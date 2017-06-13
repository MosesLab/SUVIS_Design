function [ ] = plot_resolution( left, center, right, phi_s, dir )

% Create directory where output from this script will be stored
plot_dir = strcat(dir, 'resolution/');
mkdir(dir);

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

% Calculate standard deviation of rays
sigmaX_l = [];  % length
sigmaX_c = [];
sigmaX_r = [];

sigmaL_l = [];  % wavelength
sigmaL_c = [];
sigmaL_r = [];

wav_l = []; % wavelength
wav_c = [];
wav_r = [];
for i = 1:size(x_c,1)
    
    wav_cal = 1e3 * (lam_l(i,1) - lam_r(i,1)) / (mean(x_l(i,:)) - mean(x_r(i,:)));
    
   
    
end

end

