function CreateImages(DelayTime,ImageQuant,FileName,camera)

%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\Both Hands';
%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\Left Hand';
%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\Right Hand';
%savepath = 'C:\Users\Michael\Desktop\Transfer Learning Images\Data\No Hands';
savepath = strcat('C:\Users\Michael\Desktop\Transfer Learning Images\Data\',FileName);

%camera = webcam;

for i=0:DelayTime
    picture = camera.snapshot;
    Time=DelayTime-i;
    image(picture);
    title(sprintf('Time left: %s',int2str(Time)))
    drawnow;
end

for i=1:ImageQuant
    picture = camera.snapshot;
    picture = imresize(picture,[227,227]);
    image(picture);
    title(sprintf('Image Number: %s of %s',int2str(i), int2str(ImageQuant)))
    drawnow;
    filename=sprintf('image_%d.jpg',i);
    path=fullfile(savepath, filename);
    imwrite(picture,path);
end