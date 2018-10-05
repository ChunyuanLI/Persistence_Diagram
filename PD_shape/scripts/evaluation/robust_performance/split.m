function varargout = split(str, c, type)

idx = find(str == c);
idx = [0; idx(:); length(str)+1];

items = {};
for i = 2:length(idx),
    items{i-1} = str(idx(i-1)+1:idx(i)-1);
end

if nargin < 3, type = 'varargout'; end

switch lower(type),
    
    case 'varargout'
        varargout = items;
    case 'cell'
        varargout{1} = items;
end
