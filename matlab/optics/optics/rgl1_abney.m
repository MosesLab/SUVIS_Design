% Test of rowland.m using Abney mounting with Richardson Grating cat no 52A02BF-*-556C

phi_s =    0.4 % (rad) angular position of slit     on Rowland Circle
phi_g =     pi % (rad) angular position of grating  on Rowland Circle
phi_d =      0 % (rad) angular position of detector on Rowland Circle
R_g   =    750 % (mm)  grating radius
w_g   =     75 % grating diameter
d_s   =  10e-3 % (mm) width of slit
d_g   = 1/1500 % (mm) grating groove period
d_d   =  15e-3 % (mm) detector pixel spacing
N_d   =   2048 % Number of detector pixels in the dispersion direction
m     =      1 % spectral order


figure(1)
[lambdas, deltas] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
xlabel('x (mm)')
ylabel('y (mm)')

figure(2)
hold off
plot(lambdas*1e7)
hold on
xlabel('pixel')
ylabel('wavelength (Å)')

figure(3)
hold off
plot(lambdas*1e7, lambdas ./ deltas)
hold on
xlabel('wavelength (Å)')
ylabel('resolving power')
