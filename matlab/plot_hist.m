function [  ] = plot_hist( left, center, right, phi_s, dir, d_d, field_den, ray_den )

% Create directory where output from this script will be stored
spot_dir = strcat(dir, 'hist/');
mkdir(dir);
l_dir = strcat(spot_dir, 'left/');
c_dir = strcat(spot_dir, 'center/');
r_dir = strcat(spot_dir, 'right/');
mkdir(l_dir)
mkdir(c_dir)
mkdir(r_dir)

% Extract parameters of each ray
[lam_c, hx_c, hy_c, px_c, py_c, x_c, y_c, vig_c] = get_ray_data(center);
[lam_l, hx_l, hy_l, px_l, py_l, x_l, y_l, vig_l] = get_ray_data(left);
[lam_r, hx_r, hy_r, px_r, py_r, x_r, y_r, vig_r] = get_ray_data(right);

x_l = x_l * 1e3;    % Convert detector position to microns
x_c = x_c * 1e3;
x_r = x_r * 1e3;


% subtract mean for accurate comparison
o_c = mean(x_c(:));
o_l = mean(x_l(:));
o_r = mean(x_r(:));
x_c = x_c - o_c;
x_l = x_l - o_l;
x_r = x_r - o_r;

% calculate edges of bins
d_d = 1e3 * d_d;    % Convert pixel size to microns
bin_w = 1/4;    % in units of pixels
all_x = [x_c(:), x_l(:), x_r(:)];
min_x = min(all_x(:));
max_x = max(all_x(:));
min_y = 0;
max_y = field_den^2 * ray_den^2 * bin_w;
edges = (min_x : bin_w * d_d : max_x);

figure(11)
for i = 1:size(x_c,1)
    
    hold off
    histogram(x_l(i,vig_l(i,:) == 0), edges);
    hold on
    xlim([min_x, max_x]);
    ylim([min_y, max_y]);
    xlabel('Detector X (µm from centroid)');
    ylabel(sprintf('Ray counts per %0.2f pixel', bin_w));
    text(0.92 * min_x, 0.96 * max_y, sprintf('wavelength = %0.0f nm\nfeed optic position = %0.1f deg\nspot width (2\\sigma) = %0.1f µm',...
        1e3 * lam_l(i,1), rad2deg(phi_s(i)), 2 * std(x_l(i, vig_l(i,:) == 0))), 'VerticalAlignment', 'top', 'BackgroundColor', 'white', 'EdgeColor', 'black');
    print(sprintf('%sspot_hist_%0.0f_%0.0f.eps', l_dir, 1e3 * lam_l(i,1), rad2deg(phi_s(i))),'-depsc');
    print(sprintf('%sspot_hist_%0.0f_%0.0f.png', l_dir, 1e3 * lam_l(i,1), rad2deg(phi_s(i))),'-dpng');
    
    hold off
    histogram(x_c(i,vig_c(i,:) == 0), edges);
    hold on
    xlim([min_x, max_x]);
    ylim([min_y, max_y]);
    xlabel('Detector X (µm from centroid)');
    ylabel(sprintf('Ray counts per %0.2f pixel', bin_w));
    text(0.92 * min_x, 0.96 * max_y, sprintf('wavelength = %0.0f nm\nfeed optic position = %0.1f deg\nspot width (2\\sigma) = %0.1f µm',...
        1e3 * lam_c(i,1), rad2deg(phi_s(i)), 2 * std(x_c(i, vig_c(i,:) == 0))), 'VerticalAlignment', 'top', 'BackgroundColor', 'white', 'EdgeColor', 'black');
    print(sprintf('%sspot_hist_%0.0f_%0.0f.eps', c_dir, 1e3 * lam_c(i,1), rad2deg(phi_s(i))),'-depsc');
    print(sprintf('%sspot_hist_%0.0f_%0.0f.png', c_dir, 1e3 * lam_c(i,1), rad2deg(phi_s(i))),'-dpng');
    
    hold off
    histogram(x_r(i,vig_r(i,:) == 0), edges);
    hold on
    xlim([min_x, max_x]);
    ylim([min_y, max_y]);
    xlabel('Detector X (µm from centroid)');
    ylabel(sprintf('Ray counts per %0.2f pixel', bin_w));
    text(0.92 * min_x, 0.96 * max_y, sprintf('wavelength = %0.0f nm\nfeed optic position = %0.1f deg\nspot width (2\\sigma) = %0.1f µm',  ...
        1e3 * lam_r(i,1), rad2deg(phi_s(i)), 2 * std(x_r(i, vig_r(i,:) == 0))), 'VerticalAlignment', 'top', 'BackgroundColor', 'white', 'EdgeColor', 'black');
    print(sprintf('%sspot_hist_%0.0f_%0.0f.eps', r_dir, 1e3 * lam_r(i,1), rad2deg(phi_s(i))),'-depsc');
    print(sprintf('%sspot_hist_%0.0f_%0.0f.png', r_dir, 1e3 * lam_r(i,1), rad2deg(phi_s(i))),'-dpng');
    
end

end

