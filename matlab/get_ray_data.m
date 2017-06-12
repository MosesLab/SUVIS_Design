function [lam, hx, hy, px, py, x, y, vig ] = get_ray_data( rays )

lam = rays(1,:,:);  % array of wavelengths
hx = rays(2,:,:);   % array of x-components of field angle
hy = rays(3,:,:);   % array of y-components of field angle
px = rays(4,:,:);
py = rays(5,:,:);
x = rays(6,:,:);  % Array of x-coordinates of rays on detector
y = rays(7,:,:);  % Array of y-coordinates of rays on detector
vig = rays(8,:,:);  % vignetting code

end

