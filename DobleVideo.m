close all;
clc;
clear all;

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

recortado = false;
transform = eye(3);

% Read a video frame and run the face detector.
archivo="obj 3.mp4"
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

        %614 410
        escaladoOriginal = size(videoOriginal{1});
        escaladoTrack = size(videoTrack{1});
        escaladoStable = size(videoEstabilizado{1});
        if(escaladoOriginal(1)>escaladoOriginal(2))
            escaladoOriginal = [614 NaN];
        else
            escaladoOriginal = [NaN 410];
        end
        if(escaladoTrack(1)>escaladoTrack(2))
            escaladoTrack = [400 NaN];
        else
            escaladoTrack = [NaN 300];
        end
        if(escaladoStable(1)>escaladoStable(2))
            escaladoStable = [400 NaN];
        else
            escaladoStable = [NaN 300];
        end

        showFrameOnAxis(hAxes.pict1, imresize(capturaPuntos,escaladoOriginal));
        showFrameOnAxis(hAxes.pict2, imresize(capturaBox,escaladoOriginal));
        
        %exportarVideo
        writerTrack=VideoWriter(archivo+"-TRACK");
        writerEstabilizado=VideoWriter(archivo+"-STABLE");
        open(writerTrack);
        for i=1:size(videoTrack(:))
            writeVideo(writerTrack,videoTrack{i});
        end
        close(writerTrack);
        open(writerEstabilizado);
        for i=1:size(videoEstabilizado(:))
            writeVideo(writerEstabilizado,videoEstabilizado{i});
        end
        close(writerEstabilizado);

        figure(hFig);
        recortado=true;
        indice=1;
    end
end
auxi = size(videoTrack(:));
aux =size(videoOriginal(:));
while true
    if indice<=aux(1)
        if indice<auxi(1)
            frameTrack=videoTrack{indice};
            frameEstabilizado=videoEstabilizado{indice};
            showFrameOnAxis(hAxes.axis2, imresize(frameTrack,escaladoTrack));
            showFrameOnAxis(hAxes.axis3, imresize(frameEstabilizado,escaladoStable)); 
        end
        frameOriginal=videoOriginal{indice};
        
    
        % Display the annotated video frame using the video player object
        showFrameOnAxis(hAxes.axis1, imresize(frameOriginal,escaladoOriginal));
                  
        indice=indice+1;
    end
    if(indice>aux(1))
        indice=1;
    end
end