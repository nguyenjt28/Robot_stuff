% INPUT:
% --------
% xyY : a Nx3 matrix, x = [0.15 .. 0.64], y = [  0.060  ..   0.600 ], Y = [   0     .. 100     ]
%
% OUTPUT:
% --------
% XYZ   : a Nx3 matrix, X = [0 .. 95.05  ], Y = [  0      .. 100     ], Z = [   0     .. 108.90  ]
function [XYZ] = xyY_2_XYZ(xyY)

if size(xyY,2) ~= 3
    error('each input row is expected to be one xyY entry');
end

% xyY to XYZ
% http://www.easyrgb.com/index.php?X=MATH&H=04#text4
% http://www.poynton.com/notes/Timo/colorspace-faq, section 8.3
% Y from 0 to 100
% x from 0 to 1
% y from 0 to 1
x = xyY(:,1);
y = xyY(:,2);
Y = xyY(:,3);
X = x .* ( Y ./ y );
Z = ( 1 - x - y ) .* ( Y ./ y );

XYZ    = cat(2,X,Y,Z);

end
