%what value is chosen for Y ? one such that X+Y+Z = 1 ?
function [ output,status,msgCharSent ] = set_Lamp_xy(urlLIGHT_State, xyY)

msgCharSent     = sprintf('{"on":true, "xy":[%3.3f,%3.3f]}',xyY(1),xyY(2));
[output,status] = urlread2(urlLIGHT_State,'PUT',msgCharSent);

end

