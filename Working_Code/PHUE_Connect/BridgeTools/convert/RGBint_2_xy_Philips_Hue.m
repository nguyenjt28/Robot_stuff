% Converts RGB int to xy using a dedicated gamut for a specific PhilipsHue Lamp.
% 
% This method uses a dedicated sRGB to XYZ matrix M that matches the xy
% plane for a given triangle gamut (RGB primaries in HW xyY space).
% 
% Such matching is based on the idea that the three corners of the PHUE
% gamut in xy should be stretched to the position of the RGB primaries to
% maximize the coverage of the color space. For this reason an ad hoc
% matrix M is used between sRGB and XYZ
% 
% INPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
% GAMUT : A,B,C
% ref: https://www.developers.meethue.com/documentation/supported-lights 
% 
% OUTPUT:
% --------
% xy : a Nx2 matrix, x = [0.15 .. 0.64], y = [  0.060  ..   0.600 ]
% Y is omitted, can be set with 'bri' but then using L from HSL
%
% Notes:
% ------
% 
% Matrix determination, see calc_PhilipsHue_XYZ_sRGB_Matrix.m
% 1) get xy RGB primaries from https://www.developers.meethue.com/documentation/supported-lights 
% 2) Assume Y to complete xy into xyY
% 3) convert xyY to XYZ for each primary
% 4) put it in the columns of M : M = [X;Y;Z]/100
% 
% 
% RGB XY etc conversion chain :   XYZ_1 is normalized to X,Y,Z of D65
% -----------------------------------------------------------
%        2.4                          |D65           1/3
%         |                           v               |
% rgb -->(^)--> srgb <-- M --> XYZ ->(/)--> XYZ_1 ---(^)---> XYZ_1_gc --> Lab
%                |               |
%             EYE(3)             v
%                               xyY  TRIANGLE GAMUT HERE
% -----------------------------------------------------------
% 
% Gamut A 
% Color  	        x       y        Y
% Red              	0.704 	0.296    Yr
% Green            	0.2151 	0.7106   Yg
% Blue             	0.138 	0.08     Yb
%  
% Gamut B 
% Color  	        x       y        Y
% Red 	           	0.675 	0.322    Yr
% Green 	      	0.409 	0.518    Yg
% Blue 	           	0.167 	0.04     Yb
%  
% Gamut C
% Color  	        x       y        Y
% Red 	            0.692 	0.308    Yr
% Green 	        0.17 	0.7      Yg
% Blue 	            0.153 	0.048    Yb
% 
% And the 3rd variable Y is fixed as 
% Yr = 21.26;
% Yg = 71.52;
% Yb =  7.22;
% 
% -----------------------------------------------------------
% EXAMPLES :
% [xy] = RGBint_2_xy_Philips_Hue([255,0,0], 'C')
% xy =    0.6920    0.3080
% [xy] = RGBint_2_xy_Philips_Hue([0,255,0], 'C')
% xy =    0.1700    0.7000
% [xy] = RGBint_2_xy_Philips_Hue([0,0,255], 'C')
% xy =    0.1530    0.0480
% -----------------------------------------------------------
% note: From 3D to 2D is possible, viceversa not, 
% so no function xy_PHUE_2_RGB implemented, would be some
% surface in RGB space.
% -----------------------------------------------------------
% Massimo Ciacci, 2017-07-02
function [xy] = RGBint_2_xy_Philips_Hue(RGBint, GAMUT)

if nargin < 3
    GAMUT = 'C'; % Lightstrip PLUS
end
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

%% DEDICATED MATRIX FOR A CERTAIN TRIANGLE IN xy (Lamp dependent)
% =======================================================
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
% Linear map [0..1] to  [0..c], c ~ 1

if strcmp(GAMUT,'A')
    % GAMUT A
    M = [0.505643243243243   0.216492428933296   0.124545000000000
         0.212600000000000   0.715200000000000   0.072200000000000
         0.000000000000000   0.074780973824937   0.705755000000000];
elseif strcmp(GAMUT,'B')
    % GAMUT B
    M=[0.445667701863354   0.564704247104247   0.301435000000000
       0.212600000000000   0.715200000000000   0.072200000000000
       0.001980745341615   0.100790733590734   1.431365000000000];
elseif strcmp(GAMUT,'C')
    % %GAMUT C
    M= [0.477659740259740   0.173691428571429   0.230137500000000
        0.212600000000000   0.715200000000000   0.072200000000000
        0.000000000000000   0.132822857142857   1.201829166666667];
else
    error('Define this matrix with "calc_PhilipsHue_XYZ_sRGB_Matrix.m" using xy primaries');
end

% apply matrix [X;Y;Z] = M*[Sr;Sg;Sb]
X = srgb(:,1)*M(1,1) + srgb(:,2)*M(1,2) + srgb(:,3)*M(1,3);
Y = srgb(:,1)*M(2,1) + srgb(:,2)*M(2,2) + srgb(:,3)*M(2,3);
Z = srgb(:,1)*M(3,1) + srgb(:,2)*M(3,2) + srgb(:,3)*M(3,3);
% X,Y,Z approx unit scale until here ...

% %% assign output XYZ xyY in proper scale
% % XYZ = 100*cat(2,X,Y,Z);

x = X./(X+Y+Z);
y = Y./(X+Y+Z);

idx0    = find(X+Y+Z==0);
x(idx0) = 0.3127159072216;
y(idx0) = 0.3290014805067;

xy = cat(2,x,y);

end