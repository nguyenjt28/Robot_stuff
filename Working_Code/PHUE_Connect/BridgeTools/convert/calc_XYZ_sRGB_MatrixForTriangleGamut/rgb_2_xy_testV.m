% INPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
%
% OUTPUT:
% --------
% xy : a Nx3 matrix, 
%
function [xy] = rgb_2_xy_testV(RGBint)

% [srgb] = RGBint_2_sRGB(RGBint);
%scale to [0..1]
rgb = RGBint/255;

%% convert rgb to XYZ
% Input RGB is companded, needs first to go to linear RGB (median ^2.24 gamma), usually named "rgb uncompanding"
% such uncompanding is linear below a threshold and exponential above it
% convert rgb to linear lighness srgb: https://en.wikipedia.org/wiki/SRGB

% http://www.easyrgb.com/index.php?X=MATH&H=02#text2
ThrLin2Gamma    = 0.04045;
idxGamma        = find(rgb >  ThrLin2Gamma);
idxLinear       = find(rgb <= ThrLin2Gamma);

% Gamma uncompand
srgb            = zeros(size(rgb));
srgb(idxGamma)  = ((rgb(idxGamma) + 0.055) / 1.055).^2.4;
srgb(idxLinear) = rgb(idxLinear) / 12.92;


% see calc_PhilipsHue_XYZ_sRGB_Matrix.m for matrix M, e.g. 
% =======================================================
% % Yr = 21.26;
% % Yg = 71.52;
% % Yb =  7.22;
% % % Reference Triangle
% % xyY_red   = [0.675, 0.322, Yr];
% % xyY_green = [0.409, 0.518, Yg];
% % xyY_blue  = [0.167, 0.04,  Yb];
% % [XYZ_TARGET_Red_Green_Blue_Per_Row]  = xyY_2_XYZ([xyY_red;xyY_green;xyY_blue]);
% % % we want :   inv(M)*(XYZ.'/100) = eye(3)
% % M = XYZ_TARGET_Red_Green_Blue_Per_Row.'/100
% =======================================================


% Linear map [0..1] to  [0..c], c ~ 1 (see later)

% GAMUT A
%  M = [0.505643243243243   0.216492428933296   0.124545000000000
%       0.212600000000000   0.715200000000000   0.072200000000000
%       0.000000000000000   0.074780973824937   0.705755000000000];
  
% %GAMUT B
% M=[0.445667701863354   0.564704247104247   0.301435000000000
%    0.212600000000000   0.715200000000000   0.072200000000000
%    0.001980745341615   0.100790733590734   1.431365000000000];
       
% %GAMUT C
M= [0.477659740259740   0.173691428571429   0.230137500000000
   0.212600000000000   0.715200000000000   0.072200000000000
   0.000000000000000   0.132822857142857   1.201829166666667];

X = srgb(:,1)*M(1,1) + srgb(:,2)*M(1,2) + srgb(:,3)*M(1,3);
Y = srgb(:,1)*M(2,1) + srgb(:,2)*M(2,2) + srgb(:,3)*M(2,3);
Z = srgb(:,1)*M(3,1) + srgb(:,2)*M(3,2) + srgb(:,3)*M(3,3);
% X,Y,Z unit scale until here ...

% %% assign output XYZ xyY in proper scale
% % XYZ = 100*cat(2,X,Y,Z);

x = X./(X+Y+Z);
y = Y./(X+Y+Z);

idx0    = find(X+Y+Z==0);
x(idx0) = 0.3127159072216;
y(idx0) = 0.3290014805067;

xy = cat(2,x,y);

end