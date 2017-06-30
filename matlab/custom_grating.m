% Design using a custom grating
offset = 4.1*pi/180; % Offset detector from normal
phi_s =  offset + 10*pi/180; % (rad) angular position of slit     on Rowland Circle
phi_g = pi-offset; % (rad) angular position of grating  on Rowland Circle
phi_d = offset; % (rad) angular position of detector on Rowland Circle
R_g   =   1500.0; % (mm)  grating radius
w_g   =    200.0; % (mm) grating width
d_s   =  15e-3; % (mm) width of slit
d_g   = 1/2160; % (mm) grating groove period
d_d   =  15e-3; % (mm) detector pixel spacing
N_d   =   2048; % Number of detector pixels in the dispersion direction
m     =      1; % spectral order
r_s = 3.0;        % (mm) radius of feed optic

% CCK 2017-May-30 updated after correcting an error in rowland.m
% CCK 2017-Jun-01 added error budget for aberration, width one pixel, on the assumption that
%  deltas as returned by rowland.m essentially contains two such terms. My reasoning is that the
%  diffraction term is negligible, and I have made my slit 1 pixel wide.
% CCK 2017-Jun-27 attempting to resolve differences with Roy's custom_grating_zemax.m; have
%  imported his parameters and commented out my current ones.

figure(1)
[lambdas, deltas, delta_diffract, delta_pix, delta_slit] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
deltas = deltas * sqrt(3/2);
title('Innermost slit position')
xlabel('x (mm)')
ylabel('y (mm)')
print('custom_grating_layout_s1.pdf','-dpdfwrite')

figure(2)
hold off
plot(delta_pix*1e9,'k')
hold on
plot(delta_slit*1e9,'b')
title('Wavelength Blurring Terms')
xlabel('pixel')
ylabel('\Delta\lambda (pm)')

figure(3)
hold off
plot(lambdas*1e6, lambdas ./ deltas)
hold on
title('Innermost slit position')
xlabel('wavelength (nm)')
ylabel('effective resolving power')
print('custom_grating_resolution_s1.pdf','-dpdfwrite')

%phi_s = 32*pi/180 % increase to get up to 2000 Å
phi_s = offset + 33*pi/180; % increase to get up to 2000 Å  CCK 2017-Jun-27
figure(4)
[lambdas, deltas, delta_diffract, delta_pix, delta_slit] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
deltas = deltas * sqrt(3/2);
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


figure(2)
plot(delta_pix*1e9,'k')
plot(delta_slit*1e9,'m')
legend('Innermost: pixels','Innermost: slit','Outermost: pixels','Outermost: slit')
print('custom_grating_blur.pdf','-dpdfwrite')
