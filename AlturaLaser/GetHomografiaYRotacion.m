function [H,Rx] = GetHomografiaYRotacion()
load('PuntosPXInv.mat');
load('parametrosCalibracion.mat');
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
    hold on;
    plot((611-PuntosPX(:,2)),720-PuntosPX(:,1),'r*','LineWidth',2);
    hold off;
end

%% Medidas reales - Con eje X origen en final
PuntosRealCm = [19.5   0.5 1;
                18  0.5 1;
                16.2  0.5 1;
                14.8  0.5 1;
                10.9  1.4 1.8;
                8.2   0.7 1.4;
                5.3   1.5 2.2;
                2     1.5 2.2];

%% Obtenemos angulo
Beta = [];
for i=1:length(PuntosRealCm)
    % beta = atan(z/y).
    Beta = [Beta; atan(PuntosRealCm(i,3)/(PuntosRealCm(i,2)))];
end
Media_rad = mean(Beta);

%% Construimos matriz de rotacion
Rx = [1 0 0; 
    0 cos(Media_rad) sin(Media_rad);
    0 -sin(Media_rad) cos(Media_rad)];

PL = Rx*PuntosRealCm';

%% Obtener homografia
% estMethods = {0, 'Ransac', 'LMedS', 'Rho'};
% for i=1:numel(estMethods)
%     %[HH, mask] = cv.findHomography(p2, p1,'Method',estMethods{i}, 'MaxIters',2000,'RansacReprojThreshold',3.0, 'Confidence',0.995);
%     [H, ~] = cv.findHomography(PuntosPX, PL','LMedS',estMethods{i},'MaxIters',2000,'RansacReprojThreshold',3.0,'Confidence',0.995);
%     imagenDestino = cv.warpPerspective(ImUndist, H);
%     figure;
%     imshow(imagenDestino);
% end
[H, ~] = cv.findHomography(PuntosPX, PL','Method',0,'MaxIters',2000,'RansacReprojThreshold',3.0,'Confidence',0.995);