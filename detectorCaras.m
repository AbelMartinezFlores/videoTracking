clc;
clear all;
close all;
% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the face detector.
videoReader = VideoReader("caras 1.avi");

while hasFrame(videoReader)
    % get the next frame
    videoFrame = readFrame(videoReader);
    
   % faceDetector = vision.CascadeObjectDetector();
    gris = rgb2gray(videoFrame);

    faceDetector.MergeThreshold = 8;
    bbox = faceDetector(videoFrame);
    detpic = insertObjectAnnotation(videoFrame, 'rectangle', bbox, 'Face');

    imshow(detpic);
end

% Clean up
release(videoPlayer);