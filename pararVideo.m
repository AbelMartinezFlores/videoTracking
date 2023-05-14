% Cargar el video
video = VideoReader('caras 1.avi');

% Mostrar el primer fotograma
frame = readFrame(video);
figure;
imshow(frame);



% Navegar entre los fotogramas
while hasFrame(video)
    waitforbuttonpress;

    % Obtener información sobre la tecla presionada
    key = get(gcf, 'CurrentCharacter');
    disp(key)

    if (key == 'd')
        % Leer el siguiente fotograma
        frame = readFrame(video);
     
        % Mostrar el fotograma
        imshow(frame);
    end
    if (key == 'w')
        
    end
end
