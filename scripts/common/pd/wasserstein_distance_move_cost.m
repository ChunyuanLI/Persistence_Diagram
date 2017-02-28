function [dist_persistence,dist_move] = wasserstein_distance_move_cost(D1, D2, p)
    if(~isempty(find(D1(:,2)<D1(:,1),1)) || ...
            ~isempty(find(D2(:,2)<D2(:,1),1)))
        error('points must be above the diagonal');
    end
    
    nv1 = size(D1,1);
    nv2 = size(D2,1);
    
    P1 = [D1(:,1:2); (D2(:,1) + D2(:,2))/2 (D2(:,1) + D2(:,2))/2];
    P2 = [D2(:,1:2); (D1(:,1) + D1(:,2))/2 (D1(:,1) + D1(:,2))/2];
    
    A1 = pdist2(P1(:,1),P2(:,1));
    A2 = pdist2(P1(:,2),P2(:,2));
    A = max(A1,A2).^(p);
    A(nv1+1:end,nv2+1:end) = 0; 
    
    [assignment,cost] = munkres(A);
    dist_persistence = cost;
    
    correspondence = assignment(1,1:nv1);
    idx = find(correspondence <= nv2);
    jobs = correspondence(idx);
    worker = idx;
    pairs = [worker',jobs'];
    
    A3 = pdist2(D1(:,3),D2(:,3));
    
    max_persistence1 = 2;%D1(1,4);
    max_persistence2 = 2;%D2(1,4);
    
    CUT_OFF = 3;
    
    num_pairs = size(pairs,1); 
    d = [];
    for i = 1:num_pairs
        
        if max_persistence1/CUT_OFF <= D1(pairs(i,1),4) & ...
                max_persistence2/CUT_OFF <= D2(pairs(i,2),4)
                d = [d, A3(pairs(i,1),pairs(i,2))];
        end
    end
    d = sum(d)/num_pairs;
    dist_move = d;
        
end