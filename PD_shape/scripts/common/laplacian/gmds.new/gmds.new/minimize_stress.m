function [tm,um,f,normg,iter,local_stress] = minimize_stress(mesh, embed, tm, um, D, W, opt)

if nargin < 6,
    W = ones(length(tm), length(tm));
end


if nargin < 7,
    opt = [];
end

if ~isfield(opt,'mingrad'),    mingrad   = 1e-8;    else    mingrad = opt.mingrad;       end
if ~isfield(opt,'maxiter'),    maxiter   = 1000;    else    maxiter = opt.maxiter;       end
if ~isfield(opt,'verbose'),    verbose   = 2;       else    verbose = opt.verbose;       end    % 0 - silent, 1 - final result, 2 - outeriter, 3 - inner iter

epsilon = 1e-12;


    
update = 1;
idx_boundary = [];

%% all drawings are commented
% clf;
%[x,y,z] = bar2euc (mesh, tm, um);
% h = trisurf(mesh.TRIV, mesh.X, mesh.Y, mesh.Z);
% set(h, 'FaceColor', [1 1 1], 'FaceAlpha', 0.75);
% axis image; 
% hold on;
% h = plot3(x,y,z,'sb');
% set(h, 'LineWidth',2);
% hold off;
% drawnow;
tm0 = tm;
um0 = um;



if verbose > 0,
    fprintf('Starting optimization\n'); 
end
f_last = Inf;

for iter = 1:maxiter,

    if update == 1,
        update = 0;
        [f,g1,g2,H11,H12,H22] = stress_symm (um, tm, mesh, embed, D, W);
        f_last = f;
        normg = g1.^2+g2.^2;
        [normg, coord] = max(normg);
        
        if verbose > 1,
             fprintf('%4d   f = %12.8f  |g| = %12.8f\n', iter, f, normg);    
        end
        % we deleted this printf because we think it enhance performance

%         [x0,y0,z0] = bar2euc (mesh, tm0, um0);
%         [x,y,z] = bar2euc (mesh, tm, um);
        tm0 = tm;
        um0 = um;
