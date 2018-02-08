close all

tcp = tcpip('172.23.37.97', 30000, 'NetworkRole', 'client');
set(tcp,'InputBufferSize',83700);
set(tcp,'Timeout',30);
fopen(tcp);

gesture=zeros(1,5);                                                        %%%Number of gestures currently implemented
timebuffer = 0;
gesturetest = 1;
VBuffer = 50;                                                              %%%VBuffer is the difference in vertical pixels between extremeties
HBuffer = 70;    
commands = zeros(1,7);

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

NG=0; %New Gesture Indicator

str=input('New Gesture (Y/N): ', 's');

while(strcmp(str,'Y'))
   NG=NG+1; %Triggers Conditional at end of file to delete new gesture
   str=input('\nWhat is the name of new gesture?: ', 's');
   FileName(1,NG)=string(str);
   mkdir(savepath, char(FileName(1,NG))); %Change directory location accordingly for where training images should be saved
   sprintf('\nGesture ''%s'' Created\n', char(FileName(1,NG)));
   fprintf(sprintf('\nGesture ''%s'' Created\n', char(FileName(1,NG))))
   Delay=input('\nHow much delay time (seconds) is required?: ');
   CreateImages(Delay,100,str,tcp,commands,savepath);  %(Delay - Time before photos are taken, Number of photos to be taken, Name of Gesture)
   close(figure(1))
   str=input('\nCapture complete! Would you like to create another gesture? (Y/N): ', 's');
   fwrite(tcp,commands);
end

temp = 0;
%%
% Determine the number of classes from the training data.
data = imageDatastore('Data',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

dataTrain = shuffle(data);

numClasses = numel(categories(dataTrain.Labels));

%%
% count=0;
% if mod(numClasses,2)==1
%     even=numClasses+1;
%     n=even;
%     while n>1
%         count=count+1;
%         n=n/2;
%     end
%     x=count;
%     y=even/count;
% else
%     even=numClasses;
%     n=even;
%     while n>1
%         count=count+1;
%         n=n/2;
%     end
%     x=count;
%     y=even/count;
% end
% 
% figure(2)
% for i = 1:numClasses
%     subplot(x,y,i)
%     index=(i-1)*100+randi([1,99],[1,1]);  %Generates a random photo index for each iteration
%     I = readimage(data,index);
%     imshow(I)
%     label=data.Labels(index);
%     title(char(label))
%     drawnow
% end

%%
if (NG > 0)
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
        'MiniBatchSize',15,...  %This is used to test accuracy of images. The number declared here will determine number of images tested against the network
        'MaxEpochs',5,... %Determines number of iterations that will be performed
        'InitialLearnRate',0.0001,... %Sets learning speed of new layers
        'Plots','training-progress'); 
        
    netTransfer = trainNetwork(dataTrain,layers,options);

end

inputSize = netTransfer.Layers(1).InputSize(1:2);
confirmthresh=10;
prevlabel='NULL';
confirm=0;
 
close(figure(2))

while(1)
    vecphoto=fread(tcp,[227 227],'uint8');  %% Receives vectorized image from server
    cam_snap=reshape(vecphoto,227,227);  %% Reshapes vector into an array 
    cam_snap=uint8(cam_snap);  %% Changes type of array from double to uint8

    BW = image_Binarize(cam_snap);
    BW_Train=BW*255;
    BW_Train=uint8(BW_Train);
    BW_Train = cat(3, BW_Train, BW_Train, BW_Train);
    cam_snap = cat(3, cam_snap, cam_snap, cam_snap);
    [centroids, row1L, row2L, column1L, column2L, wL, hL] = draw_Rectangle(BW);

    sfigure(1);      imshow(BW); 
    hold on;
    rectangle('Position',[column1L row1L wL hL],'EdgeColor','r','LineStyle','-.','LineWidth',1.5);
    plot(centroids(:,1), centroids(:,2), '+r', 'MarkerSize',10);           %%%Mass Centroid
    hold off;
    
    h = sfigure(2);
    picture = BW_Train;
    picture = uint8(picture);
    [label, score] = classify(netTransfer, picture);
    
    ax1 = subplot(1,2,1);
    ax2 = subplot(1,2,2);
    ax2.ActivePositionProperty = 'position'
    
    if (temp < 1)
        %               h = figure(4);
        h.Position(3) =   2*h.Position(3);
        temp = temp + 1;
    end
    
    % Select the top five predictions
    [~,idx] = sort(score,'descend');
    idx = idx(5:-1:1);
    scoreTop = score(idx);
    classNames = netTransfer.Layers(end).ClassNames;
    classNamesTop = classNames(idx);
    % Plot the histogram
    barh(ax2,scoreTop)
    title(ax2,'Top 5')
    xlabel(ax2,'Probability')
    xlim(ax2,[0 1])
    yticklabels(ax2,classNamesTop)
    ax2.YAxisLocation = 'right';
    
    drawnow
    
    
    if strcmp(char(label),char(prevlabel))
      confirm=confirm+1;
      
      if (confirm < confirmthresh) && (max(score)>0.8)
          image(ax1,cam_snap);
          percent=confirm/confirmthresh*100;
          title(ax1,sprintf('Confirming: %s%%',int2str(percent)));
          drawnow;
      end
      
      if (confirm>=confirmthresh) && (max(score)>0.8)
          image(ax1,cam_snap);
          title(ax1,{char(label),num2str(max(score),2)});
          drawnow;
          commands=Gesture2Command(label,commands);
          

          
%               if strcmp(char(label),'Red Light Trigger')
%                   set_Lamp_RGB(Light3, [255,0,0]);  %Set Hue Light Color
%               end

      end
      
    else
        image(ax1,cam_snap);
        drawnow;
        confirm=0;
        commands=zeros(1,7);
    end

    prevlabel=label;
    center_image = size(cam_snap)/2+.5;                                     %%%Calculates Center point
    cam_sensitivity = 70; 
    center_sensitivity = 30;
    
   if centroids(:,1) > center_image(:,2)+center_sensitivity                  %%%Will center the user to the middle of the screen
       commands(4) = 1;
       commands(5) = 0;
       if centroids(:,1) > center_image(:,2)+cam_sensitivity                   %%%Will center the user to the middle of the screen
       commands(6) = 1;
       commands(7) = 0;
       end
   elseif centroids(:,1) < center_image(:,2)-center_sensitivity
       commands(5) = 1;
       commands(4) = 0;
       if centroids(:,1) < center_image(:,2)-cam_sensitivity
       commands(7) = 1;
       commands(6) = 0;
       end
    else
       commands(5) = 0;
       commands(4) = 0;
       commands(6) = 0;
       commands(7) = 0;
    end
    
   fwrite(tcp,commands);
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