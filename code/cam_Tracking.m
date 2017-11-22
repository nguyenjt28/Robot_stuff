%%%This function controls the camera's movement and will pan the camera
%%%left or right

function commands = cam_Tracking(cam_snap, centroids, commands)

   center_image = size(cam_snap)/2+.5;                                     %%%Calculates Center point
   cam_sensitivity = 70;                                                   %%%Cam tracking sensitivity
%    plot(center_image(:,2),center_image(:,1), '+g', 'MarkerSize', 10);
%     configurePin(mypi,5,'DigitalOutput');
%     configurePin(mypi,26,'DigitalOutput');
%     configurePin(mypi,25,'DigitalOutput');
   
           
   if centroids(:,1) > center_image(:,2)+cam_sensitivity                   %%%Will center the user to the middle of the screen
%        writeDigitalPin(mypi,26,1);
       commands(4) = 1;
   end
   if centroids(:,1) < center_image(:,2)-cam_sensitivity
%        writeDigitalPin(mypi,25,1);
       commands(5) = 1;
   end