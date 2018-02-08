% Communicate with a Philips Hue bridge to talk to the Hue personal wireless LED lights.
%  - Finds the Hue Bridge using https://www.meethue.com/api/nupnp
%  - Checks if user previously paired with bridge, if not a pairing procedure is started.
%  - Upon completed connection with the Hue-Bridge, user will get an appID,  stored to a mat file userNameWQuotes.mat" for later use.
%  - Returns the url to the first found light attached to the bridge : url_1st_light_state 
% Ref: https://www.developers.meethue.com/documentation/getting-started
% 
% Massimo Ciacci, 2017-07-02
function [url_1st_light_state, lights_ALL_INFO, errCode, Hue_IP, AppID] = Philips_HUE_CONNECT(verbose)
 
if nargin < 1
    verbose = 1;
end
errCode = 0;
%% hard-coded setting to test with HUE emulator (SteveyO-Hue-Emulator)
% uncomment what you need
% --------------------------------------------
% USE_JAVA_HUE_EMULATOR = 1; % get jar file from http://steveyo.github.io/Hue-Emulator/
USE_JAVA_HUE_EMULATOR = 0; % Use the real thing
% --------------------------------------------


addpath(genpath('BridgeTools'));
workspace;  % Make sure the workspace panel is showing.
fprintf('\n\n\n\n\n\n');
fprintf('Attempting Connection.. \n'); 

if ~USE_JAVA_HUE_EMULATOR
    fprintf('patience... finding IP address...');
    Hue_IP = get_HUE_IP();
    if strcmp(Hue_IP(1:3),'192')
        fprintf('Hue IP Detected: %s\n',Hue_IP);
    end
    fName = 'userNameWQuotes.mat';
else
    fprintf('\nRunning in EMULATOR mode.\n');
    Hue_IP = '127.0.0.1'; % Hue Emulator, localhost
    fName = 'userNameWQuotes_EMU.mat';    
end

% %% (1) Unauthoirzed user read (GET) test
% % Address 	http://<bridge ip address>/api/newdeveloper
% % Body
% % Method 	GET
% url = sprintf('http://%s/api/invalidUserID1234/', Hue_IP);
% response = myWebRead(url);
% response.error

%first check if available user name in mat file was previously registered here
fprintf('Checking if we were earlier registered to this hue bridge..\n')

try
    %% Link button not pressed POST : PAIR UP WITH UE BRIDGE
    load(fName)  % userNameWQuotes            NgQcTIB9fXENwHRc2Hgmd6W2ilXBfvUSgRrB46KN
    AppID     = userNameWQuotes(2:end-1);
    url        = sprintf('http://%s/api/%s/', Hue_IP,AppID);
    deviceINFO = myWebRead(url); % Unauthoirzed user read (GET) test
    NeedToPair_GetIntoWhiteList = isfield(deviceINFO,'error');
catch MSG
    MSG
    MSG.message
    errCode = 'JAVA_EMU_NOT_FOUND';
    if USE_JAVA_HUE_EMULATOR
        warning('No Hue bridge Found, make sure "Hue Emulator" is running, set port 80 and click Start first.');
    else
        warning('No Hue bridge Found ??');
    end
end

if NeedToPair_GetIntoWhiteList    
    fprintf('We are not known to the device yet. Attempting connection.\n')
    [deviceINFO, AppID] = register_to_Hue_Bridge(Hue_IP, fName);
    if ~isempty(AppID)
        fprintf('NEW Connection with Hue Bridge ESTABLISHED ! Registration completed. \n')
        AppID
    else
        fprintf('Connection ABORTED by user. \n')
        errCode = 'CONNECTION_ABORTED';
    end
else
    fprintf('Connection with Hue Bridge ESTABLISHED !, using previous available user-name (AppID)\n')
end

if verbose
    try
        fprintf('DEVICE INFO:\n')
        expstruc(deviceINFO);    
        userNameWQuotes

        fprintf('Previously paired Applications / UserNames:\n')
        deviceINFO.config.whitelist
    catch MSG
    end 
end

if isfield(deviceINFO,'lights')
    if    isfield(deviceINFO.lights,'x1')
            sel_Light = deviceINFO.lights.x1;
            FirstLightNr = 1;
    elseif isfield(deviceINFO.lights,'x2')
            sel_Light = deviceINFO.lights.x2;
            FirstLightNr = 2;            
    elseif isfield(deviceINFO.lights,'x3')
            sel_Light = deviceINFO.lights.x3;
            FirstLightNr = 3;            
    else
        errCode = 'CONNECTED_BUT_NO_LIGHTS';
        deviceINFO.lights
        warning('cannot find light entries ?');
    end
