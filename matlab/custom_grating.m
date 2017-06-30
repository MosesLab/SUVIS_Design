% Design using a custom grating as specified in custom_grating_hdr.m :
custom_grating_hdr

% CCK 2017-May-30 updated after correcting an error in rowland.m
% CCK 2017-Jun-01 added error budget for aberration, width one pixel, on the assumption that
%  deltas as returned by rowland.m essentially contains two such terms. My reasoning is that the
%  diffraction term is negligible, and I have made my slit 1 pixel wide.
% CCK 2017-Jun-27 attempting to resolve differences with Roy's custom_grating_zemax.m; have
%  imported his parameters and commented out my current ones.
% CCK 2017-Jun-30 put parameters into a header shared by this program and custom_grating_zemax.m

figure(1)
[lambdas, deltas, delta_diffract, delta_pix, delta_slit] = rowland(phiS_min, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
deltas = deltas * sqrt(3/2);
title('Innermost slit position')
xlabel('x (mm)')
ylabel('y (mm)')
print([outdir,'custom_grating_layout_s1.pdf'],'-dpdfwrite')

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
print([outdir,'custom_grating_resolution_s1.pdf'],'-dpdfwrite')

figure(4)
[lambdas, deltas, delta_diffract, delta_pix, delta_slit] = rowland(phiS_max, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m);
deltas = deltas * sqrt(3/2);
plot([850,-850,-850,850],[-30,-30,420,420],'k:')
title('Outermost slit position')
xlabel('x (mm)')
ylabel('y (mm)')
print([outdir,'custom_grating_layout_sn.pdf'],'-dpdfwrite')

figure(5)
hold off
plot(lambdas*1e6)
hold on
title('Outermost slit position')
xlabel('pixel')
ylabel('wavelength (nm)')
print([outdir,'custom_grating_lambdas_sn.pdf'],'-dpdfwrite')

figure(6)
hold off
plot(lambdas*1e6, lambdas ./ deltas)
hold on
title('Outermost slit position')
xlabel('wavelength (nm)')
ylabel('effective resolving power')
print([outdir,'custom_grating_resolution_sn.pdf'],'-dpdfwrite')


figure(2)
plot(delta_pix*1e9,'k')
plot(delta_slit*1e9,'m')
legend('Innermost: pixels','Innermost: slit','Outermost: pixels','Outermost: slit')
print([outdir,'custom_grating_blur.pdf'],'-dpdfwrite')
