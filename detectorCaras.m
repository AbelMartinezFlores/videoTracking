clc;
clear all;
close all;
%Creamos un detector de objetos en cascada
faceDetector = vision.CascadeObjectDetector();
faceDetector.MergeThreshold = 8;
% Iniciamos video
videoReader = VideoReader("caras 2.avi");

while hasFrame(videoReader)
    % Siguiente Frame
    videoFrame = readFrame(videoReader);
    %pasamos el frame a escala de grisas
    gris = rgb2gray(videoFrame);
    %detectamos las caras en la imagen de escala de gris
    bbox = faceDetector(gris);
    %dibujamos las cajas que se detectan
    detpic = insertObjectAnnotation(videoFrame, 'rectangle', bbox, 'Face');
    imshow(detpic);
end
