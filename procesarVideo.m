function [videoOriginal, videoTrack, videoEstabilizado] = procesarVideo(videoReader,frameIdx,bbox)
transform = eye(3);
    for idx=1:(videoReader.NumFrames-frameIdx+1)
        frame=read(videoReader,frameIdx+idx-1);
        
        videoOriginal{idx}=frame;
        videoTrack{idx}=frame;
        videoEstabilizado{idx}=frame;
        
        if(idx==1)
            % Convert the first box into a list of 4 points
            % This is needed to be able to visualize the rotation of the object.
            bboxPoints = bbox2points(bbox(1, :));
            
            points = detectMinEigenFeatures(im2gray(videoOriginal{idx}), "ROI", bbox);
            
            % Display the detected points.
            %figure, imshow(videoFrame), hold on, title("Detected features");
            %plot(points);
            
            pointTracker = vision.PointTracker("MaxBidirectionalError", 2);
            
            % Initialize the tracker with the initial point locations and the initial
            % video frame.
            points = points.Location;
            initialize(pointTracker, points, videoOriginal{idx});
            
            oldPoints = points;

            xminglobal = min(bboxPoints(:,1));
            yminglobal = min(bboxPoints(:,2));
            xmaxglobal = max(bboxPoints(:,1));
            ymaxglobal = max(bboxPoints(:,2));            
        end
    
        % Track the points. Note that some points may be lost.
        [points, isFound] = step(pointTracker, videoOriginal{idx});
        visiblePoints = points(isFound, :);
        oldInliers = oldPoints(isFound, :);
        
        if size(visiblePoints, 1) >= 2 % need at least 2 points
            
            % Estimate the geometric transformation between the old points
            % and the new points and eliminate outliers
            [xform, inlierIdx] = estimateGeometricTransform2D(oldInliers, visiblePoints, "similarity", "MaxDistance", 4);
            oldInliers    = oldInliers(inlierIdx, :);
            visiblePoints = visiblePoints(inlierIdx, :);
            
            % Apply the transformation to the bounding box points
            bboxPoints = transformPointsForward(xform, bboxPoints);
                    
            % Insert a bounding box around the object being tracked
            bboxPolygon = reshape(bboxPoints', 1, []);
            videoOriginal{idx} = insertShape(videoOriginal{idx}, "polygon", bboxPolygon, "LineWidth", 2);
    
            % poner toda la imagen en negro menos el bounding box
            tam = size(videoOriginal{idx});
            matriz = zeros(tam(1),tam(2), 'uint8');
            xmin = max(mean([bboxPoints(1,1) bboxPoints(4,1)]),1);
            ymin = max(mean([bboxPoints(1,2) bboxPoints(2,2)]),1);
            xmax = min(mean([bboxPoints(2,1) bboxPoints(3,1)]),tam(2));
            ymax = min(mean([bboxPoints(3,2) bboxPoints(4,2)]),tam(1));            
            %xmin = max(min(bboxPoints(:,1)),1);
            %ymin = max(min(bboxPoints(:,2)),1);
            %xmax = min(max(bboxPoints(:,1)),tam(2));
            %ymax = min(max(bboxPoints(:,2)),tam(1));            
            matriz(round(ymin):round(ymax), round(xmin):round(xmax)) = 1;
            videoTrack{idx} = videoOriginal{idx} .* matriz;
                    
            % Display tracked points
            %videoTrack{idx} = insertMarker(videoTrack(idx), visiblePoints, "+", "Color", "white");       
            
            % Reset the points
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);     
    
            %ESTABILIZACIOn            
            transform = inv(xform.T.').' * transform;
            videoEstabilizado{idx} = imwarp(videoOriginal{idx},affine2d(transform),"OutputView",imref2d(size(videoOriginal{idx})));
            videoEstabilizado{idx} = imcrop(videoEstabilizado{idx},bbox);

            %RECORTE
            xminglobal = min(min(bboxPoints(:,1)),xminglobal);
            yminglobal = min(min(bboxPoints(:,2)),yminglobal);
            xmaxglobal = max(max(bboxPoints(:,1)),xmaxglobal);
            ymaxglobal = max(max(bboxPoints(:,2)),ymaxglobal);            
        end
    end
    xminglobal = max(xminglobal,1);
    yminglobal = max(yminglobal,1);
    xmaxglobal = min(xmaxglobal,tam(2));
    ymaxglobal = min(ymaxglobal,tam(1));
    width=xmaxglobal-xminglobal;
    height=ymaxglobal-yminglobal;
    for n=1:size(videoTrack(:))
        videoTrack{n} = imcrop(videoTrack{n},[xminglobal yminglobal width height]);
    end
end