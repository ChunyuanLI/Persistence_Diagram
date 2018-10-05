function update_headlight_callback(obj,evd)
% delete lights
chldrn = get(gca, 'Children');
for i=1:length(chldrn)
    if(strcmp(get(chldrn(i), 'Type'), 'light'))
        delete(chldrn(i));
    end
end
camlight('headlight')
end %function mypostcallback

