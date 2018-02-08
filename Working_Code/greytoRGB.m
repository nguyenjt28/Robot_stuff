function RGBimage = greytoRGB(IM)

    IM = uint8(IM);
    red_IM = cast(cat(3, IM, zeros(size(IM)), zeros(size(IM))), class(IM));
    green_IM = cast(cat(3, zeros(size(IM)), IM, zeros(size(IM))), class(IM));
    blue_IM = cast(cat(3, zeros(size(IM)), zeros(size(IM)), IM), class(IM));
    
    RGBimage = cat(3, red_IM(:,:,1), green_IM(:,:,2), blue_IM(:,:,3));


