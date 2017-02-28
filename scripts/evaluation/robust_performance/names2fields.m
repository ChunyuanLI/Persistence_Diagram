function [shapeid, xform, strength] = names2fields(names)
fields   = cellfun(@(x)(split(chop_extension(x),'.','cell')), names, 'UniformOutput', false);
shapeid  = cellfun(@(x)(str2num(x{1})), fields);
xform    = cellfun(@(x)(x{2}), fields, 'UniformOutput', false);
strength = cellfun(@(x)(str2num(x{3})), fields);
