%HSV and HSB are the same thing (Value = Brightness)
%HSL has a different definition of both Saturation and Lightness
% 
% 
% note: r,g,b denote values in [0..1] but still in companded lightness (CRT domain)
%       i.e. r=R/255 etc
function [RGBint] = HSVpc_2_RGBint(HSVpc)

if size(HSVpc,2) ~= 3
    error('each input row is expected to be one HSV entry');
end

H = HSVpc(:,1);
S = HSVpc(:,2);  
V = HSVpc(:,3);  

% HSVpc is in 0..360, 0..100, 0..100, but keep precision
H = double(H) / 360;
S = double(S) / 100;
V = double(V) / 100;

[rgb] = hsv2rgb(H,S,V);

% scale up, keep precision, and get rid of singleton dimensions
RGBint = squeeze(rgb*255);

if size(RGBint,2)==1
    %one single color, convert to row
    RGBint=RGBint.';
end

RGBint = max(0,min(RGBint,255));