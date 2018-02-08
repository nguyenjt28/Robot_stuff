% ref: https://www.developers.meethue.com/documentation/supported-lights
% this is merely a test folder, export findings into RGBint_2_xy_Philips_Hue.
% 
% 1) get xy RGB primaries from https://www.developers.meethue.com/documentation/supported-lights 
% 2) Assume Y to complete xy into xyY
% 3) convert xyY to XYZ for each primary
% 4) put it in the columns of M : M = [X;Y;Z]/100
% 
% 
% -----------------------------------------------------------
% conversion chain :
% -----------------------------------------------------------
%                             95.047   ref D65 2° observer
%                             100
%                             108.883
%        2.4                    |              1/3
%         |                     v               |
% rgb -->(^)--> srgb --> XYZ ->(/)--> XYZ_1 ---(^)---> XYZ_1_gc --> Lab
%                         |
%                         v
%                        xyY  TARGET DEFINED HERE
% 
% Gamut A 
% Color  	        x       y
% Red              	0.704 	0.296
% Green            	0.2151 	0.7106
% Blue             	0.138 	0.08
%  
% Gamut B 
% Color  	        x       y
% Red 	           	0.675 	0.322
% Green 	      	0.409 	0.518
% Blue 	           	0.167 	0.04
%  
% Gamut C
% Color  	        x       y
% Red 	            0.692 	0.308
% Green 	        0.17 	0.7
% Blue 	            0.153 	0.048 

% And the 3rd variable Y is fixed as 
% Yr = 21.26;
% Yg = 71.52;
% Yb =  7.22;


clc
Yr = 21.26;
Yg = 71.52;
Yb =  7.22;

%% TARGET GAMUT TRIANGLE on X+Y+Z = 1

% GAMUT A
%  xyY_red   = [0.704,  0.296,  Yr];
%  xyY_green = [0.2151, 0.7106, Yg];
%  xyY_blue  = [0.138,  0.08,   Yb];
%  M = [0.505643243243243   0.216492428933296   0.124545000000000
%       0.212600000000000   0.715200000000000   0.072200000000000
%       0.000000000000000   0.074780973824937   0.705755000000000];

% GAMUT B
% xyY_red   = [0.675, 0.322, Yr];
% xyY_green = [0.409, 0.518, Yg];
% xyY_blue  = [0.167, 0.04,  Yb];
% M=[0.445667701863354   0.564704247104247   0.301435000000000
%    0.212600000000000   0.715200000000000   0.072200000000000
%    0.001980745341615   0.100790733590734   1.431365000000000];

%GAMUT C
xyY_red   = [0.692, 0.308,  Yr];
xyY_green = [0.17,    0.7,  Yg];
xyY_blue  = [0.153,  0.048, Yb];

M= [0.477659740259740   0.173691428571429   0.230137500000000
   0.212600000000000   0.715200000000000   0.072200000000000
   0.000000000000000   0.132822857142857   1.201829166666667];
   

[XYZ_TARGET_Red_Green_Blue_Per_Row]  = xyY_2_XYZ([xyY_red;xyY_green;xyY_blue]);

%using the DEFAULT matrix we get something very far from eye(3)
[~,srgb_TEST_Red_Green_Blue_Per_Row] = XYZ_2_RGBint(XYZ_TARGET_Red_Green_Blue_Per_Row)
eye(3)
% we want :   inv(M)*(XYZ.'/100) = eye(3)


% inv(M)*(XYZ.'/100) = eye(3)
% XYZ/100 = M

M = XYZ_TARGET_Red_Green_Blue_Per_Row.'/100

% copy this into rgb_2_xy_testV, and then into RGBint_2_xy_Philips_Hue.m
% M=[0.445667701863354   0.564704247104247   0.301435000000000
%    0.212600000000000   0.715200000000000   0.072200000000000
%    0.001980745341615   0.100790733590734   1.431365000000000];
      
       
%finally RETEST
xyY_red
xyY_green
xyY_blue

[xyR] = rgb_2_xy_testV([255 0 0])
[xyG] = rgb_2_xy_testV([0 255 0])
[xyB] = rgb_2_xy_testV([0 0 255])

