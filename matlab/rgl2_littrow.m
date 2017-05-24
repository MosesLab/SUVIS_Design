% Abney mounting with Richardson Grating cat no  52053BK-*-787D
% This is a ruled grating, blazed for 150nm.

% Moved detector off normal to get a more compact instrument; almost fits in 17".

off_norm = 0.035 % Move detector off normal
phi_s =    0.075 % (rad) angular position of slit     on Rowland Circle
phi_g =     pi-off_norm % (rad) angular position of grating  on Rowland Circle
phi_d =      0+off_norm % (rad) angular position of detector on Rowland Circle
R_g   = 2998.3 % (mm)  grating radius
w_g   =     50 % (mm) grating ruled width
d_s   =  10e-3 % (mm) width of slit
d_g   = 1/1200 % (mm) grating groove period
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

phi_s = 0.285 % increase to get up to 2000 Å
figure(4)
[lambdas, deltas] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
xlabel('x (mm)')
ylabel('y (mm)')

figure(5)
hold off
plot(lambdas*1e7)
hold on
xlabel('pixel')
ylabel('wavelength (Å)')

figure(6)
hold off
plot(lambdas*1e7, lambdas ./ deltas)
hold on
xlabel('wavelength (Å)')
ylabel('resolving power')
