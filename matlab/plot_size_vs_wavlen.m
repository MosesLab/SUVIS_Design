function [  ] = plot_ave_size_vs_wavlen( left, center, right, phi_s, dir )

% Create directory where output from this script will be stored
plot_dir = strcat(dir, 'size_vs_wavlen/');
mkdir(dir);
l_dir = strcat(plot_dir, 'left/');
c_dir = strcat(plot_dir, 'center/');
r_dir = strcat(plot_dir, 'right/');
mkdir(l_dir)
mkdir(c_dir)
mkdir(r_dir)

% Extract parameters of each ray
[lam_c, hx_c, hy_c, px_c, py_c, x_c, y_c, vig_c] = get_ray_data(center);
[lam_l, hx_l, hy_l, px_l, py_l, x_l, y_l, vig_l] = get_ray_data(left);
[lam_r, hx_r, hy_r, px_r, py_r, x_r, y_r, vig_r] = get_ray_data(right);


% subtract mean for accurate comparison
o_c = mean(x_c(:));
o_l = mean(x_l(:));
o_r = mean(x_r(:));
x_c = x_c - o_c;
x_l = x_l - o_l;
x_r = x_r - o_r;

% find y-pupil coordinates
u_py = unique(py);

% Construct RMS spot size data cube in wavelength and height
rms_c = [];
ht_c = [];
for i = 1:size(x_c,1)
    j = 0;
    for py_i = u_py
        ind = find(py == py_i & vig_c == 0);
        X_c = x_c(i,ind);
        Y_c = y_c(i,ind);
        
        rms_c(i,j) = sqrt(mean(X_c .* X_c));
        ht_c(i,j) = mean(Y_c);
        
        j = j + 1;
    end
end

% Plot slices along wavelength
j = 0;
for ht

end

