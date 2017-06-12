function [ ] = plot_spot( left, center, right )

[lam_l, hx_l, hy_l, px_l, py_l, x_l, y_l, vig_l] = get_ray_data(left);
[lam_c, hx_c, hy_c, px_c, py_c, x_c, y_c, vig_c] = get_ray_data(center);
[lam_r, hx_r, hy_r, px_r, py_r, x_r, y_r, vig_r] = get_ray_data(right);

pt_sz = 20;
pt_color = hx_c;
scatter(x_c, y_c, pt_sz, pt_color, 'filled');

end

