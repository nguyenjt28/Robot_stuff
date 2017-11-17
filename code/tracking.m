imaqreset;
rehash;

clc
clear
close all

%%%Raspberry Initialize
 mypi = raspi;

%%%Initialize Camera
cam = videoinput('winvideo', 1);
cam.FramesPerTrigger = 1;
cam.ReturnedColorSpace = 'grayscale';
triggerconfig(cam,'manual');
start(cam);

% while(1)
%     cam_snap = getsnapshot(cam);
    cam_snap = imread('IR1_gesture5.jpg');          %%%Use picture
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
    plot(centroids(:,1), centroids(:,2), '+r', 'MarkerSize',10);    %Mass Centroid

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Lcheck = abs(centroids(1) - column1L);
    Rcheck = abs(centroids(1) - column2L);
    totalCheck = Lcheck - Rcheck;
    if totalCheck > 10
        motion = 'LEFT'
    elseif totalCheck < -10
        motion = 'RIGHT'
    elseif totalCheck >= -10 && totalCheck <= 10
        motion = 'CENTER'
    end
    
    pointBOX = BW(row1L:row2L,column1L:column2L);
    point1L = find(pointBOX,1,'first')+row1L;
    point2L = mod(find(pointBOX,1,'last'),(row2L-row1L+1))+row1L;
    if point1L < centroids(2)
        plot(column1L,point1L, '*g', 'MarkerSize',10)
    end
    if point2L < centroids(2)
        plot(column2L,point2L, '*g', 'MarkerSize',10)
    end
    
%%%%%%%%%%%%%%%%%%%CAM_TRACKING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    center_image=size(cam_snap)/2+.5;                           %%%Calculates Center point
    cam_sensitivity = 25;                                       %%%Cam tracking sensitivity
    plot(center_image(:,2),center_image(:,1), '+g', 'MarkerSize', 10);
    configurePin(mypi,5,'DigitalOutput');
    configurePin(mypi,6,'DigitalOutput');
            
    if centroids(:,1) > center_image(:,2)+cam_sensitivity           %%%Will center the user to the middle of the screen
        writeDigitalPin(mypi,6,1);
    elseif centroids(:,1) < center_image(:,2)-cam_sensitivity
        writeDigitalPin(mypi,5,1);
    else
    end
end