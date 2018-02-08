%HSV and HSB are the same thing (Value = Brightness)
%HSL has a different definition of both Saturation and Lightness
%
% INPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
% 
% OUTPUT:
% --------
% HSVpc : a Nx3 matrix, H=0..360, S=0..100, V=0..100  (pc = per-cent)
% HSLpc : a Nx3 matrix, H=0..360, S=0..100, L=0..100  (pc = per-cent)
% 
% note: r,g,b denote values in [0..1] but still in companded lightness (CRT domain)
%       i.e. r=R/255 etc
function [HSVpc, HSLpc] = RGBint_2_HSVpc_HSLpc(RGBint)

if size(RGBint,2) ~= 3
    error('each input row is expected to be one RGB entry');
end
if (max(max(RGBint))) > 256
    error('RGB values out of range');
end


% extract channels
% A colormap has values on [0,1], while a uint8 image has values on [0,255]. This is what rgb2hsv expects
% RGBintis in 0..255, keep precision
r = double(RGBint(:,1)) / 255;
g = double(RGBint(:,2)) / 255;
b = double(RGBint(:,3)) / 255;

[hsv] = rgb2hsv(r,g,b);

%HSV to HSL (http://codeitdown.com/hsl-hsb-hsv-color/)
H       = hsv(:,1);
S       = hsv(:,2);
V       = hsv(:,3);
L       = 0.5.*V.*(2-S) ;
S_HSL   = V.*S./(1-abs(2*L-1));

S_HSL(abs(2*L-1)==1) = 0;

%prevent 100+eps or 0-eps to appear
H = max(0,min(H,1));
S = max(0,min(S,1));
S_HSL = max(0,min(S_HSL,1));
V = max(0,min(V,1));
L = max(0,min(L,1));

% keep precision
HSVpc = cat(2,360*H,100*S,     100*V);
HSLpc = cat(2,360*H,100*S_HSL, 100*L);



