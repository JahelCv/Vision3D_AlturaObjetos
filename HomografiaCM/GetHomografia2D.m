function res = GetHomografia2D(Puntos_PX)
    load('parametrosCalibracion.mat');

    %% Cargamos img de referencia
    uncorrect = imread('img\Medidas.jpg');
    DEBUG = 0;
    if DEBUG == 1
        figure;
        imshow(uncorrect);
        title('Uncorrected');
        drawnow;
    end
    ImUndist= cv.undistort(uncorrect, A, distCoeffs);
    if DEBUG == 1
        figure;
        imshow(ImUndist);
        title('Corrected');
        drawnow;
    end

    %% Medidas reales - Con eje X origen en final
    PuntosRefCm = [19.7  6.75 1; % Chocolate rojo
                    19.7  10 1; % Chocolate rojo
                    20  15.9 1; % Choco Lion
                    19  21.85 1]; %Choco Lindt

    %% Medidas de PX
    PuntosRefPX = [595, 161, 1; % Chocolate rojo
                   595, 263, 1; % Chocolate rojo
                   607, 437, 1; % Choco Lion
                   573, 607, 1]; %Choco Lindt

    %% Obtener homografia y cms
    [H, ~] = cv.findHomography(PuntosRefPX, PuntosRefCm,'Method',0,'MaxIters',2000,'RansacReprojThreshold',3.0,'Confidence',0.995);
    res = H*(Puntos_PX');
    res = res';