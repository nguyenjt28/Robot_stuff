% INPUT:
% --------
% XYZ : a Nx3 matrix, X = [0 .. 95.05  ], Y = [  0      .. 100     ], Z = [   0     .. 108.90  ]
%
% OUTPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
% 
function [RGBint,srgb] = XYZ_2_RGBint(XYZ)

if size(XYZ,2) ~= 3
    error('each input row is expected to be one XYZ entry');
end

% http://www.easyrgb.com/index.php?X=MATH&H=01#text1
XYZ = XYZ/100;

% this is the inverse of the matrix used in RGBint_2_XYZ_xyY_LAB
invM =  [
   3.240625477320053  -1.537207972210319  -0.498628598698248
  -0.968930714729320   1.875756060885242   0.041517523842954
   0.055710120445511  -0.204021050598487   1.056995942254388   ];
% If you change this, you need to change all the corners , e.g in Lab too, else sliders are gone

% %wide D65 point, Philips hue site, https://developers.meethue.com/documentation/color-conversions-rgb-xy
% Bah ! Not quite
% invM = [
%    1.656493646740894  -0.354852231612697  -0.255037806749715
%   -0.707195833688164   1.655398667801136   0.036152567055389
%    0.051713531912103  -0.121365027825794   1.011530224669834 ];

% % this would do perfectly fine for BULB 3
% invM = [   3.538366774520371  -2.708045122027578  -0.608556679021184
%           -1.058845703962440   2.218595098033939   0.111076202572976
%            0.069663036162135  -0.152476747518143   0.691654430466916];
       
       

sr = XYZ(:,1)*invM(1,1) + XYZ(:,2)*invM(1,2) + XYZ(:,3)*invM(1,3);
sg = XYZ(:,1)*invM(2,1) + XYZ(:,2)*invM(2,2) + XYZ(:,3)*invM(2,3);
sb = XYZ(:,1)*invM(3,1) + XYZ(:,2)*invM(3,2) + XYZ(:,3)*invM(3,3);    

srgb   = cat(2,sr,sg,sb);

RGBint = srgb_2_RGBint(srgb);


end
