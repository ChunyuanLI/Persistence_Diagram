function [cmap] = my_cmap(n)
% function [rgb_map] = my_cmap(n)
% n is the colormap size
% cmap(value) monotonically increases
% cmap(hue) ranges from blue to red
% cmap(saturation) = 1


if(nargin < 1)
    n = 64;
end

% v
v0 = 1/3;
v1 = 1;
dv = (v1-v0)/(n-1);
v = (v0:dv:v1)';

% h goes from blue to red
blue_hsv = rgb2hsv([0,0,1]); blue_h = blue_hsv(1);
red_hsv = rgb2hsv([1,0,0]); red_h = red_hsv(1);

h0 = blue_h;
h1 = red_h;
dh = (h1 - h0)/(n-1);
h = (h0:dh:h1)';

% s
s = ones(n, 1);

cmap = hsv2rgb([h, s, v]);
 
% figure; imagesc([0:1:n]'); colormap(cmap);
% s0 = zeros(n, 1);
% figure; imagesc([0:1:n]'); colormap(hsv2rgb([h, s0, v]));
% 
