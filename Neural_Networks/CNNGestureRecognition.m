close all
clear all

clc

if(false) %Used for Hue Lights
addpath(genpath('PHUE_Connect'))

[urlLIGHT_State, lights_ALL_INFO, ErrCode, Hue_IP, AppID] = Philips_HUE_CONNECT(0);
urlLIGHT_First = urlLIGHT_State(1:end-5);

Light1=strcat(urlLIGHT_State(1:end-7),'1/state');
Light2=strcat(urlLIGHT_State(1:end-7),'2/state');
Light3=strcat(urlLIGHT_State(1:end-7),'3/state');
end

camera=webcam;
NG=0; %New Gesture Indicator

str=input('New Gesture (Y/N): ', 's');

while(strcmp(str,'Y'))
   NG=1; %Triggers Conditional at end of file to delete new gesture
   str=input('\nWhat is the name of new gesture?: ', 's');
   FileName=str;
   mkdir('C:\Users\Michael\Desktop\Transfer Learning Images\Data', FileName); %Change directory location accordingly for where training images should be saved
   fprintf(sprintf('\n Gesture ''%s'' Created\n', FileName))
   Delay=input('\nHow much delay time is required?: ');
   CreateImages(Delay,100,str,camera);  %(Delay - Time before photos are taken, Number of photos to be taken, Name of Gesture)
   
   str=input('\nWould you like to create another gesture? (Y/N): ', 's');
end

close(figure(1))
data = imageDatastore('Data',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

%[dataTrain,dataTest] = splitEachLabel(data,0.8);

dataTrain = shuffle(data);

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
% Determine the number of classes from the training data.
numClasses = numel(categories(dataTrain.Labels));

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
    'MaxEpochs',5,... %Determines number of iterations that will be performed
    'InitialLearnRate',0.0001); %Sets learning speed of new layers

netTransfer = trainNetwork(dataTrain,layers,options);

 confirmthresh=50;
 prevlabel='NULL';
 confirm=0;
 
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
if(NG) %Gives option to user to delete created gesture
str=input(sprintf('\nDelete Gesture ''%s'' (Y/N): ', FileName), 's');

if(strcmp(str,'Y'))
   [status,msg]=rmdir(strcat('\Users\Michael\Desktop\Transfer Learning Images\Data\', FileName), 's'); %Change directory location accordingly for where training images should be deleted
   fprintf(sprintf('\n''%s'' Deleted\n\n', FileName))
end
end
