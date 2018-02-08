% function fns = expstruc(X,sname,ll,lname,mems)
%
% Recursively explode a structure to find all members.
%
% INPUTS
% ------
% X; structure to be exploded
% sname; structure name
% ll; structure level (1= top)
% lname; name of the field (string, completely expanded)
% mems; structure containing field names and data types
%
% =====================================
% written by Andy Clifton, October 2010.
% =====================================

function mems = expstruc(X,sname,ll,lname,mems)

switch nargin
    case 1
        % generate us an empty name vector
        sname = inputname(1);
        lname = [];
        ll = 1;
        mems = struct('name',{''},'type',{''});
    case 2
        lname = [];
end

switch class(X)
    case {'struct'} % still something to expand
        fns = fieldnames(X);
        for f = 1:numel(fns)
            % keep expanding the structure
            switch ll
                case 1
                    expstruc(X.(fns{f}),sname,ll+1,...
                        [sname '.' char(fns{f})],mems);
                otherwise
                    expstruc(X.(fns{f}),sname,ll+1,...
                        [lname '.' char(fns{f})],mems);
            end
        end
    otherwise % then no more fields to expand
        % M.Ciacci added this try/catch part, July 2017
        try
            n1 = max(1,50-length(lname));
            space1 = repmat(' ',1,n1);
            if isempty(X)
                disp([' ' lname space1 ' = []'])
            elseif ischar(X)
                disp([' ' lname space1 ' = '  X])
            elseif iscell(X)
                if ischar(X{1})
                    disp([' ' lname space1 ' = '  vec2string(cell2mat(X),'%s,')])
                else
                    disp([' ' lname space1 ' = '  vec2string(cell2mat(X),'%g,')])
                end
            else                
                if length(X) == 1
                    disp([' ' lname space1 ' = '  sprintf('%g',X)])                    
                else
                    disp([' ' lname space1 ' = '  vec2string(X,'%g,')])
                end
            end
        catch MSG
            disp(['... ' lname])
        end
        mems.name{end+1} = lname;
        mems.type{end+1} = class(X);
        % how do I get this data out of the function, though?
end

end 


function str = vec2string(vec,fmt)
str = [];
% for ii=1:length(vec)
%     str = [str,sprintf(fmt,vec(ii)),' '];
% end

for ii=1:length(vec)    
    if isreal(vec(ii)) || str2double(sprintf(fmt,imag(vec(ii))))==0
        str = [str,sprintf(fmt,vec(ii)),' '];
    else
        str = [str,sprintf([fmt,'+j',fmt],real(vec(ii)),imag(vec(ii))),' '];        
    end
end
end