function [ output,status,msgCharSent, xy, RGBint ] = set_Lamp_HSV(urlLIGHT_State, HSVpc, mode, GAMUT)
%SET_LAMP_HSL 
%     Changes color of lamp using HSV
%     - HSV  = triplet in [0..360],[0..100],[0..100] 
%     - mode = direct | convert
%            direct:  ignores hw color mappings and maps hues linearly : 0-65535 onto [0-360]
%            convert: uses the provided GAMUT and resorts to set_Lamp_RGB, after internal conversion.
%     - GAMUT, only used in mode = convert
%
% INPUTS:
% - urlLIGHT_State : The Url of the lamp we want to drive,
%               e.g.
%                    IP | whiteListName | LightNumber
%               more precisely :
%                    http://IP/api/whiteListName/lights/LightNumber/state
%                    http://192.168.1.104/api/NgQcTIB9fXENwXXX2Hgmd6W2ilYYYUSgRrB46KN/lights/3/state
%
% - HSVpc : A triplet in [0..360],[0..100],[0..100], the standard HSL definition
%
% OUTPUTS: example
% ==========
% output =
% [{"success":{"/lights/3/state/on":false}}]
% 
% status = 
% 
%       allHeaders: [1x1 struct]
%     firstHeaders: [1x1 struct]
%           status: [1x1 struct]
%              url: 'http://192.168.1.100/api/xxx/lights/3/state'
%           isGood: 1
% 
% msgCharSent =
% {"on":true, "xy":[0.692,0.308], "bri":254}
% 
% Massimo Ciacci, 2017-11-12
% 
if nargin < 3
    mode = 'convert'; %need HW xy ref triangle points, set_Lamp_RGB will take care of that
end
if nargin < 4
    GAMUT = 'C';
end

if strcmp(mode,'direct')
    % the HSL route is quite inaccurate.. don't expect H to match that of HSL 
    Hue_MAX = 65535; Sat_MAX = 254; Bri_Max = 254;
    hue = round(HSVpc(1)/360*Hue_MAX);
    sat = round(HSVpc(2)/100*Sat_MAX);
    bri = round(HSVpc(3)/100*Bri_Max);
    msgCharSent     = sprintf('{"on":true, "sat":%d, "bri":%d, "hue":%d}',sat,bri,hue);
    [output,status] = urlread2(urlLIGHT_State,'PUT',msgCharSent);
    xy=[]; RGBint=[];
else
    %therefore we can wish to do this instead, B=V
    
    RGBint = HSVpc_2_RGBint(HSVpc); %note: here we cant use HSLpc_2_RGB else L=100=white !!
    [ output,status, msgCharSent, xy] = set_Lamp_RGB(urlLIGHT_State, RGBint, GAMUT);
end

end

