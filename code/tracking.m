imaqreset;
rehash;

clc
clear
close all

%%%Raspberry Initialize
 mypi = raspi;

%%%Initialize Camera
% cam = videoinput('winvideo', 1, 'YUY2_640x480');
% cam.FramesPerTrigger = 1;
% cam.ReturnedColorSpace = 'grayscale';
% triggerconfig(cam,'manual');
% start(cam);

% while(1)
%     cam_snap = getsnapshot(cam);
    cam_snap = imread('IR1_6.23_3people_walk17.jpg');          %%%Use picture
    level = graythresh(cam_snap)+0.08;
    bwthreshold = 0.5;                         %%%Black White Threshold Value
    BW = imbinarize(cam_snap,level);      %%%Binarizes cam_snap
    sfigure(1); imshowpair(cam_snap,BW,'montage');
    
    se90 = strel('line',3,90);                  % out of while would be faster but harder to read
    se0 = strel('line',3,0);                    %Structuring elements
    BW = imerode(BW,[se90 se0]);                % imerode clears/erode noise/edges 
    BW = imdilate(BW,[se90 se0]);               % expand/dilate areas to reconnect things
    CCL = bwconncomp(BW);
    
    numPixels = cellfun(@numel,CCL.PixelIdxList);
    [largest_PixelGroup,idxL] = max(numPixels);          %biggest is largets # of pixels, idx is column number housing largest area
    
    BW = bwareaopen(BW,largest_PixelGroup);
%     figure(2); imshow(BW);
    
    
    %%%%%%Drawing Rectangle based off the max and min pixel%%%%%%%%%%%%%%%%
    verticalL = any(BW,2);
    horizontalL = any(BW,1);
    row1L = find(verticalL,1,'first');          %Finds top row pixel of 1 in image
    row2L = find(verticalL,1, 'last');          %Finds lowest/bottom row pixel of 1 in image
    column1L = find(horizontalL,1,'first');     %Finds first horizontal pixel (first side of target)
    column2L = find(horizontalL,1,'last');      %Finds last horizontal pixel (last side of target)
    wL = column2L - column1L;
    hL = row2L - row1L;

    sfigure(3); imshow(BW); hold on;
    rectangle('Position',[column1L row1L wL hL],'EdgeColor','r','LineStyle','-.','LineWidth',1.5);
    center  = regionprops(BW, 'centroid');
    centroids = cat(1, center.Centroid);
    plot(centroids(:,1), centroids(:,2), '+r', 'MarkerSize',10);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    boundary1 = 1;
    boundary2 = length(BW)-100;
    configurePin(mypi,5,'DigitalOutput');
    configurePin(mypi,6,'DigitalOutput');
    
    if column1L <= boundary1
        writeDigitalPin(mypi,6,1);
    elseif column2L >= boundary2
        writeDigitalPin(mypi,5,1);
    else
    end
% end