% INPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
%
% OUTPUT:
% --------
% XYZ : a Nx3 matrix, X = [0 .. 95.05  ], Y = [  0      .. 100     ], Z = [   0     .. 108.90  ]
%
% note: r,g,b denote values in [0..1] but still in companded lightness (CRT domain)
%       i.e. r=R/255 etc
%
% Conversion results are in line with :
% http://colormine.org/convert/RGB-to-xyz
function [XYZ] = RGBint_2_XYZ(RGBint)

[srgb] = RGBint_2_sRGB(RGBint);

% Linear map [0..1] to  [0..c], c ~ 1 (see later)
M = [0.4124  0.3576  0.1805 ;
     0.2126  0.7152  0.0722 ;
     0.0193  0.1192  0.9505  ];

%  Wide RGB D65 ? (Philips hue site)
% M = [0.664511  0.154324  0.162028 ;
%      0.283881  0.668433  0.047685 ;
%      0.000088  0.072310  0.986039  ];
 
X = srgb(:,1)*M(1,1) + srgb(:,2)*M(1,2) + srgb(:,3)*M(1,3);
Y = srgb(:,1)*M(2,1) + srgb(:,2)*M(2,2) + srgb(:,3)*M(2,3);
Z = srgb(:,1)*M(3,1) + srgb(:,2)*M(3,2) + srgb(:,3)*M(3,3);
% X,Y,Z unit scale until here ...

%% assign output XYZ xyY in proper scale
XYZ = 100*cat(2,X,Y,Z);

end