close all
clear all

% Note for 1st time use : 
% ======================
% Upon completed connection with the Hue-Bridge, you will get an appID, 
% stored to a mat file "userNameWQuotes.mat" for later use.
% Keep an eye to this newly generated file


% testType = 'AroundHues'; %SingleColors, AroundHues, None
% testType = 'SingleColors'; %SingleColors, AroundHues, None
%testType = 'AroundHues_Fast'; %SingleColors, AroundHues, AroundHues_Fast, None
clc

addpath(genpath('PHUE_Connect'))
 [urlLIGHT_State, lights_ALL_INFO, ErrCode, Hue_IP, AppID] = Philips_HUE_CONNECT(0);
 urlLIGHT_First = urlLIGHT_State(1:end-5);


while(1)
    
x=input('Enter Number: ');

switch x
    case 1
        set_Lamp_RGB(urlLIGHT_State, [255,0,0]);
    case 2
        set_Lamp_RGB(urlLIGHT_State, [0,255,0]);
    case 3
        set_Lamp_RGB(urlLIGHT_State, [0,0,255]);
    otherwise
        set_Lamp_RGB(urlLIGHT_State, [0,0,0]);
        return
end
end

camera = webcam;
nnet=alexnet;

set_Lamp_RGB(urlLIGHT_State, [0,0,0]);

confirm = 0;

% while true
%     picture = camera.snapshot;
%     picture = imresize(picture,[227,227]);
%     
%     label = classify(nnet, picture);
%     
%     image(picture);
%     title(char(label));
%     drawnow;
%     
%     if strcmp(char(label),'computer keyboard')
%         confirm=confirm+1
%         if confirm==20
%         set_Lamp_RGB(urlLIGHT_State, [255,0,0]);
%         return
%         end
%     end
%     
%     if strcmp(char(label),'computer keyboard') == 0
%         confirm=0;
%     end
% end


msgChar         = sprintf('{"on":false}');
[output,status] = urlread2(urlLIGHT_State,'PUT',msgChar);

