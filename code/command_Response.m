%Robot Initialization
% arrobot_disconnect %%serial connection needs to be broken before attempting to connect again
% clear all
% aria_init 
% arrobot_connect

filename = 'commands.csv';
mypi = raspi;

while(1)
    data = csvread(filename,1,0);
    move = data(1:3);
    pan = data(4:5);
    move = num2str(move);
    pan = num2str(pan);
    
    configurePin(mypi,5,'DigitalOutput');
    configurePin(mypi,26,'DigitalOutput');
    configurePin(mypi,25,'DigitalOutput');
    
    switch move
        case '1  0  0'                                               
            disp('forward')
%             arrobot_setvel(5);
        
        case '0  1  0'
            disp('right')
%             arrobot_setrotvel(5)
        
        case '0  0  1'
            disp('left');  
%             arrobot_setrotvel(-5)
    end
    
    switch pan
        case '1  0'
            disp('pan right')
            writeDigitalPin(mypi,26,1);
            
        case '0  1'
            disp('pan left')
            writeDigitalPin(mypi,25,1);
    end         
end