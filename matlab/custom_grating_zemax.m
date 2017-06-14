% Design using a custom grating
offset = 4.1*pi/180; % Offset detector from normal
phiS_max =  offset + 33*pi/180; % (rad) angular position of slit     on Rowland Circle
phiS_min =  offset + 10*pi/180;
phi_g = pi-offset; % (rad) angular position of grating  on Rowland Circle
phi_d = offset; % (rad) angular position of detector on Rowland Circle
R_g   =   1500.0; % (mm)  grating radius
w_g   =    100.0; % (mm) grating width
d_s   =  15e-3; % (mm) width of slit
d_g   = 1/2160; % (mm) grating groove period
d_d   =  15e-3; % (mm) detector pixel spacing
N_d   =   2048; % Number of detector pixels in the dispersion direction
m     =      1; % spectral order
r_s = 3.0;        % (mm) radius of feed optic
% CCK 2017-May-30 updated after correcting an error in rowland.m

% Raytrace densities
field_den = 5;  % Number of field angles to sample per axis
ray_den = 5;   % Number of rays in pupil per axis
tot_rays = field_den^2 * ray_den^2;

phiS_resolution = 9;  % Number of slit positions
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

plot_resolution( rays_left, rays_center, rays_right, phiS, dir )


