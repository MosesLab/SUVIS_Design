function [ ] = plot_spot( left, center, right, phi_s, dir )

s_sz = 15.74;


% Create directory where output from this script will be stored
spot_dir = strcat(dir, 'spot/');
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

mar = 1.05;    % Plot margin
all_x = [x_c(:), x_l(:), x_r(:)];
all_y = [y_c(:), y_l(:), y_r(:)];
min_x = mar * min(all_x(:));
max_x = mar * max(all_x(:));
min_y = mar * min(all_y(:));
max_y = mar * max(all_y(:));

pt_sz = 20; % Size of points in scatterplot
figure(10);

for i = 1:size(x_c,1)
    i_c = find(vig_c(i,:) == 0);
    hold off
    gscatter(x_c(i,i_c), y_c(i,i_c), s_sz * hx_c(i,i_c));
    hold on
    xlim([min_x, max_x]);
    ylim([min_y, max_y]);
    title(sprintf('Spot Diagram\n detector center offset = %0.3f\n wavelength = %0.0f nm\n slit position = %0.1f deg', o_c, 1e3 * lam_c(i,1), rad2deg(phi_s(i))));
    xlabel('Detector X (mm from center)');
    ylabel('Detector Y (mm from center)');
    print(sprintf('%sspot_center_%0.0f_%0.0f.pdf', c_dir, 1e3 * lam_c(i,1), rad2deg(phi_s(i))),'-dpdfwrite');
    print(sprintf('%sspot_center_%0.0f_%0.0f.png', c_dir, 1e3 * lam_c(i,1), rad2deg(phi_s(i))),'-dpng');
    
    i_l = find(vig_l(i,:) == 0);
    hold off
    gscatter(x_l(i,i_l), y_l(i,i_l), s_sz * hx_l(i,i_l));
    hold on
    xlim([min_x, max_x]);
    ylim([min_y, max_y]);
    title(sprintf('Spot Diagram\n detector center offset = %0.3f\n wavelength = %0.0f nm\n slit position = %0.1f deg', o_l, 1e3 * lam_l(i,1), rad2deg(phi_s(i))));
    xlabel('Detector X (mm from center)');
    ylabel('Detector Y (mm from center)');
    print(sprintf('%sspot_left_%0.0f_%0.0f.pdf', l_dir, 1e3 * lam_l(i,1), rad2deg(phi_s(i))),'-dpdfwrite');
    print(sprintf('%sspot_left_%0.0f_%0.0f.png', l_dir, 1e3 * lam_l(i,1), rad2deg(phi_s(i))),'-dpng');
    
    i_r = find(vig_r(i,:) == 0);
    hold off
    gscatter(x_r(i,i_r), y_r(i,i_r), s_sz * hx_r(i,i_r));
    hold on
    xlim([min_x, max_x]);
    ylim([min_y, max_y]);
    title(sprintf('Spot Diagram\n detector center offset = %0.3f\n wavelength = %0.0f nm\n slit position = %0.1f deg', o_r, 1e3 * lam_r(i,1), rad2deg(phi_s(i))));
    xlabel('Detector X (mm from center)');
    ylabel('Detector Y (mm from center)');
    print(sprintf('%sspot_right_%0.0f_%0.0f.pdf', r_dir, 1e3 * lam_r(i,1), rad2deg(phi_s(i))),'-dpdfwrite');
    print(sprintf('%sspot_right_%0.0f_%0.0f.png', r_dir, 1e3 * lam_r(i,1), rad2deg(phi_s(i))),'-dpng');
    
end

end
