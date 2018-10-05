function [vertices, edges,ringv] = generate_2d_shape_graph_structure(coordinate_bounadry)

    num_points = size(coordinate_bounadry,1);
    vertices = coordinate_bounadry;
    
    edges = [];
    for i = 2:num_points
        edge = [i-1,i];
        edges = [edges;edge];
    end
    
    ringv = cell(num_points,1);
    for i = 1:num_points
        
        if i == 1
            ringv{i} = [2];
        else if i == num_points
            ringv{i} = [num_points-1];
            else
                ringv{i} = [i-1,i+1];
            end
        end
    end
     
end