clc;
clear all;
close all;
%Creamos un detector de objetos en cascada
faceDetector = vision.CascadeObjectDetector();
faceDetector.MergeThreshold = 8;
% Iniciamos video
archivo="caras 1.avi"
videoReader = VideoReader(archivo);

while hasFrame(videoReader)
    % Siguiente Frame
    videoFrame = readFrame(videoReader);
    %pasamos el frame a escala de grisas
    gris = rgb2gray(videoFrame);
    %detectamos las caras en la imagen de escala de gris
    bbox = faceDetector(gris);
    %dibujamos las cajas que se detectan
    frame = insertObjectAnnotation(videoFrame, 'rectangle', bbox, 'Face');
    imshow(frame);


    %exportarVideo
    writerTrack=VideoWriter(archivo+"-TRACK-FACE");
    open(writerTrack);
    writeVideo(writerTrack,frame);
    close(writerTrack);
    

end
