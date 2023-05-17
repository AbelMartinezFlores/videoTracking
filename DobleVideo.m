close all;
clc;
clear all;

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

recortado = false;
transform = eye(3);

% Read a video frame and run the face detector.
archivo="caras 1.avi"
videoReader = VideoReader(archivo);
videoFrame = readFrame(videoReader);

indice = 1;

numFrames = videoReader.NumFrames;

%bbox            = step(faceDetector, videoFrame);
imshow(videoFrame);        
%PRUEBA VIDEO
[hFig, hAxes] = createFigureAndAxes();

while hasFrame(videoReader)
    %REBOBINADO Y RECORTADO
    if(recortado == false)
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
    if (key == 'w' & ~recortado)
        [a,b,c,bbox] = imcrop(videoFrame);
        [videoOriginal,videoTrack,videoEstabilizado,capturaPuntos,capturaBox] = procesarVideo(videoReader,indice,bbox);
        showFrameOnAxis(hAxes.pict1, imresize(capturaPuntos,0.3));
        showFrameOnAxis(hAxes.pict2, imresize(capturaBox,0.3));
        
        %exportarVideo
        writerTrack=VideoWriter(archivo+"-TRACK");
        writerEstabilizado=VideoWriter(archivo+"-STABLE");
        open(writerTrack);
        for i=1:size(videoTrack(:));
            writeVideo(writerTrack,videoTrack{i});
        end
        close(writerTrack);
        open(writerEstabilizado);
        for i=1:size(videoEstabilizado(:));
            writeVideo(writerEstabilizado,videoEstabilizado{i});
        end
        close(writerEstabilizado);

        figure(hFig);
        recortado=true;
        indice=1;
    end
    if recortado == true
        aux =size(videoOriginal(:));
        if indice<aux(1)
            frameOriginal=videoOriginal{indice};
            frameTrack=videoTrack{indice};
            frameEstabilizado=videoEstabilizado{indice};
        
            % Display the annotated video frame using the video player object
            showFrameOnAxis(hAxes.axis1, imresize(frameOriginal,0.3));
            showFrameOnAxis(hAxes.axis2, imresize(frameTrack,0.3));
            showFrameOnAxis(hAxes.axis3, imresize(frameEstabilizado,0.3));           
            indice=indice+1;
        end
    end
end

% Clean up
release(videoPlayer);