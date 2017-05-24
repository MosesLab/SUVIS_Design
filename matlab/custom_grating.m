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


figure(1)
[lambdas, deltas] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
title('Innermost slit position')
xlabel('x (mm)')
ylabel('y (mm)')
print('custom_grating_layout_s1.pdf','-dpdfwrite')

figure(2)
hold off
plot(lambdas*1e6)
hold on
title('Innermost slit position')
xlabel('pixel')
ylabel('wavelength (nm)')
print('custom_grating_lambdas_s1.pdf','-dpdfwrite')

figure(3)
hold off
plot(lambdas*1e6, lambdas ./ deltas)
hold on
title('Innermost slit position')
xlabel('wavelength (nm)')
ylabel('effective resolving power')
print('custom_grating_resolution_s1.pdf','-dpdfwrite')

phi_s = 33.5*pi/180 % increase to get up to 2000 Å
figure(4)
[lambdas, deltas] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
plot([850,-850,-850,850],[-30,-30,420,420],'k:')
title('Outermost slit position')
xlabel('x (mm)')
ylabel('y (mm)')
print('custom_grating_layout_sn.pdf','-dpdfwrite')

figure(5)
hold off
plot(lambdas*1e6)
hold on
title('Outermost slit position')
xlabel('pixel')
ylabel('wavelength (nm)')
print('custom_grating_lambdas_sn.pdf','-dpdfwrite')

figure(6)
hold off
plot(lambdas*1e6, lambdas ./ deltas)
hold on
title('Outermost slit position')
xlabel('wavelength (nm)')
ylabel('effective resolving power')
print('custom_grating_resolution_sn.pdf','-dpdfwrite')
