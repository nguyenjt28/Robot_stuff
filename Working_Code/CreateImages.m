function CreateImages(DelayTime,ImageQuant,FileName,tcp,commands,savepath)

%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\Both Hands';
%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\Left Hand';
%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\Right Hand';
%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\No Hands';
savepath = strcat(savepath,FileName);

%camera = webcam;
tic
while toc<DelayTime
    vecphoto=fread(tcp,[227 227],'uint8');  %% Receives vectorized image from server
    cam_snap=reshape(vecphoto,227,227);  %% Reshapes vector into an array 
    cam_snap=uint8(cam_snap);  %% Changes type of array from double to uint8
    BW = image_Binarize(cam_snap);
    picture = BW;
    Time=DelayTime-toc;
    imshow(picture);
    title(sprintf('Time Remaining: %f Seconds',Time))
    drawnow;
    fwrite(tcp,commands);
end

for i=1:ImageQuant
    vecphoto=fread(tcp,[227 227],'uint8');  %% Receives vectorized image from server
    cam_snap=reshape(vecphoto,227,227);  %% Reshapes vector into an array 
    cam_snap=uint8(cam_snap);  %% Changes type of array from double to uint8

    BW = image_Binarize(cam_snap);
    BW = uint8(255*BW);
    BW = cat(3, BW, BW, BW);
    picture = BW;
    picture = imresize(picture,[227,227]);
    image(picture);
    title(sprintf('Image Number: %s of %s',int2str(i), int2str(ImageQuant)))
    drawnow;
    filename=sprintf('image_%d.jpg',i);
    path=fullfile(savepath, filename);
    imwrite(picture,path);
    fwrite(tcp,commands);
end