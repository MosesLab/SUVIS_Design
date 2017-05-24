% Design using a custom grating
offset = 4*pi/180 % Offset detector from normal
phi_s =  10*pi/180 % (rad) angular position of slit     on Rowland Circle
phi_g = pi-offset % (rad) angular position of grating  on Rowland Circle
phi_d = offset % (rad) angular position of detector on Rowland Circle
R_g   =   1500 % (mm)  grating radius
w_g   =     75 % grating diameter
d_s   =  15e-3 % (mm) width of slit
d_g   = 1/2400 % (mm) grating groove period
d_d   =  15e-3 % (mm) detector pixel spacing
N_d   =   2048 % Number of detector pixels in the dispersion direction
m     =      1 % spectral order

args = [phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m]
draw_zemax(args)