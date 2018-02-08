%HSV and HSB are the same thing (Value = Brightness)
%HSL has a different definition of both Saturation and Lightness
% 
% 
% note: r,g,b denote values in [0..1] but still in companded lightness (CRT domain)
%       i.e. r=R/255 etc
function [RGBint] = HSLpc_2_RGBint(HSLpc)

if size(HSLpc,2) ~= 3
    error('each input row is expected to be one HSL entry');
end

H = HSLpc(:,1);
S = HSLpc(:,2);  
L = HSLpc(:,3);  

% HSV is in 0..360, 0..100, 0..100, but keep precision
H     = double(H) / 360;
S_HSL = double(S) / 100;
L     = double(L) / 100;

% L =  max(0.000001, min(0.999999,L)); %prevent loss of Hue and Saturation: don't

%from HSL to HSV(B) (http://codeitdown.com/hsl-hsb-hsv-color/)
V       = L + S_HSL.*(1-abs(2*L-1))/2;
S_HSV   = 2*(V-L)./V;
S_HSV(V==0) = 0;

% HSV 2 rgb in [0 1]
[rgb] = hsv2rgb(H,S_HSV,V);

% scale up, keep precision, and get rid of singleton dimensions
RGBint = squeeze(rgb*255);

if size(RGBint,2)==1
    %one single color, convert to row
    RGBint=RGBint.';
end

RGBint = max(0,min(RGBint,255));
