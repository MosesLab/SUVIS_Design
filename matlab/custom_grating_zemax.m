% Design using a custom grating as specified in the header:
custom_grating_hdr
% CCK 2017-Jun-30 put parameters into a header shared by this program and custom_grating.m

% Raytrace densities
field_den = 7;  % Number of field angles to sample per axis
ray_den = 25;   % Number of rays in pupil per axis
tot_rays = field_den^2 * ray_den^2;

phiS_resolution = 25;  % Number of slit positions
d_phiS = (phiS_max - phiS_min) / (phiS_resolution - 1);     % Angle between each slit position
phiS = phiS_min : d_phiS : phiS_max;

rays_center = [];      % Array to store results of raytrace for each slit position
rays_left = [];
rays_right = [];

% Loop over given slit positions
i = 1;
for phi_s = phiS
    
    fprintf('Raytrace for position %i of %i\n', i, phiS_resolution);
    
    % construct zemax model for this slit position
    build_zemax_model(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m, r_s, field_den, ray_den);
    
    % Read rays for this slit position into Matlab memory
    [left, center, right] = read_zemax_raytrace();
    
    % Store results in cube
    rays_center = cat(2, rays_center, center);
    rays_left = cat(2, rays_left, left);
    rays_right = cat(2, rays_right, right);
    
    i = i + 1;
    
end

dir = '../output/';
cmd_rmdir(dir);
mkdir(dir);

plot_spot(rays_left, rays_center, rays_right, phiS, dir);

plot_resolution( rays_left, rays_center, rays_right, phiS, dir , d_d)


