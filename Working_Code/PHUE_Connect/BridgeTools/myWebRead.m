function [ data ] = myWebRead( url )
%MYWEBREAD Summary of this function goes here
%   Detailed explanation goes here



v = version('-release'); vn=str2double(v(1:4))*10+(v(5)-'a')+1;
if vn < 20142 %< 2014b
    error('this is not going to work... Need ML2014b at least!');    
%     tmp = urlread2(url);
%     [output,extras] = urlread2(url,'GET','');

else
    data = webread(url);    
end



end

