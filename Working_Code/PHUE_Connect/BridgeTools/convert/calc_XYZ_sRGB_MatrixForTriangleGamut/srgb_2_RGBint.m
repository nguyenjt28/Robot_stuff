% INPUT:
% --------
% srgb : a Nx3 matrix, [0..1]
%
% OUTPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
% 
function RGBint = srgb_2_RGBint(srgb)

if size(srgb,2) ~= 3
    error('each input row is expected to be one XYZ entry');
end



ThrLin2Gamma = 0.0031308;
indexGamma  = find(srgb >  ThrLin2Gamma);
indexLinear = find(srgb <= ThrLin2Gamma);

RGB = zeros(size(srgb));
RGB(indexGamma)  = 1.055 * srgb(indexGamma).^(1/2.4) - 0.055;
RGB(indexLinear) = 12.92 * srgb(indexLinear);

RGBint = RGB*255; %keep precision

% RGBint = max(0,min(RGBint,255)); % don't let clipping be detected
end
