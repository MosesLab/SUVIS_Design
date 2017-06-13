function [lam, hx, hy, px, py, x, y, vig ] = get_ray_data( rays )

lam = squeeze(rays(1,:,:));  % array of wavelengths
hx = squeeze(rays(2,:,:));   % array of x-components of field angle
hy = squeeze(rays(3,:,:));   % array of y-components of field angle
px = squeeze(rays(4,:,:));
py = squeeze(rays(5,:,:));
x = squeeze(rays(6,:,:));  % Array of x-coordinates of rays on detector
y = squeeze(rays(7,:,:));  % Array of y-coordinates of rays on detector
vig = squeeze(rays(8,:,:));  % vignetting code

end

