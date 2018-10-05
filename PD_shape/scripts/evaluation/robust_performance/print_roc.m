function print_roc(varargin)

if length(varargin) == 4,
    fout = 1;
else
    fout = varargin{1};
    varargin = varargin(2:end);
end

EER      = varargin{1};
FPR1     = varargin{2};
FPR01    = varargin{3};
XFORM    = varargin{4};
    
fprintf(fout, '\n');
fprintf(fout, '%20s   EER    FP@1%%  FP@0.1%%\n', '');
for x = 1:length(XFORM),
    fprintf(fout, '%-20s', XFORM{x});
    fprintf(fout, '%6.4f   ', EER(x));
    fprintf(fout, '%6.4f   ', FPR1(x));
    fprintf(fout, '%6.4f', FPR01(x));
    fprintf(fout, '\n');
end