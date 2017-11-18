%%%This function is used to calculate the extremities of the image and will
%%%output whether the lefthand/righthand or both are up

function [RHU, LHU] = calc_Extremities(centroids, point1L, point2L, row1L, row2L, column1L, column2L, HBuffer)

     if (point1L < centroids(2)) && ((column2L-column1L)/2 <= (abs(centroids(1)-column1L))+HBuffer) && (column2L-column1L)>=0.5*(row2L-row1L) %%%Determines if extremities are protruded for gesture recognition and plots 
        plot(column1L,point1L, '*g', 'MarkerSize',10)
        RHU = 1;
     else
         RHU = 0;
     end
     if (point2L < centroids(2)) && ((column2L-column1L)/2 <= (abs(column2L-centroids(1))+HBuffer)) && (column2L-column1L)>=0.5*(row2L-row1L)
        plot(column2L,point2L, '*g', 'MarkerSize',10)
        LHU = 1;
     else
         LHU = 0;
     end