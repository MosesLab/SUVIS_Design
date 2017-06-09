% Design using a custom grating
offset = 4.1*pi/180; % Offset detector from normal
%phi_s =  offset + 33*pi/180; % (rad) angular position of slit     on Rowland Circle
phi_s =  offset + 22*pi/180;
%phi_s =  offset + 10*pi/180;
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

field_den = 5;
ray_den = 31;

% Construct call to Zemax
path = "..\c++\CppStandaloneApplication\Debug\CppStandaloneApplication ";
args = strcat(num2str(phi_s), " ", num2str(phi_g), " ", num2str(phi_d), " ", num2str(R_g), " ", ...
    num2str(w_g), " ", num2str(d_s), " ", num2str(d_g), " ", num2str(d_d), " ", num2str(N_d), ...
    " ", num2str(m), " ", num2str(r_s)," ", num2str(field_den), " ", num2str(ray_den));

% Call zemax c++ code with the above arguments
system(char(strcat(path, args)));

% Construct spot diagram
zemax_spot

