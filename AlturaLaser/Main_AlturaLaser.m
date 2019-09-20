%% Inicio
clear all;
close all;
addpath('C:\mexopencv2017');
DEBUG = 1;

%% Corrige el efecto barrilete
load('parametrosCalibracion.mat');
uncorrect = imread('img\ConLaser15.jpg');
% if DEBUG == 1
%     figure;
%     imshow(uncorrect);
%     title('Uncorrected');
%     drawnow;
% end
ImUndist= cv.undistort(uncorrect, A, distCoeffs);
if DEBUG == 1
    figure;
    imshow(ImUndist);
    title('Corrected');
    drawnow;
end

%% Obtenemos la matriz de homografia y la de rotacion
[H,Rx] = GetHomografiaYRotacion();
invRx = inv(Rx);
% El origen de coordenadas es la punta de abajo del laser
% Sacamos longitud filas y columnas
longcolumnas = size(ImUndist,2);
longfilas = size(ImUndist,1);

%% Obtenemos los objetos detectados y el laser
Obj = DetectaContorno_Sauvola(ImUndist);
[linesResult,ncolorig]= DetectaLaser(ImUndist);
% Fila, columna
%origen = [longfilas-718, longcolumnas-610, 1];
origen = [longfilas, ncolorig, 1];

% Guardo en vectores el punto medio de las linesResult
xq = []; yq = [];
for i = 1:length(linesResult)
    if isempty(linesResult{i}) == 0
        py_line = linspace(linesResult{i}(2),linesResult{i}(4),abs(linesResult{i}(2)-linesResult{i}(4)));
        px_line = linspace(linesResult{i}(1),linesResult{i}(3),length(py_line));
        
%         puntomedio = (P1(:) + P2(:)).'/2;
        xq = [xq, px_line];
        yq = [yq, py_line];
    end
end

% Determino por cada objeto un solo punto de láser
PuntosPXLaser = [];
PuntoCMactual = [];
for i = 1:length(Obj)
    % Miro si hay puntos dentro del objeto
    xv = [Obj(i).Extrema(1,1), Obj(i).Extrema(2,1), Obj(i).Extrema(3,1), ...
        Obj(i).Extrema(4,1), Obj(i).Extrema(5,1), Obj(i).Extrema(6,1),...
        Obj(i).Extrema(7,1), Obj(i).Extrema(8,1)];
    yv = [Obj(i).Extrema(1,2), Obj(i).Extrema(2,2), Obj(i).Extrema(3,2), ...
        Obj(i).Extrema(4,2), Obj(i).Extrema(5,2), Obj(i).Extrema(6,2),...
        Obj(i).Extrema(7,2), Obj(i).Extrema(8,2)];
    % Laser de los que pertenecen a un objeto
    [in,on] = inpolygon(xq,yq,xv,yv);
    % x (columna), y (fila)
    laserx = xq(in);
    lasery = yq(in);
    
    % Obtengo puntos de laser en PuntosPXLaser
    if isempty(laserx) == 0
        %fprintf("Objeto: %d, entra en se ha obtenido objeto\n", i);
        index_proximo = 1;
        mindist = Inf;
        % Punto del laser mas proximo al centroide
        for j = 1:length(laserx)
            mindist_posible = sqrt(([laserx(j), lasery(j)] - [Obj(i).Centroid(1), Obj(i).Centroid(2)]) .^ 2);
            if mindist_posible < mindist
                mindist = mindist_posible;
                index_proximo = j;
            end
        end
        disp(lasery(index_proximo));
        disp(laserx(index_proximo));
        % fila, columna, altura y despues indice de objeto
        puntopxactual = [ceil(origen(1)-lasery(index_proximo)) ceil(origen(2)-laserx(index_proximo)) 1];
        puntocmactual_pre = H*puntopxactual';
        puntocmactual_pre = invRx*puntocmactual_pre;
        PuntosPXLaser=[PuntosPXLaser; puntopxactual];
        puntocmactual_pre(4) = i;
        PuntoCMactual = [PuntoCMactual; puntocmactual_pre'];
        if DEBUG == 1
            ImUndist = insertMarker(ImUndist,Obj(i).Centroid,'o','size',10);
            ImUndist = insertMarker(ImUndist,Obj(i).Extrema(8,:),'+','size',10,'color','red');
            ImUndist = insertMarker(ImUndist,Obj(i).Extrema(6,:),'+','size',10,'color','blue');
            ImUndist = insertMarker(ImUndist,Obj(i).Extrema(3,:),'+','size',10,'color','magenta');
            ImUndist = insertMarker(ImUndist,Obj(i).Extrema(5,:),'+','size',10,'color','white');
            if isempty(laserx) == 0
                ImUndist = insertMarker(ImUndist,[laserx(index_proximo),lasery(index_proximo)],'*','size',10);
            end
            imshow(ImUndist);
        end
    end
end

%% Pintamos las boundingbox
for i = 1:size(PuntoCMactual,1)
    indexobj = PuntoCMactual(i,4);
    rectangle('Position',Obj(indexobj).BoundingBox, 'LineWidth',2);
    text(Obj(indexobj).BoundingBox(1)-10,Obj(indexobj).BoundingBox(2)-10,num2str(PuntoCMactual(i,3)));
end
hold on;
plot(origen(2),origen(1),'r*','LineWidth',2);
hold off;

% PuntosCmAux_est = inv(Rx)*(H*PuntosPXLaser');
% % PuntosCmAux_est = H*PuntosPXLaser';
% fprintf("Los puntos de laser en cms estimados son: ");
% disp(PuntosCmAux_est');