%         hold on;
%         
%         h = line([x0(:) x(:)]', [y0(:) y(:)]', [z0(:) z(:)]');
%         set(h, 'Color', [1 0 0], 'LineWidth', 2); 
%         
%         h = plot3(x,y,z,'ro');
%         set(h, 'MarkerFaceColor', [1 0 0],'MarkerSize', 5);
%         
%         hold off;
%         drawnow;
%     
    else
        normg = g1.^2+g2.^2;
        [normg, coord] = max(normg);
    end
        
    if normg < 1e-8,
        if verbose > 0,
            fprintf('%4d   f = %12.8f  |g| = %12.8f\n', iter, f, normg); 
            fprintf('Gradient norm reached %12.8f < %12.8f\nOptimization terminated.\n', mingrad, normg);
        end

        if nargout >= 6,
            [f, g1, g2, H11, H12, H22, local_stress] = stress_symm (um, tm, mesh, embed, D, W);
        end

        return;
    end
    
    u = [um(coord,1:2) 1-um(coord,1)-um(coord,2)];

    vertex = find(u>0);
    
    intersection = ...
        1*(u(1)<=0 & u(2) > 0 & u(3) > 0) + ...     % intersect edge 1
        2*(u(2)<=0 & u(1) > 0 & u(3) > 0) + ...     % intersect edge 2
        3*(u(3)<=0 & u(1) > 0 & u(2) > 0);          % intersect edge 3

    % Edge intersection
    if intersection > 0,
               
        [tn, perm] = edge_neighbor (mesh, tm(coord), intersection);

        % Shared edge
        if ~isnan(tn),
          
            % TODO: can be accelerated, no need to recompute all the stress
            um_ = um; tm_ = tm;
            u_ = u(perm);
            um_(coord,:) = u_(1:2);
            tm_(coord) = tn;
            [f_,g1_,g2_,H11_,H12_,H22_] = stress_symm (um_, tm_, mesh, embed, D, W);

            H_in = [H11(coord,coord) H12(coord,coord); H12(coord,coord) H22(coord,coord)];
            g_in = [g1(coord); g2(coord)];
            [u_in, f_in, idx_in] = solve_newton (H_in, g_in, um(coord,:), f);
            u_in  = [u_in 1-u_in(1)-u_in(2)];
            u_in_perm = u_in(perm);
            intersection_in = ...
                1*(u_in_perm(1)<=0 & u_in_perm(2) > 0 & u_in_perm(3) > 0) + ...     % intersect edge 1
                2*(u_in_perm(2)<=0 & u_in_perm(1) > 0 & u_in_perm(3) > 0) + ...     % intersect edge 2
                3*(u_in_perm(3)<=0 & u_in_perm(1) > 0 & u_in_perm(2) > 0);          % intersect edge 3
            
            H_out = [H11_(coord,coord) H12_(coord,coord); H12_(coord,coord) H22_(coord,coord)];
            g_out = [g1_(coord); g2_(coord)];
            [u_out, f_out, idx_out] = solve_newton (H_out, g_out, um_(coord,:), f);
            u_out = [u_out 1-u_out(1)-u_out(2)];
            intersection_out = ...
                1*(u_out(1)<=0 & u_out(2) > 0 & u_out(3) > 0) + ...     % intersect edge 1
                2*(u_out(2)<=0 & u_out(1) > 0 & u_out(3) > 0) + ...     % intersect edge 2
                3*(u_out(3)<=0 & u_out(1) > 0 & u_out(2) > 0);          % intersect edge 3
                        
            % 1. Minimum in both triangles is on the shared edge
            %    implies f_in = f_out due to C^0
            if intersection_in > 0 & ...               % active constrain
               intersection_in == intersection_out,    % same active constrains
                
                % Already in the minimum?
                if norm(um(coord,:)-u_in(1:2)) < epsilon,
                    idx_boundary = [idx_boundary(:); coord];
%                    fprintf ('%4d Already in the minimum on the edge\n', coord);
                    g1(coord) = 0;
                    g2(coord) = 0;
                    f_last = f_in;
                    continue;
                end
                
%                fprintf ('%4d Minimum found on the edge\n', coord);
                um(coord,:) = u_in(1:2);
                update = 1;
                f_last = f_in;
                continue;

            % 2. Minimum in the neighbor triangle is lower
            %    f_in > f_out
            elseif f_in > f_out & abs(f_in-f_out) > epsilon,

%                fprintf ('%4d Minimum in the neighbor triangle is lower\n', coord);                
                tm(coord)   = tn;             % Pass to the neighbor triangle
                um(coord,:) = u_out(1:2);    
                update = 1;
                f_last = f_out;
                continue;

            % 3. Minimum in the neighbor triangle is higher
            %    f_in < f_out
            elseif f_in < f_out & abs(f_in-f_out) > epsilon,
                
%                fprintf ('%4d Minimum in the neighbor triangle is higher\n', coord);
                um(coord,:) = u_in(1:2);
                update = 1;
                f_last = f_in;
                continue;
            
            elseif abs(f_in - f_out) < epsilon %& f_in < f_last,
                
%                fprintf ('%4d Same minimum\n', coord);
                %um(coord,:) = u_in(1:2);
                %update = 1;
                %f_last = f_in;
                g1(coord) = 0;
                g2(coord) = 0;
                update = 0;
                continue;                
                
            else   
                
                g1(coord) = 0;
                g2(coord) = 0;
                update = 0;
                continue;
                
            end
       
        % Boundary    
        else
            
%            fprintf ('%4d Boundary\n', coord);
            
            H = [H11(coord,coord) H12(coord,coord); H12(coord,coord) H22(coord,coord)];
            g = [g1(coord); g2(coord)];
            [u, f_, idx_in] = solve_newton (H, g, um(coord,:), f);
            
            if f_ < f_last & abs(f_-f_last) > epsilon,
                um(coord,:) = u(:)';
                update = 1;            
            else
                idx_boundary = [idx_boundary(:); coord];
                g1(coord) = 0;
                g2(coord) = 0;
                update = 0;
            end
            continue;
            
        end

    % Vertex intersection    
    elseif length(vertex) == 1,

        [tn, perm] = vertex_neighbor (mesh, tm(coord), vertex);

        um_ = um; tm_ = tm;
        f_out = zeros(length(tn),1);
        u_out = zeros(length(tn),3);
        for t=1:length(tn),
            
            % TODO: can be accelerated, no need to recompute all the stress
            u_ = u(perm(t,:));
            um_(coord,:) = u_(1:2);
            tm_(coord) = tn(t);
            [f_in,g1_,g2_,H11_,H12_,H22_] = stress_symm (um_, tm_, mesh, embed, D, W);
            
            H_out = [H11_(coord,coord) H12_(coord,coord); H12_(coord,coord) H22_(coord,coord)];
            g_out = [g1_(coord); g2_(coord)];
            [u_, f_out(t)] = solve_newton (H_out, g_out, um_(coord,:), f_in);
            u_out(t,:)  = [u_ 1-u_(1)-u_(2)];            
        end
        
        
        if length(tn) >= 1,
            [f_out, idx] = min(f_out);
            u_out = u_out(idx,:);
            tn    = tn(idx);
        end
        
        % A neighbor triangle has a lower minimum
        if length(tn) >= 1 & f_out < f_last & abs(f_out-f_last) > epsilon,

%            fprintf ('%4d Boundary!!\n', coord);

            um(coord,:) = u_out(:,1:2);
            tm(coord) = tn;
            update = 1;
            continue;
               
        else,
            
            idx_boundary = [idx_boundary(:); coord];
            g1(coord) = 0;
            g2(coord) = 0;
            update = 0;
            continue;
            
        end
        
    
    % No intersection    
    else
        
%        fprintf(1,'%4d Inside\n', coord);
        H = [H11(coord,coord) H12(coord,coord); H12(coord,coord) H22(coord,coord)];
        g = [g1(coord); g2(coord)];
        [u, f, idx_in] = solve_newton (H, g, um(coord,:), f);
        um(coord,:) = u(:)';
        update = 1;
        f_last = f;
        continue;
        
    end
    

end

if verbose > 0,
    fprintf('%4d   f = %12.8f  |g| = %12.8f\n', iter, f, normg);  
    fprintf('Iteration count exceeded %d\nOptimization terminated.\n', maxiter);
end

if nargout >= 6,
    [f, g1, g2, H11, H12, H22, local_stress] = stress_symm (um, tm, mesh, embed, D, W);
end

