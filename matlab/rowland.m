% Rowland Circle Spectrometer nominal wavelength calibration on detector
function [lambdas, deltas, delta_diffract, delta_pix, delta_slit] = rowland(phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m)
% INPUT PARAMETERS:
%  phi_s = angular position of   slit   on Rowland circle (rad)
%  phi_g = angular position of grating  on Rowland circle (rad)
%  phi_d = angular position of detector on Rowland circle (rad)
%  R_g = grating radius
%  w_g = grating width (diameter if circular)
%  d_s = width of slit
%  d_g = grating groove period
%  d_d = detector pixel spacing
%  N_d = Number of detector pixels in the dispersion direction
%  m = spectral order
% OUTPUTS:
%  lambdas = wavelengths at each pixel
%  deltas = wavelength uncertainty interval associated with each pixel
%  delta_diffract = wavelength uncertainty due to diffraction
%  delta_pix = wavelength uncertainty due to pixel size
%  delta_slit = wavelength uncertainty due to slit size
% OUTPUTS HAVE THE SAME UNITS AS THE INPUT DISTANCES, WHICH ARE ASSUMED
% TO BE ALL THE SAME.
% CCK 2017-May-30 corrected serious error in calculation of betas (thanks to Roy).
% CCK 2017-May-31 new outputs delta_diffract, delta_pix, delta_slit are the RSS'd components of deltas.

RR = R_g/2; % radius of Rowland circle
N_g = w_g/d_g; % number of illuminated rulings

% Cartesian coordinates of grating, slit, and detector (centers).
phi_g;
phi_s;
phi_d;
x_g = RR .* cos(phi_g);
y_g = RR .* sin(phi_g);
x_s = RR .* cos(phi_s);
y_s = RR .* sin(phi_s);
x_d = RR .* cos(phi_d);
y_d = RR .* sin(phi_d);

% Displacement vector from grating to slit
x_gs = (x_s - x_g);
y_gs = (y_s - y_g);

% Grating normal unit vector
x_gn = (-x_g)/RR;
y_gn = (-y_g)/RR;

% Alpha angle at grating center (inverting the cross product)
alpha = angle2d( x_gn, y_gn, x_gs, y_gs );
alpha_deg = alpha * 180/pi


% Cartesian coordinates of detector pixels
w_d = (N_d-1) .* d_d; % Detector width (center of first pixel to center of last pixel)
s = (0:(N_d-1)) .* d_d - (w_d/2); % Coordinate along detector, with origin at detector center.
   % Positive s correlates with positive phi.
x_p = x_d - s .* sin(phi_d); % pixel x array
y_p = y_d + s .* cos(phi_d); % pixel y array

% Array of beta angles for all of the pixels
betas = angle2d( x_gn, y_gn, x_p - x_g, y_p - y_g );
min_beta_deg = min(betas) * 180/pi
max_beta_deg = max(betas) * 180/pi
% beta = angle2d(x_gn, y_gn, x_gd, y_gd)

% Array of wavelengths, using the grating equation
lambdas = (d_g ./ m) .* ( sin(alpha) + sin(betas) );

% Array of delta lambda, using RSS of diffraction limit, pixels, and slit width.
% There is no aberration in this calculation!!
betas_ext = [2*betas(1)-betas(2), betas, 2*betas(end)-betas(end-1)];  
   % Extrapolate betas array one element each way.
Delta_betas = 0.5*( betas_ext(3:end) - betas_ext(1:end-2) ); % range of betas subtended by each pixel
Delta_alpha = d_s/sqrt(x_gs.^2 + y_gs.^2); % range of alphas subtended by slit
delta_diffract = lambdas/N_g;                   % diffraction is governed by illuminated rulings.
delta_slit = (d_g/m)*cos(alpha) .* Delta_alpha; % projected slit size in wavelength units
delta_pix = (d_g/m)*cos(betas) .* Delta_betas;  % pixel wavelength interval
deltas = sqrt( delta_diffract.^2  + delta_slit.^2 + delta_pix.^2 );   % RSS wavelength uncertainty at each pixel

% Coordinates to trace Rowland circle
phi_RS = 0:0.01:2*pi;
x_RS = RR*cos(phi_RS);
y_RS = RR*sin(phi_RS);

% Plot optical layout
hold off
plot([x_s],[y_s],'+k')
hold on
% Grating surface plot, using coordinates centered at grating center of curvature
x0_g = -x_g; % center of curvature of grating
y0_g = -y_g; % center of curvature of grating
subtent_g = atan(w_g/R_g);
thetas_g = [(-subtent_g/2):0.01:0, 0:0.01:(subtent_g/2)];
thetas_g = thetas_g + atan((y_g-y0_g)/(x_g-x0_g));
xs_g = x0_g - R_g .* cos(thetas_g);
ys_g = y0_g - R_g .* sin(thetas_g);
plot(xs_g, ys_g, 'g-', 'LineWidth',5)
%plot([x_g],[y_g],'gx')
plot(x_p,y_p,'-b','LineWidth',5)
%plot([x_s,x_g,x_d],[y_s,y_g,y_d],'k')
plot(x_RS,y_RS,'--k')
legend('slit','grating','detector','Rowland circle')
axis equal
