function dist = wasserstein_distance(D1, D2, p)
    if(~isempty(find(D1(:,2)<D1(:,1),1)) || ...
            ~isempty(find(D2(:,2)<D2(:,1),1)))
        error('points must be above the diagonal');
    end
    
    nv1 = size(D1,1);
    nv2 = size(D2,1);
    
    P1 = [D1; (D2(:,1) + D2(:,2))/2 (D2(:,1) + D2(:,2))/2];
    P2 = [D2; (D1(:,1) + D1(:,2))/2 (D1(:,1) + D1(:,2))/2];
    
    A1 = pdist2(P1(:,1),P2(:,1));
    A2 = pdist2(P1(:,2),P2(:,2));
    A = max(A1,A2).^(p);
    A(nv1+1:end,nv2+1:end) = 0; 
    
    [~,cost] = munkres(A);
    
    dist = cost;
end