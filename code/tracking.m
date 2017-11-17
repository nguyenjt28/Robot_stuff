imaqreset;
rehash;

clc
clear
close all

%%%Raspberry Initialize
%  mypi = raspi; %UNCOMMENT%

%%%Initialize Camera %UNCOMMENT%
  cam = videoinput('winvideo', 1, 'YUY2_640x480');
  cam.FramesPerTrigger = 1;
  cam.ReturnedColorSpace = 'grayscale';
  triggerconfig(cam,'manual');
  start(cam);

 %%%%%%%%%%%%%%%%%SETTINGS%%%%%%%%%%%%%%%
gesture=zeros(1,4); %Number of gestures currently implemented
timebuffer=0;
gesturetest=1;
while(1) %UNCOMMENT%
     cam_snap = getsnapshot(cam); %UNCOMMENT%
 %    cam_snap = imread('picR142.jpg');          %%%Use picture
    level = graythresh(cam_snap)+0.00;
    bwthreshold = 0.5;                         %%%Black White Threshold Value (0.5)
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
    plot(centroids(:,1), centroids(:,2), '+r', 'MarkerSize',10); %Mass Centroid

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Lcheck = abs(centroids(1) - column1L);
    Rcheck = abs(centroids(1) - column2L);
%     if Lcheck > Rcheck
%         motion = 'LEFT'
%     elseif Rcheck > Lcheck
%         motion = 'RIGHT'
%     end
    
    pointBOX = BW(row1L:row2L,column1L:column2L);
    point1L = find(pointBOX,1,'first')+row1L;  %Extremity 1
    point2L = mod(find(pointBOX,1,'last'),(row2L-row1L+1))+row1L; %Extremity 2
    
    LHU=0; %LEFT HAND UPCONDITION
    RHU=0; %RIGHT HAND UP CONDITION
    
    VBuffer=50; %VBuffer is the difference in vertical pixels between extremeties
    HBuffer=50; %HBuffer is the difference in horizontal pixels between extremeties
    
     if (point1L < centroids(2)) && ((column2L-column1L)/2 <= (abs(centroids(1)-column1L))+HBuffer) && (column2L-column1L)>=0.5*(row2L-row1L) %Determines if extremities are protruded for gesture recognition and plots 
        plot(column1L,point1L, '*g', 'MarkerSize',10)
        RHU=1;
     end
     if (point2L < centroids(2)) && ((column2L-column1L)/2 <= (abs(column2L-centroids(1))+HBuffer)) && (column2L-column1L)>=0.5*(row2L-row1L)
        plot(column2L,point2L, '*g', 'MarkerSize',10)
        LHU=1;
     end
    
     adjacentL=abs(centroids(2)-point2L);
     oppositeL=abs(column2L-centroids(1));
     thetaL=atan(adjacentL/oppositeL)*180/pi;
     
     adjacentR=abs(centroids(2)-point1L);
     oppositeR=abs(column1L-centroids(1));
     thetaR=atan(adjacentR/oppositeR)*180/pi;
%%%%%%%%%%%%%%%%%%%%%%%GESTURES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=1; %k is a unique identifier for each gesture
timebuffer=timebuffer+1;
if timebuffer==100 %This delay is a prevantive measure in accidental gesture recognition between gestures
    gesturetest=1;
    timerbuffer=0;%This test will be set to zero as soon as a gesture is recgonized to prevent other gestures from also triggering in the same iteration
end

if ((point2L-point1L) <= VBuffer) && (column2L-column1L)>=0.7*(row2L-row1L) && RHU==1 && LHU==1 && gesture(k)~=1%If extremeties are roughly on the same horizontal plane and extended horizontally from the centroid, gesture is recognized
    disp('Gesture1')
    gesturetest=0;
    for i=1:length(gesture) %This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
        if i~=k
            gesture(i)=0;
        else
            gesture(i)=1;
        end
    end
end

k=k+1;

if ((point2L-point1L) <= VBuffer) && (column2L-column1L)<=0.2*(row2L-row1L) && gesture(k)~=1%If extremeties are roughly on the same horizontal plane and extended vertically from the centroid, gesture is recognized
    disp('Gesture2')
    gesturetest=0;
    for i=1:length(gesture) %This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
        if i~=k
            gesture(i)=0;
        else
            gesture(i)=1;
        end
    end
end

k=k+1;

if (LHU == 1) && (thetaL>=15 && thetaL<=35) && gesture(k)~=1 && (abs(thetaL-thetaR)<=10)%If only (graphically) left hand is horizontal to centroid, gesture is recognized
    disp('Gesture3')
    gesturetest=0;
    for i=1:length(gesture) %This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
        if i~=k
            gesture(i)=0;
        else
            gesture(i)=1;
        end
    end
end

k=k+1; 

if (RHU == 1) && (thetaR>=15 && thetaR<=35) && gesture(k)~=1 && (abs(thetaL-thetaR)<=10) %If only (graphically) right hand is horizontal to centroid, gesture is recognized
    disp('Gesture4')
    gesturetest=0;
    for i=1:length(gesture) %This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
        if i~=k
            gesture(i)=0;
        else
            gesture(i)=1;
        end
    end
end

% if ((LHU == 1) && (abs(centroids(2)-point1L) <= HBuffer) && (column2L-column1L)>=(3/8+1/4-0.1)*(row2L-row1L)) && gesturetest==1 && gesture(k)~=1%If only (graphically) left hand is horizontal to centroid, gesture is recognized
%     disp('Gesture3')
%     gesturetest=0;
%     for i=1:length(gesture) %This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
%         if i~=k
%             gesture(i)=0;
%         else
%             gesture(i)=1;
%         end
%     end
% end
% 
% k=k+1; 
% 
% if ((RHU == 1) && (abs(point2L-centroids(2)) <= HBuffer) && (column2L-column1L)>=(3/8+1/4-0.1)*(row2L-row1L)) && gesturetest==1 && gesture(k)~=1%If only (graphically) right hand is horizontal to centroid, gesture is recognized
%     disp('Gesture4')
%     gesturetest=0;
%     for i=1:length(gesture) %This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
%         if i~=k
%             gesture(i)=0;
%         else
%             gesture(i)=1;
%         end
%     end
% end
    
%%%%%%%%%%%%%%%%%%%CAM_TRACKING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    center_image=size(cam_snap)/2+.5;                           %%%Calculates Center point
%    cam_sensitivity = 25;                                       %%%Cam tracking sensitivity
%    plot(center_image(:,2),center_image(:,1), '+g', 'MarkerSize', 10);
%    configurePin(mypi,5,'DigitalOutput');
%    configurePin(mypi,6,'DigitalOutput');
%            
%    if centroids(:,1) > center_image(:,2)+cam_sensitivity           %%%Will center the user to the middle of the screen
%        writeDigitalPin(mypi,6,1);
%    elseif centroids(:,1) < center_image(:,2)-cam_sensitivity
%        writeDigitalPin(mypi,5,1);
%    else
%    end
end %UNCOMMENT%