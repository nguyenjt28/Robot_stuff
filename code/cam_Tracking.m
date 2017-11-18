%%%This function controls the camera's movement and will pan the camera
%%%left or right

function cam_Tracking(cam_snap, mypi, centroids)

   center_image = size(cam_snap)/2+.5;                                     %%%Calculates Center point
   cam_sensitivity = 25;                                                   %%%Cam tracking sensitivity
%    plot(center_image(:,2),center_image(:,1), '+g', 'MarkerSize', 10);
   configurePin(mypi,5,'DigitalOutput');
   configurePin(mypi,6,'DigitalOutput');
           
   if centroids(:,1) > center_image(:,2)+cam_sensitivity                   %%%Will center the user to the middle of the screen
       writeDigitalPin(mypi,6,1);
   elseif centroids(:,1) < center_image(:,2)-cam_sensitivity
       writeDigitalPin(mypi,5,1);
   else
   end