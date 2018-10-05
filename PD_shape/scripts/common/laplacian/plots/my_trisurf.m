function [] = my_trisurf(TRIV, X, Y, Z, c, params)
% params.colorbar = 'off' or '';

if(nargin < 6)
    params = struct;
    if(nargin < 5)
        c = Z;
    end
end

if(isstruct(c))
    params = c;
    c = Z;
end

trisurf(TRIV, X(:), Y(:), Z(:), c,...
    'EdgeColor', 'interp', 'FaceColor', 'interp', 'BackFaceLighting', 'unlit');
set(rotate3d,'ActionPostCallback',@update_headlight_callback);

if(isfield(params, 'colorbar'));
    colorbar;
end

if(isfield(params, 'camup') && ~isempty(params.camup))
    camup(params.camup);
end

if(isfield(params, 'campos') && ~isempty(params.campos))
    campos(params.campos);
end

if(isfield(params, 'camva') && ~isempty(params.camva))
    camva(params.camva);
end

camlight head;
material dull; lighting phong; shading interp; axis image; axis off; 

end % function trisurf_shape



