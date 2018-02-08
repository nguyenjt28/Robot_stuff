% INPUT:
% --------
% XYZ   : a Nx3 matrix, X = [0 .. 95.05  ], Y = [  0      .. 100     ], Z = [   0     .. 108.90  ]
%
% OUTPUT:
% --------
% xyY : a Nx3 matrix, x = [0.15 .. 0.64], y = [  0.060  ..   0.600 ], Y = [   0     .. 100     ]
function [xyY] = XYZ_2_xyY(XYZ)

if size(XYZ,2) ~= 3
    error('each input row is expected to be one XYZ entry');
end


%% convert XYZ to xyY
% http://www.easyrgb.com/index.php?X=MATH&H=03#text3
X = XYZ(:,1);
Y = XYZ(:,2);
Z = XYZ(:,3);

x = X./(X+Y+Z);
y = Y./(X+Y+Z);

%set the white point also for black, which is now a NaN
idx0 = find(X+Y+Z==0);
x(idx0) = 0.3127159072216;
y(idx0) = 0.3290014805067;

xyY = cat(2,x,y,Y);

end
