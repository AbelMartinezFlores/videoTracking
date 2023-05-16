%PRUEBA VIDEO
[hFig, hAxes] = createFigureAndAxes();

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

recortado = false;
transform = eye(3);

% Read a video frame and run the face detector.
videoReader = VideoReader("caras 1.avi");
videoFrame = readFrame(videoReader);

indice = 1;

numFrames = videoReader.NumFrames;

%bbox            = step(faceDetector, videoFrame);
imshow(videoFrame);

while hasFrame(videoReader)

    %REBOBINADO Y RECORTADO
    if( recortado == false)
        waitforbuttonpress;
    end
    key = get(gcf, 'CurrentCharacter');
    if (key == 'd' & ~recortado & indice < numFrames )
        indice = indice + 1;
        % Leer el siguiente fotograma
        videoFrame = read(videoReader, indice);
        % Mostrar el fotograma
        imshow(videoFrame);
        
    end
    if (key == 'a' & ~recortado & indice > 1)
        indice = indice - 1;
        % Leer el siguiente fotograma
        videoFrame = read(videoReader, indice);
        % Mostrar el fotograma
        imshow(videoFrame);
    end

    %PLAY
    if (key == 'w' & recortado == false)
        %bbox = step(faceDetector, videoFrame);

        [a,b,c,bbox] = imcrop(videoFrame);

        % Draw the returned bounding box around the detected face.
        videoFrame = insertShape(videoFrame, "rectangle", bbox);
        %figure; imshow(videoFrame); title("Detected face");
        
        % Convert the first box into a list of 4 points
        % This is needed to be able to visualize the rotation of the object.
        bboxPoints = bbox2points(bbox(1, :));
        
        points = detectMinEigenFeatures(im2gray(videoFrame), "ROI", bbox);
        
        % Display the detected points.
        %figure, imshow(videoFrame), hold on, title("Detected features");
        plot(points);
        
        pointTracker = vision.PointTracker("MaxBidirectionalError", 2);
        
        % Initialize the tracker with the initial point locations and the initial
        % video frame.
        points = points.Location;
        initialize(pointTracker, points, videoFrame);
        
        videoPlayer  = vision.VideoPlayer("Position", [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);
        
        oldPoints = points;

        recortado = true;
    end

    if recortado == true
        
        % get the next frame
        videoFrame = readFrame(videoReader);
    
        % Track the points. Note that some points may be lost.
        [points, isFound] = step(pointTracker, videoFrame);
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
            videoTrack = insertShape(videoFrame, "polygon", bboxPolygon, "LineWidth", 2);
                    
            % Display tracked points
            videoTrack = insertMarker(videoTrack, visiblePoints, "+", "Color", "white");       
            
            % Reset the points
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);     

            %ESTABILIZACIOn
            tform = estgeotform2d(oldInliers,visiblePoints,"similarity","MaxDistance",15);
            auxtrans = inv(tform.A).';
            transform = auxtrans * transform;
            videoEstabilizado = imwarp(videoFrame,affine2d(transform),"OutputView",imref2d(size(videoFrame)));

        end 
        % Display the annotated video frame using the video player object
        %step(videoPlayer, videoFrame);
        showFrameOnAxis(hAxes.axis1, imresize(videoFrame,0.25));
        showFrameOnAxis(hAxes.axis2, imresize(videoTrack,0.25));
        showFrameOnAxis(hAxes.axis3, imresize(videoEstabilizado,0.25));
        %showFrameOnAxis(hAxes.axis1, frameOriginal);
        %showFrameOnAxis(hAxes.axis2, frameTrack);
        %showFrameOnAxis(hAxes.axis2, frameEstabilizado);
    end
end

% Clean up
release(videoPlayer);