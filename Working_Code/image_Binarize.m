%%%This function will read in the input image and filter out noise

function BW = image_Binarize(cam_snap)

    BW_Sensitivity = 0.04;                         %%%Black White Sensitivity Value
    level = graythresh(cam_snap)+BW_Sensitivity;
    
    BW = imbinarize(cam_snap,level);      %%%Binarizes cam_snap
    %sfigure(1); imshowpair(cam_snap,BW,'montage');
    
    se90 = strel('line',3,90);                  % out of while would be faster but harder to read
    se0 = strel('line',3,0);                    %Structuring elements
    BW = imerode(BW,[se90 se0]);                % imerode clears/erode noise/edges 
    BW = imdilate(BW,[se90 se0]);               % expand/dilate areas to reconnect things
    CCL = bwconncomp(BW);
    
    numPixels = cellfun(@numel,CCL.PixelIdxList);
    [largest_PixelGroup,idxL] = max(numPixels);          %biggest is largets # of pixels, idx is column number housing largest area
    
    BW = bwareaopen(BW,largest_PixelGroup);