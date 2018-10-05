function [] = my_trimesh(TRIV, X, Y, Z, params)
trimesh(TRIV, X, Y, Z, 'BackFaceLighting', 'unlit');

if(nargin == 4)
    params = struct;
end

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

material dull; lighting phong; shading interp; axis image; axis off; 
