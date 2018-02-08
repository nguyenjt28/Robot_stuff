imaqreset;
rehash;

clc
clear
close all

%%%Raspberry Initialize
 mypi = raspi;

%%%Initialize Camera
  cam = videoinput('winvideo', 1,'YUY2_640x480');                                       %%%YUY2_640x480 for infrared sensor
  cam.FramesPerTrigger = 1;
  cam.ReturnedColorSpace = 'grayscale';
  triggerconfig(cam,'manual');
  start(cam);

%%%%Settings
gesture=zeros(1,4);                                                        %%%Number of gestures currently implemented
timebuffer = 0;
gesturetest = 1;
VBuffer = 50;                                                              %%%VBuffer is the difference in vertical pixels between extremeties
HBuffer = 50;                                                              %%%HBuffer is the difference in horizontal pixels between extremeties

 while(1)
 
   cam_snap = getsnapshot(cam);                   
   % cam_snap = imread('picR142.jpg');                                      %%%Use picture
    BW = image_Binarize(cam_snap);   
    %%%Binarizes the image
    
    [centroids, row1L, row2L, column1L, column2L] = draw_Rectangle(BW);    %%%Locates user and draws a rectangle
         
%    figure(2); imshow(BW);
   
        
    Lcheck = abs(centroids(1) - column1L);
    Rcheck = abs(centroids(1) - column2L);
    
    pointBOX = BW(row1L:row2L,column1L:column2L);
    point1L = find(pointBOX,1,'first')+row1L;                              %%%Extremity 1
    point2L = mod(find(pointBOX,1,'last'),(row2L-row1L+1))+row1L;          %%%Extremity 2
    
    if (sum(BW(:) == 1)/numel(BW))<0.8 || (column1L>11 && column2L<length(BW)-10)
        
    [RHU, LHU] = calc_Extremities(centroids, point1L, point2L, row1L, row2L, column1L, column2L, HBuffer);    %%%Determines if the right/left hand are up
                                                                                               
%     totalCheck = Lcheck - Rcheck;
%     if totalCheck > 10
%         motion = 'LEFT'
%     elseif totalCheck < -10
%         motion = 'RIGHT'
%     elseif totalCheck >= -10 && totalCheck <= 10
%         motion = 'CENTER'
%     end
%     
     adjacentL=abs(centroids(2)-point2L);
     oppositeL=abs(column2L-centroids(1));
     thetaL=atan(adjacentL/oppositeL)*180/pi;
     
     adjacentR=abs(centroids(2)-point1L);
     oppositeR=abs(column1L-centroids(1));
     thetaR=atan(adjacentR/oppositeR)*180/pi;
     
%%%GESTURES
    k = 1;                                                                 %%%k is a unique identifier for each gesture
    timebuffer = timebuffer + 1;
    if timebuffer == 100                                                   %%%This delay is a prevantive measure in accidental gesture recognition between gestures
        gesturetest = 1;
        timerbuffer = 0;                                                    %%%This test will be set to zero as soon as a gesture is recgonized to prevent other gestures from also triggering in the same iteration
    end

    if ((point2L-point1L) <= VBuffer) && (column2L-column1L)>=0.7*(row2L-row1L) && RHU==1 && LHU==1 && gesture(k)~=1%%%If extremeties are roughly on the same horizontal plane and extended horizontally from the centroid, gesture is recognized
        disp('BOTH HANDS')
        gesturetest=0;
        for i=1:length(gesture)                                            %%%This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
            if i~=k
                gesture(i)=0;
            else
                gesture(i)=1;
            end
        end
    end

    k=k+1;

    if ((point2L-point1L) <= VBuffer) && (column2L-column1L)<=0.2*(row2L-row1L) && gesture(k)~=1    %%%If extremeties are roughly on the same horizontal plane and extended vertically from the centroid, gesture is recognized
        disp('Gesture2')
        gesturetest=0;
        for i=1:length(gesture)                                            %%%This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
            if i~=k
                gesture(i)=0;
            else
                gesture(i)=1;
            end
        end
    end

    k=k+1;

    if (LHU == 1) && (RHU == 0) && (thetaL>=15 && thetaL<=35) && gesture(k)~=1 && (abs(thetaL-thetaR)>=10)    %%%If only (graphically) right hand is horizontal to centroid, gesture is recognized
        disp('RIGHT HAND')
        gesturetest=0;
        for i=1:length(gesture)                                            %%%This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
            if i~=k
                gesture(i)=0;
            else
                gesture(i)=1;
            end
        end
    end

    k=k+1; 

    if (RHU == 1) && (LHU == 0) && (thetaR>=15 && thetaR<=35) && gesture(k)~=1 && (abs(thetaL-thetaR)>=10) %%%If only (graphically) left hand is horizontal to centroid, gesture is recognized
        disp('LEFT HAND')
        gesturetest=0;
        for i=1:length(gesture)                                            %%%This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
            if i~=k
                gesture(i)=0;
            else
                gesture(i)=1;
            end
        end
    end

    % if ((LHU == 1) && (abs(centroids(2)-point1L) <= HBuffer) && (column2L-column1L)>=(3/8+1/4-0.1)*(row2L-row1L)) && gesturetest==1 && gesture(k)~=1%%%If only (graphically) left hand is horizontal to centroid, gesture is recognized
    %     disp('Gesture3')
    %     gesturetest=0;
    %     for i=1:length(gesture) %%%This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
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
    % if ((RHU == 1) && (abs(point2L-centroids(2)) <= HBuffer) && (column2L-column1L)>=(3/8+1/4-0.1)*(row2L-row1L)) && gesturetest==1 && gesture(k)~=1%%%If only (graphically) right hand is horizontal to centroid, gesture is recognized
    %     disp('Gesture4')
    %     gesturetest=0;
    %     for i=1:length(gesture) %%%This for loop makes it so that a gesture cannot be recognized twice in a row and should be added to every gesture
    %         if i~=k
    %             gesture(i)=0;
    %         else
    %             gesture(i)=1;
    %         end
    %     end
    % end



    cam_Tracking(cam_snap,mypi,centroids);
    end
 end 


    
  
