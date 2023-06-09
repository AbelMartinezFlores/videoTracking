% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the face detector.
videoReader = VideoReader("obj 2.mp4");
videoFrame      = readFrame(videoReader);
%bbox            = step(faceDetector, videoFrame);

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

videoPlayer  = vision.VideoPlayer("Position", [100 100 1024 576]);

oldPoints = points;
transform = [
    1 0 0
    0 1 0
    0 0 1
];

while hasFrame(videoReader)
    % get the next frame
    videoFrame = readFrame(videoReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);
    
    if size(visiblePoints, 1) >= 2 % need at least 2 points
        
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, inlierIdx] = estimateGeometricTransform2D(oldInliers, visiblePoints, "similarity", "MaxDistance", 15);
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
        auxtrans = inv(tform.A).';
        transform = auxtrans * transform;
        videoFrame = imwarp(videoFrame,affine2d(transform),"OutputView",imref2d(size(videoFrame)));
    end

    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
end

% Clean up
release(videoPlayer);