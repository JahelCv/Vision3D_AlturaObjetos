load('parametrosCalibracion.mat');
pathorig = 'C:\Users\Jahel\Documents\MATLAB\Treball3D\AlturaLaser\img\';
pathdest = 'C:\Users\Jahel\Documents\MATLAB\Treball3D\AlturaLaser\img_corregidas\';
files = dir(strcat(pathorig,'*.jpg'));
i = 1;
for file = files'
    pathname=strcat(pathorig,file.name);
    uncorrect = imread(pathname);
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
        dest = strcat(pathdest,'ConLaserCorregida',num2str(i),'.jpg');
        imwrite(ImUndist,dest);
    end
    i = i+1;
end