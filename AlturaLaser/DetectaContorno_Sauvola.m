function result = DetectaContorno_Sauvola(src)
DEBUG = 0;
% Primero aplica un fitro para que la chocolatina blanca se vea sobre el
% fondo blanco
[Gbw,mask] = createMask_CogeContornos(src);
% Aplico sauvola
Gbw = rgb2gray(mask);
U=~sauvola(Gbw,[20 20]);
C=bwconncomp(U);
if DEBUG == 1
    figure;
    L=labelmatrix(C);
    CL=label2rgb(L,@hsv,'w','shuffle');
    imshow(CL);
    pause(2);
end
% Sacamos las propiedades
FilledAreaMin = 10000;
FilledAreaMax = 80000;
RChocos = regionprops(C,'BoundingBox','FilledArea','Centroid','Extrema');
contresult = 1;
result = [];
for i = 1:length(RChocos)
    if (RChocos(i).FilledArea < FilledAreaMax) && (RChocos(i).FilledArea > FilledAreaMin)
        result = [result; RChocos(i)];
        contresult = contresult + 1;
        if DEBUG == 1
            rectangle('Position',RChocos(i).BoundingBox, 'LineWidth',2);
            text(RChocos(i).BoundingBox(1)-10,RChocos(i).BoundingBox(2)-10,int2str(RChocos(i).FilledArea));
        end
    end
end