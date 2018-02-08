%%%This function will determine centroids, row1L, row2L, column1L, column2L
%%%and draw a rectangle around the target

function [centroids, row1L, row2L, column1L, column2L, wL, hL] = draw_Rectangle(BW)
    verticalL = any(BW,2);
    horizontalL = any(BW,1);
    row1L = find(verticalL,1,'first');                                     %%%Finds top row pixel of 1 in image
    row2L = find(verticalL,1, 'last');                                     %%%Finds lowest/bottom row pixel of 1 in image
    column1L = find(horizontalL,1,'first');                                %%%Finds first horizontal pixel (first side of target)
    column2L = find(horizontalL,1,'last');                                 %%%Finds last horizontal pixel (last side of target)
    wL = column2L - column1L;
    hL = row2L - row1L;

    %sfigure(3); 
%      imshow(BW); 
%      hold on;
%      rectangle('Position',[column1L row1L wL hL],'EdgeColor','r','LineStyle','-.','LineWidth',1.5);
      center  = regionprops(BW, 'centroid');
      centroids = cat(1, center.Centroid);
%      plot(centroids(:,1), centroids(:,2), '+r', 'MarkerSize',10);           %%%Mass Centroid