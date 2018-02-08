%Ensure CreateImages function script is in same directory as this script

close all
clear all

clc

savepath=cd;

if(false) %Used for Hue Lights
addpath(genpath('PHUE_Connect'))

[urlLIGHT_State, lights_ALL_INFO, ErrCode, Hue_IP, AppID] = Philips_HUE_CONNECT(0);
urlLIGHT_First = urlLIGHT_State(1:end-5);

Light1=strcat(urlLIGHT_State(1:end-7),'1/state');
Light2=strcat(urlLIGHT_State(1:end-7),'2/state');
Light3=strcat(urlLIGHT_State(1:end-7),'3/state');
end

try cd Data
    cd ..
    savepath=strcat(savepath,'\Data\');
catch
     mkdir(savepath, 'Data'); %Create a new directory called 'Data' in current directory to store images
     savepath=strcat(savepath,'\Data\');
     fprintf('\n%s Created\n\n',savepath(1:end-1))
end

pause(0.5)

camera=webcam;
NG=0; %New Gesture Indicator

str=input('New Gesture (Y/N): ', 's');

while(strcmp(str,'Y'))
   NG=NG+1; %Triggers Conditional at end of file to delete new gesture
   str=input('\nWhat is the name of new gesture?: ', 's');
   FileName(1,NG)=string(str);
   mkdir(savepath, char(FileName(1,NG))); %Change directory location accordingly for where training images should be saved
   fprintf(sprintf('\nGesture ''%s'' Created\n', char(FileName(1,NG))))
   Delay=input('\nHow much delay time (seconds) is required?: ');
   CreateImages(Delay,100,str,camera);  %(Delay - Time before photos are taken, Number of photos to be taken, Name of Gesture)
   close(figure(1))
   str=input('\nCapture complete! Would you like to create another gesture? (Y/N): ', 's');
end

%%
% Determine the number of classes from the training data.
data = imageDatastore('Data',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

dataTrain = shuffle(data);

numClasses = numel(categories(dataTrain.Labels));

%%
count=0;
if mod(numClasses,2)==1
    even=numClasses+1;
    n=even;
    while n>1
        count=count+1;
        n=n/2;
    end
    x=count;
    y=even/count;
else
    even=numClasses;
    n=even;
    while n>1
        count=count+1;
        n=n/2;
    end
    x=count;
    y=even/count;
end

figure(2)
for i = 1:numClasses
    subplot(x,y,i)
    index=(i-1)*100+randi([1,99],[1,1]);  %Generates a random photo index for each iteration
    I = readimage(data,index);
    imshow(I)
    label=data.Labels(index);
    title(char(label))
    drawnow
end

%%
% Load a pretrained AlexNet network.
net = alexnet;

%%
% The last three layers of the pretrained network |net| are configured for
% 1000 classes. These three layers must be fine-tuned for the new
% classification problem. Extract all the layers except the last three from
% the pretrained network, |net|.
layersTransfer = net.Layers(1:end-3);

%%
% Transfer the layers to the new task by replacing the last three layers
% with a fully connected layer, a softmax layer, and a classification
% output layer. Specify the options of the new fully connected layer
% according to the new data. Set the fully connected layer to be of the
% same size as the number of classes in the new data. To speed up training,
% also increase |'WeightLearnRateFactor'| and |'BiasLearnRateFactor'|
% values in the fully connected layer.

%%
% Create the layer array by combining the transferred layers with the new
% layers.
layers = [...
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%%
% If the training images differ in size from the image input layer, then
% you must resize or crop the image data. The images in |merchImages| are
% the same size as the input size of AlexNet, so you do not need to resize
% or crop the new image data.

%%
% Create the training options. For transfer learning, you want to keep the
% features from the early layers of the pretrained network (the transferred
% layer weights). Set |'InitialLearnRate'| to a low value. This low initial
% learn rate slows down learning on the transferred layers. In the previous
% step, you set the learn rate factors for the fully connected layer higher
% to speed up learning on the new final layers. This combination results in
% fast learning only on the new layers, while keeping the other layers
% fixed. When performing transfer learning, you do not need to train for as
% many epochs. To speed up training, you can reduce the value of the
% |'MaxEpochs'| name-value pair argument in the call to |trainingOptions|.
% To reduce memory usage, reduce |'MiniBatchSize'|.

options = trainingOptions('sgdm',...
    'MiniBatchSize',5,...  %This is used to test accuracy of images. The number declared here will determine number of images tested against the network
    'MaxEpochs',1,... %Determines number of iterations that will be performed
    'InitialLearnRate',0.0001); %Sets learning speed of new layers

netTransfer = trainNetwork(dataTrain,layers,options);

 confirmthresh=50;
 prevlabel='NULL';
 confirm=0;
 
figure(1)
for i=0:100 %Amount of time webcam will record
    picture = camera.snapshot;
    picture = imresize(picture,[227,227]);
    
    label = classify(netTransfer, picture);
   
    if strcmp(char(label),char(prevlabel))
      confirm=confirm+1;
      if confirm < confirmthresh
      image(picture);
      percent=confirm/confirmthresh*100;
      title(sprintf('Confirming: %s%%',int2str(percent)));
      drawnow;
      end
      if confirm>=confirmthresh
      image(picture);
      title(char(label));
      drawnow;
      if strcmp(char(label),'Red Light Trigger')
          %set_Lamp_RGB(Light3, [255,0,0]);  %Set Hue Light Color
      end
      end
    else
      image(picture);
      drawnow;
      confirm=0;
    end
    
     prevlabel=label;
end

close(figure(1))

while(NG>=1) %Gives option to user to delete created gesture
str=input(sprintf('\nDelete Gesture ''%s'' (Y/N): ', char(FileName(1,NG))), 's');

if(strcmp(str,'Y'))
   [status,msg]=rmdir(strcat(savepath, char(FileName(1,NG))), 's'); %Change directory location accordingly for where training images should be deleted
   fprintf(sprintf('\n''%s'' Deleted\n\n', char(FileName(1,NG))))
end
NG=NG-1;
end

close(figure(2))
