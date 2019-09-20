%% ncolorig tiene la columna con el laser mas a la derecha detectada   
function [linesResult,ncolorig] = DetectaLaser(src)
debug = 0;
limpxdreta = 400;
limpxesq = 570;
if debug == 0
    addpath('C:\mexopencv2017');
end
%% Processing - Edge Detection
[bw,mask] = createMaskHSV_Laser2(src);
dst = cv.Canny(mask, [0, 500], 'ApertureSize',3); 

%% Output images
color_dst = cv.cvtColor(dst, 'GRAY2RGB'); 

%% HoughLinesP
tic 
lines = cv.HoughLinesP(dst,'Threshold',10,'MinLineLength',10,'MaxLineGap',5); 
toc 

%% Filtra y pinta las lineas encontradas
ncolorig = 550; %Por defecto
for i=1:numel(lines)     
    % Si las columnas caen de la franja posible...
    if (lines{i}(1)<= limpxesq && lines{i}(3)>=limpxdreta)
        %fprintf("Comparado ncolorig: %d, lines(2): %d, lines(4): %d",ncolorig,lines{i}(2),lines{i}(4));
        % si es totalmente recto (columnas iguales)
        if lines{i}(1) == lines{i}(3)  
            linesResult{i} = lines{i};
            ncolorig = max(ncolorig,lines{i}(3));
            ncolorig = max(ncolorig,lines{i}(1));
            color_dst = cv.line(color_dst, lines{i}(1:2), lines{i}(3:4), ...
            'Color',[0,0,255], 'Thickness',2, 'LineType','AA'); 
        % Si es totalmente horizontal
        elseif lines{i}(2) == lines{i}(4)
            % Nada
        else
            d_alto = abs(lines{i}(2)-lines{i}(4));
            d_ancho = abs(lines{i}(1)-lines{i}(3));
            if d_ancho/d_alto < 0.2
                linesResult{i} = lines{i};
                ncolorig = max(ncolorig,lines{i}(3));
                ncolorig = max(ncolorig,lines{i}(1));
                color_dst = cv.line(color_dst, lines{i}(1:2), lines{i}(3:4), ...
                'Color',[0,0,255], 'Thickness',2, 'LineType','AA'); 
            end
        end
    end
end
if debug == 1
    figure;
    imshow(color_dst), title('Detected Line Segments');
    hold on;
    plot(ncolorig,size(src,1),'r*','LineWidth',2);
    hold off;
end