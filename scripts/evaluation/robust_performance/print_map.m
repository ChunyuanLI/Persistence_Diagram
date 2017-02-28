function print_map(varargin)

if length(varargin) == 3,
    fout = 1;
else
    fout = varargin{1};
    varargin = varargin(2:end);
end

MAP      = varargin{1};
XFORM    = varargin{2};
STRENGTH = varargin{3};
    
fprintf(fout, '%-20s', '');
for s = STRENGTH,
    fprintf(fout, '   <=%d   ', s);
end
fprintf(fout, '\n');
for x = 1:length(XFORM),
    fprintf(fout, '%-20s', XFORM{x});
    for s = 1:length(STRENGTH),
        num = MAP(x,s);
        if isnan(num),
            num = '------';
        else
            num = sprintf('%6.4f', num);
        end
        fprintf(fout, '%6s   ', num);
    end
    fprintf(fout, '\n');
end