else
    error('cannot find lights ?');
end    
% sel_Light
% expstruc(sel_Light);


% get info about all lights
% http://<bridge ip address>/api/1028d66426293e821ecfd9ef1a0731df/lights
url        = sprintf('http://%s/api/%s/lights', Hue_IP,AppID);
lights_ALL_INFO = myWebRead(url);
if verbose
    expstruc(lights_ALL_INFO);
end


% % http://<bridge ip address>/api/1028d66426293e821ecfd9ef1a0731df/lights/1
% lightsINFO = myWebRead(urlLIGHT);
% if verbose
%     expstruc(lightsINFO);
% end


%% try turn it on - off - on, like in the theaters...
% Address 	http://<bridge ip address>/api/1028d66426293e821ecfd9ef1a0731df/lights/1/state
% Body 	{"on":true}
% Method 	PUT
urlLIGHT        = sprintf('http://%s/api/%s/lights/%d', Hue_IP,AppID,FirstLightNr);
url_1st_light_state  = [urlLIGHT,'/state'];
body_char       = '{"on":true}';
[output,status] = urlread2(url_1st_light_state,'PUT',body_char);
pause(1)
body_char       = '{"on":false}';
[output,status] = urlread2(url_1st_light_state,'PUT',body_char);
pause(1)
body_char       = '{"on":true}';
[output,status] = urlread2(url_1st_light_state,'PUT',body_char);


fprintf('\n\n');


end




% fName, to save user name for next time once we are into white list
function [deviceINFO, AppID] = register_to_Hue_Bridge(Hue_IP, fNameSAVE)
    % Address 	http://<bridge ip address>/api
    % Body 	{"devicetype":"my_hue_app#iphone peter"}
    % Method 	POST
    url  = sprintf('http://%s/api', Hue_IP)

    POST_body_char = '{"devicetype":"ColorStudioMax#_Color_GUI"}';

    [output,status] = urlread2(url,'POST',POST_body_char)
    notPressed = ~isempty(strfind(output,'link button not pressed'));
    finished = (status.isGood ~= 1) || ~notPressed;

    if ~finished
        options.Interpreter = 'none'; options.Default = 'Yes';
        qstring = 'To connect to HUE, I need to obtain a valid Username, Proceed with Pairing? You will need to press the link button on the bridge';
        choice = questdlg(qstring,'Pair with Hue Bridge','Yes','No-Cancel',options);
        if ~strcmp(choice,'Yes')
            deviceINFO=[];
            AppID=[];
            return
        else
            h1=msgbox('Press the Link Button on the HUE bridge');
        end
    end

    while ~finished    
        [output,status] = urlread2(url,'POST',POST_body_char)    
        notPressed = ~isempty(strfind(output,'link button not pressed'));
        finished = (status.isGood ~= 1) || ~notPressed;
        pause(1)
    end
    if ishandle(h1), close(h1); end

    if ~status.isGood
        error('could not comunicate with Philips Hue Bridge');
    end

    if isempty(strfind(output,'username'))
        error('something went wrong while talking to Hue Bridge');
        output
    end
    n1              = strfind(output,'":"')+2;
    n2              = strfind(output,'"}') ;
    userNameWQuotes = output(n1:n2);
    save(fNameSAVE,'userNameWQuotes')
    
    AppID          = userNameWQuotes(2:end-1);    
    
    %% GET device INFO
    % Address 	http://<bridge ip address>/api/newdeveloper
    % Body
    % Method 	GET
    url = sprintf('http://%s/api/%s/', Hue_IP,AppID);
    deviceINFO = myWebRead(url); 
end


function [ Hue_IP, Hue_ID ] = get_HUE_IP()
    % GET_HUE_IP: get HUE IP address and ID
    url = 'https://www.meethue.com/api/nupnp';
    data = myWebRead(url);
    if isempty(data)
        warning('could not read your Hue IP address... Are under a VPN? Turn it off first.');
        data.id                = '001788fffe401fea'
        data.internalipaddress = '192.168.1.101'
    end
    fprintf('done! \n');    
    Hue_ID = data.id;
    Hue_IP = data.internalipaddress;
end
