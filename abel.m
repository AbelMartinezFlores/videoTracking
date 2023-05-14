close all;
clc;
clear all;

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

recortado = false;
transform = [
    1 0 0
    0 1 0
    0 0 1
];

% Read a video frame and run the face detector.
videoReader = VideoReader("obj 2.mp4");
videoFrame      = readFrame(videoReader);

indice = 1;
numFrames = videoReader.NumFrames;
disp(numFrames)

%bbox            = step(faceDetector, videoFrame);
figure; imshow(videoFrame);


while hasFrame(videoReader)

    if( recortado == false)
        waitforbuttonpress;
    end

    % Obtener información sobre la tecla presionada
    key = get(gcf, 'CurrentCharacter');
    disp(key)

    if (key == 'd' & recortado == false & indice < numFrames )
        indice = indice + 1;
        disp(indice);
        % Leer el siguiente fotograma
        videoFrame = read(videoReader, indice);
        % Mostrar el fotograma
        imshow(videoFrame);
        
    end

    if (key == 'a' & recortado == false & indice > 1)
        indice = indice - 1;
        disp(indice);
        % Leer el siguiente fotograma
        videoFrame = read(videoReader, indice);
        % Mostrar el fotograma
        imshow(videoFrame);
    end

    if (key == 'w' & recortado == false)
        %bbox = step(faceDetector, videoFrame);

        [a,b,c,bbox] = imcrop(videoFrame);

        % Draw the returned bounding box around the detected face.
        videoFrame = insertShape(videoFrame, "rectangle", bbox);
        figure; imshow(videoFrame); title("Detected face");
        
        % Convert the first box into a list of 4 points
        % This is needed to be able to visualize the rotation of the object.
        bboxPoints = bbox2points(bbox(1, :));
        
        points = detectMinEigenFeatures(im2gray(videoFrame), "ROI", bbox);
        
        % Display the detected points.
        figure, imshow(videoFrame), hold on, title("Detected features");
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
            videoFrame = insertShape(videoFrame, "polygon", bboxPolygon, "LineWidth", 2);
                    
            % Display tracked points
            videoFrame = insertMarker(videoFrame, visiblePoints, "+", "Color", "white");       
            
            % Reset the points
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);     

            %ESTABILIZACIOn
            tform = estgeotform2d(oldInliers,visiblePoints,"similarity","MaxDistance",15);
            auxtrans = [
                (1/tform.Scale)*cosd(tform.RotationAngle) -(1/tform.Scale)*sind(tform.RotationAngle) 0
                (1/tform.Scale)*sind(tform.RotationAngle) (1/tform.Scale)*cosd(tform.RotationAngle) 0
                -tform.Translation(1) -tform.Translation(2) 1
            ];
            transform = auxtrans * transform;
            videoFrame = imwarp(videoFrame,affine2d(transform),"OutputView",imref2d(size(videoFrame)));

        end
        
        % Display the annotated video frame using the video player object
        step(videoPlayer, videoFrame);
    end

    
end

% Clean up
release(videoPlayer);