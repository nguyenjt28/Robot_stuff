close all
clear all

% Note for 1st time use : 
% ======================
% Upon completed connection with the Hue-Bridge, you will get an appID, 
% stored to a mat file "userNameWQuotes.mat" for later use.
% Keep an eye to this newly generated file


% testType = 'AroundHues'; %SingleColors, AroundHues, None
% testType = 'SingleColors'; %SingleColors, AroundHues, None
testType = 'AroundHues_Fast'; %SingleColors, AroundHues, AroundHues_Fast, None
clc

addpath(genpath('PHUE_Connect'))

[urlLIGHT_State, lights_ALL_INFO, ErrCode, Hue_IP, AppID] = Philips_HUE_CONNECT(0);
urlLIGHT_First = urlLIGHT_State(1:end-5);

if strcmp(testType,'SingleColors')
    fprintf('\n TEST RED press a key to proceed\n'); pause()
    %% test Pure Red, OK
    [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, [255,0,0])
    pause(4); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);

    fprintf('\n TEST GREEN press a key to proceed\n'); pause()
    %% test Pure Green, OK
    [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, [0,255,0])
    pause(4); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);

    fprintf('\n TEST BLUE press a key to proceed\n'); pause()
    %% test Pure BLUE, OK
    [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, [0,0,255])
    pause(4); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);


    fprintf('\n TEST NAVY DARK BLUE press a key to proceed\n'); pause()
    [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, [0,0,128])
    pause(4); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);

    fprintf('\n TEST AQUA press a key to proceed\n'); pause()
    [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, [0,255,255])
    pause(4); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);
    
    % RGBint=[30,144,255]; %dodger Blue
    % [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, RGBint)

    % RGBint=[63,0,255]; %ultramarine Blue 
    % [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, RGBint)    
    
elseif  strcmp(testType,'AroundHues')

    fprintf('\n TEST Hues At max Brightness: press a key to proceed\n'); pause()
    H_VEC_in = (0:30:360); NN=length(H_VEC_in);
    
    Cnames={'red', 'orange', 'yellow', 'chartreuse', 'lime', 'SpringGreen',...
     'aqua/cyan', 'azure', 'blue', 'ElectricViolet', 'magenta', 'rose', 'red'};

    
    H_VEC_readB = zeros(1,NN);
    S=100;  B=100; 
    for ii = 1:NN    
        H = H_VEC_in(ii);
        if 0
            mode='direct'; %inaccurate blue ? Mostly yes. This mapping is HW dependent.
        else
            mode='convert'; %uses set_Lamp_RGB, Assuming Gamut and dedicated Matrix
%              H_VEC_in   = [0    30    60    90     120   150   180     210     240     270    300    330     360]            
%             H_VEC_readB = [0    6130  15291 22378  25600 30740 38388   44354   47089   48733  52917  59689     0

        end
        fprintf('\n ==> Sending this color : H=%d, name=%s\n',H,Cnames{ii});
        [ output,status,msgCharSent ] = set_Lamp_HSV(urlLIGHT_State, [H S B], mode);
        msgCharSent                
        pause(5); First_light_INFO = webread(urlLIGHT_First); %need to wait 3 to be sure it is updated
        H_readBack      = First_light_INFO.state.hue
        H_VEC_readB(ii) = H_readBack;
    end

    H_VEC_in
    H_VEC_readB    
    figure;plot(H_VEC_in,H_VEC_readB,'-o'); 
    xlabel('H  [DEG]'); ylabel('hue [hw]');
    title('if this curve is not nice, and convert mode, check your GAMUT in set-Lamp-RGB.m');
    
elseif  strcmp(testType,'AroundHues_Fast')
    fprintf('\n TEST MANY Hues At max Brightness: press a key to proceed\n'); pause()
    H_VEC_in = (0:5:359); NN=length(H_VEC_in);
    
    x_VEC_set = zeros(1,NN);
    y_VEC_set = zeros(1,NN);
    figure(87); hold on;
    axis equal
    axis([0 .8 0 .9])
    plot(1/3,1/3,'k*');
        
    set(gcf,'color',[1 1 1]);
    grid on;
    
    
    xlabel('x');ylabel('y');title('xy sent to Philips Hue; see default GAMUT in set-Lamp-RGB.m');
    load xy_1931_boundary
    xx = x./(x+y+z);
    yy = y./(x+y+z);
    plot([xx,xx(1)],[yy,yy(1)],'k');
    NS = 3;
    for iS = 1:NS
        S=round(100/(NS+1-iS));
        B=100; 
        for ii = 1:NN    
            H = H_VEC_in(ii);
            mode='convert'; %uses set_Lamp_RGB, Assuming Gamut and dedicated Matrix
            fprintf('\n ==> Sending this color : H=%d\n',H);
            [ output,status,msgCharSent,xy,RGBint] = set_Lamp_HSV(urlLIGHT_State, [H S B], mode);
            xSet = xy(1);
            ySet = xy(2);
            msgCharSent                
            pause(.0625); 
            plot(xSet,ySet,'o','color',RGBint/255,'markerfacecolor',RGBint/255);     
            if ~mod(H,120)
                text(xSet,ySet,sprintf('H=%2.0f,S=%d',H,S));
            end
            x_VEC_set(ii)   = xSet;
            y_VEC_set(ii)   = ySet;        
        end
    end        

end

msgChar         = sprintf('{"on":false}');
[output,status] = urlread2(urlLIGHT_State,'PUT',msgChar);

% ====================================================
% It seems that bri is similar to V of HSV, and remains unset when issueing an xy command
% ====================================================



