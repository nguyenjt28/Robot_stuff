function [ output,status,msgCharSent,xy ] = set_Lamp_RGB(urlLIGHT_State, RGBint, GAMUT)
%SET_LAMP_RGB Summary of this function goes here
%     Changes color of lamp using RGB triplet in [0..255].
%     GAMUT: A,B,C: depends on what lamp you have, ref: https://www.developers.meethue.com/documentation/supported-lights 
%     
% INPUTS: 
% - urlLIGHT_State : The Url of the lamp we want to drive, 
%               e.g.
%                    IP | whiteListName | LightNumber
%               more precisely :
%                    http://IP/api/whiteListName/lights/LightNumber/state
%                    http://192.168.1.104/api/NgQcTIB9fXENwXXX2Hgmd6W2ilYYYUSgRrB46KN/lights/3/state
% 
% - RGBint : A triplet in [0..255], the standard RGB color
% - GAMUT : A,B,C
%   ref: https://www.developers.meethue.com/documentation/supported-lights 
% 
% approach (this does not claim to be the most exact route, but I tried my real best)
% ===================================================================================
% (1) use th xy route, with dedicated matrix sRGB <---> XYZ that matches triangle primaries RGB in xy
% (2) Fix the brightness from HSV/HSB (V)
% -----------------------------------------------------------
% (1) RGBint_2_xy_Philips_Hue : 
% RGB XY etc conversion chain :   XYZ_1 is normalized to X,Y,Z of D65
% -----------------------------------------------------------
%        2.4                          |D65           1/3
%         |                           v               |
% rgb -->(^)--> srgb <-- M --> XYZ ->(/)--> XYZ_1 ---(^)---> XYZ_1_gc --> Lab
%                |               |
%             EYE(3)             v
%                               xyY  TRIANGLE GAMUT HERE
% -----------------------------------------------------------
% Massimo Ciacci, 2017-07-02
% 
if nargin < 3
    GAMUT = 'C'; % Lightstrip PLUS
end

[xy]            = RGBint_2_xy_Philips_Hue(RGBint, GAMUT);

% % %keep track of the conversion in a dedicated plot, to test GAMUTS
% % figure(555); hold on;
% % plot(xy(1),xy(2),'.');

%now fix the brightness too
[HSVpc, HSLpc] = RGBint_2_HSVpc_HSLpc(RGBint);

B = HSVpc(3); %this would be the correct one I guess ? But if you find it too bright with aqua...
% B = HSLpc(3); %use this instead ? ...

bri            = min(254,max(0, round(B/100*254)));

if bri > 0
    msgCharSent     = sprintf('{"on":true, "xy":[%3.3f,%3.3f], "bri":%d}',xy(1),xy(2),bri);
else
    msgCharSent     = sprintf('{"on":false, "xy":[%3.3f,%3.3f], "bri":%d}',xy(1),xy(2),bri);
end
[output,status] = urlread2(urlLIGHT_State,'PUT',msgCharSent);


% -- Note, why need to fix brightness too --
% % %since xy is a 2D color space we cannot set the brightness with it, 
% % %in fact the xy plane is the outer shell of the RGB cube, i.e. points with value = 1. 
% % %So, let's try an experiment.
% % 
% % RGBint          = [100, 0, 0]; % a very dark RED, L=19.6 (from HSL); 19.6/100*255 = 50
% % [xy]            = RGBint_2_xy_Philips_Hue(RGBint);
% % msgCharSent     = sprintf('{"on":true, "xy":[%3.3f,%3.3f]}',xy(1),xy(2));
% % [output,status] = urlread2(urlLIGHT_State,'PUT',msgCharSent);
% % pause(3); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);
% % % brightness remained 128, unaltered.. of course.

% [ output,status, msgCharSent ] = set_Lamp_RGB(urlLIGHT_State, [100,0,0])
% urlLIGHT_First = urlLIGHT_State(1:end-5);
% pause(3); First_light_INFO = webread(urlLIGHT_First); expstruc(First_light_INFO);


% Old Attempt: Don't
% =================
% use the HSL route, quite inaccurate..
% [HSVpc, HSLpc] = RGBint_2_HSVpc_HSLpc(RGBint);
% Hue_MAX = 65535; Sat_MAX = 254; Bri_Max = 254;
% hue = round(HSLpc(1)/360*Hue_MAX);
% sat = round(HSLpc(2)/100*Sat_MAX);
% bri = round(HSLpc(3)/100*Bri_Max);
% msgCharSent     = sprintf('{"on":true, "sat":%d, "bri":%d, "hue":%d}',sat,bri,hue);
% [output,status] = urlread2(urlLIGHT_State,'PUT',msgCharSent);


end

