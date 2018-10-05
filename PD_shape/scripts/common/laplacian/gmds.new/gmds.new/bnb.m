function [dmin, ref_y_min, bound] = bnb (d0, ref_y, idx_x, C, bound, Dx, Dy)

if isempty(idx_x),
    if d0 < bound, bound = d0; end
    dmin = d0;
    ref_y_min = ref_y;
    return;
end

n = length(ref_y);

dmin = Inf;
ref_y_min = [];
for k=1:length(C(1,:)),
    i = C(1,k);
    ref_new = [ref_y i];
    if n > 1,
        dy = Dy(i,ref_y);
        dx = Dx(n+1, 1:n);
        d = max(abs(dx(:)-dy(:)));
    else
        d = 0;
    end
    dnew = max(d0, d);
    if dnew < bound,
        [d, ref_y_, bound] = bnb (dnew, ref_new, idx_x(2:end), C(2:end,:), bound, Dx, Dy);
        if d < dmin,
            ref_y_min = ref_y_;
            dmin = d;
        end
    end
end
