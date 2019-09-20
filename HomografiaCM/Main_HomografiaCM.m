%% Inicio
clear all;
close all;
addpath('C:\mexopencv2017');

%% Corrigo la imagen a encontrar los centroides en cms
load('parametrosCalibracion.mat');
DEBUG = 1;
uncorrect = imread('img\ConLaser16.jpg');
ImUndist= cv.undistort(uncorrect, A, distCoeffs);
if DEBUG == 1
    figure;
    imshow(ImUndist);
    title('Corrected');
    drawnow;
end

%% Obtengo centroides y los paso a cms
Obj = DetectaContorno_Sauvola(ImUndist);
Centroides = cat(1,Obj.Centroid);
Centroides = [Centroides, ones(size(Centroides,1),1)];
res = GetHomografia2D(Centroides);
hold on;
for i = 1:size(res,1)
    rectangle('Position',Obj(i).BoundingBox, 'LineWidth',2);
    msg = "Col: " + num2str(res(i,1)) + ", Fila: " + num2str(res(i,2));
    text(Obj(i).BoundingBox(1)-10,Obj(i).BoundingBox(2)-10,msg);
    plot(Centroides(i,1),Centroides(i,2),'r*','LineWidth',2)
end
hold off;