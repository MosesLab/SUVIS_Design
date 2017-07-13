% FURST design using a custom grating
% 2017-07-13 CCK modified to fit skins. Need a grating spec update.
offset = 4.1*pi/180; % Offset detector from normal
phiS_max =  offset + 28.4*pi/180; % (rad) angular position of slit on Rowland Circle
phiS_min =  offset + 10*pi/180;
phi_g = pi-offset; % (rad) angular position of grating  on Rowland Circle
phi_d = offset; % (rad) angular position of detector on Rowland Circle
R_g   =   1500.0; % (mm)  grating radius
w_g   =   200.0; % (mm) grating width
d_s   =  15e-3; % (mm) width of slit
d_g   = 1/1970; % (mm) grating groove period
d_d   =  15e-3; % (mm) detector pixel spacing
N_d   =   2048; % Number of detector pixels in the dispersion direction
m     =      1; % spectral order
r_s = 3.0;        % (mm) radius of feed optic
N_phi = 9;     % Number of slit positions
% Choose all slit locations
delta_phi = (phiS_max - phiS_min)/(N_phi-1);
phiS_array = phiS_min:delta_phi:phiS_max % Array of slit positions

% Directory for outputs
outdir = [' /tmp/', strcat('FURST', datestr(clock,'yyyymmddTHHMMSS')), '/'];
system(strcat('mkdir', outdir));
