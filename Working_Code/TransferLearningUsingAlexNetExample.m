close all
clear all
%% Transfer Learning Using AlexNet
% Fine-tune a pretrained convolutional neural network to learn the features
% on a new collection of images.
%
% Transfer learning is commonly used in deep learning applications. You can
% take a pretrained network and use it as a starting point to learn a new
% task. Fine-tuning a network with transfer learning is much faster and
% easier than training from scratch. You can quickly transfer learning to a
% new task using a smaller number of training images.

camera=webcam;
NG=0; %New Gesture Indicator
%%
% Load the sample images as |ImageDatastore| objects.

str=input('New Gesture (Y/N): ', 's');

if(strcmp(str,'Y'))
   NG=1; %Triggers Conditional at end of file to delete new gesture
   str=input('What is the name of new gesture?: ', 's');
   FileName=str;
   mkdir('C:\Users\Michael\Desktop\Transfer Learning Images\Data', FileName);
   Delay=input('How much delay time is required?: ');
   CreateImages(Delay,100,str,camera);
end

close(figure(1))
data = imageDatastore('Data',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

%[dataTrain,dataTest] = splitEachLabel(data,0.8);

dataTrain = shuffle(data);


%%
% In the sample data, there are 64 training images and 16 test images.
% Display 20 sample images.
% figure
% for i = 1:20
%     subplot(4,5,i)
%     
%     I = readimage(dataTrain,i);
%     imshow(I)
%     drawnow
% end

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
    'MiniBatchSize',5,...
    'MaxEpochs',1,...
    'InitialLearnRate',0.0001);


%%
% Fine-tune the network using |trainNetwork| on the new layer array.
netTransfer = trainNetwork(dataTrain,layers,options);

%%
% Classify the test images using |classify|.
%predictedLabels = classify(netTransfer,dataTest);

%%
% Display four sample test images with their predicted labels.

% if(0)
% idx = [1 4 7 10];
% figure
% for i = 1:numel(idx)
%     subplot(2,2,i)
%     
%     I = readimage(dataTest,idx(i));
%     label = predictedLabels(idx(i));
%     
%     imshow(I)
%     title(char(label))
%     drawnow
% end
% 
% %%
% % Calculate the classification accuracy.
% testLabels = dataTest.Labels;
% 
% accuracy = sum(predictedLabels==testLabels)/numel(predictedLabels)
% 
% end

 confirmthresh=100;
 prevlabel='NULL';
 confirm=0;
 
for i=0:1000
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
      if strcmp(char(label),'Both Hands')
          
      end
      end
    else
      image(picture);
      drawnow;
      confirm=0;
    end

    
     prevlabel=label;
end
%%
% This example has high accuracy. If the accuracy is not high enough using
% transfer learning, try feature extraction instead.
close(figure(1))
if(NG)
str=input('Delete Newest Gesture (Y/N): ', 's');

if(strcmp(str,'Y'))
   [status,msg]=rmdir(strcat('\Users\Michael\Desktop\Transfer Learning Images\Data\', FileName), 's');
   disp('Folder Deleted')
end
end
