%% Author: Andrew Petersen
% Assignment: 9_11
% Course: CEC 495A
%%

clc;
clear all;
warning off

img1 = imread('img/1.jpg');
img2 = imread('img/2.jpg');
ipts1 = OpenSurf(img1);
ipts2 = OpenSurf(img2);
Ipts1X = zeros(length(ipts1),1);
Ipts1Y = zeros(length(ipts1),1);
Ipts2X = zeros(713,1);
Ipts2Y = zeros(713,1);

for i = 1:length(ipts1)
    Ipts1X(i) = ipts1(i).x;
    Ipts1Y(i) = ipts1(i).y;
end

for j = 1:713
    Ipts2X(j) = ipts2(j).x;
    Ipts2Y(j) = ipts2(j).y;
end

Ipts1 = [Ipts1X';Ipts1Y'];
Ipts2 = [Ipts2X';Ipts2Y'];
% [M, inliers] = ransac(Ipts1);
[H, inliers] = ransacfithomography(Ipts1, Ipts2, .05);
fixedPoints = [Ipts1(2,inliers)' Ipts1(1,inliers)'];
movingPoints = [Ipts2(2,inliers)' Ipts2(1,inliers)'];

   % Determining the transform based on the relationship matrices between
    % the coordinates in the two images
    tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity');
    
    % Image registration (alignment)
    Jregistered = imwarp(img2,tform,'OutputView',imref2d(size(img1)));
    falsecolorOverlay = imfuse(img1,Jregistered);

    % Putting everything together into a 2x2 image
    I1 = cat(2,img2(1:704,1:985,:),Jregistered);
    im1rgb = cat(3,img1,img1,img1);
    I2 = cat(2,im1rgb(:,:,1:3),falsecolorOverlay);
    I = cat(1,I1,I2(1:704,1:1970,:));

    % Accounting for the concatenation
    shiftY = size(img1,1);
    shiftX = size(img1,2);

    % Displaying the four images
    imshow(I,'Border','tight'); hold on;

    % Plotting the relationships between img1 and img2 images (RANSAC
    % results only at this point)
    plot(Ipts1(2,inliers),Ipts1(1,inliers)+shiftY,'r+');
    hold on
    plot(Ipts2(2,inliers),Ipts2(1,inliers)+shiftY,'b+');    

   