function [ ] = plot_resolution( left, center, right, phi_s, dir, d_d )

% Create directory where output from this script will be stored
plot_dir = strcat(dir, 'resolution/');
mkdir(strcat(dir, plot_dir));

% Extract parameters of each ray
[lam_c, hx_c, hy_c, px_c, py_c, x_c, y_c, vig_c] = get_ray_data(center);
[lam_l, hx_l, hy_l, px_l, py_l, x_l, y_l, vig_l] = get_ray_data(left);
[lam_r, hx_r, hy_r, px_r, py_r, x_r, y_r, vig_r] = get_ray_data(right);

% subtract mean for accurate comparison
o_c = mean(x_c(:));
o_l = mean(x_l(:));
o_r = mean(x_r(:));
% x_c = x_c - o_c;
% x_l = x_l - o_l;
% x_r = x_r - o_r;

x_l = x_l * 1e3;    % Convert detector position to microns
x_c = x_c * 1e3;
x_r = x_r * 1e3;

d_d = 1e3 * d_d;    % Convert pixel size to microns

lam_l = lam_l * 1e3;    % Convert wavelength to nm
lam_c = lam_c * 1e3;
lam_r = lam_r * 1e3;


% Approximately find two points on wavelength calibration curve
x1 = (mean(x_l,2) + mean(x_c,2)) / 2;
x2 = (mean(x_c,2) + mean(x_r,2)) / 2;
y1 = (lam_l(:,1) + lam_c(:,1)) / 2;
y2 = (lam_c(:,1) + lam_r(:,1)) / 2;

% Calculate calibration
cal_m = (y2 - y1) ./ (x2 - x1);

% Calculate std deviation of pixel size
sigmaP = d_d / sqrt(12);    % \frac{\int_{-d/2}^{d/2} x^2 dx}{\int_{-d/2}^{d/2} dx} (microns)

for i = 1:size(lam_c,1)
    
    % Calculate standard deviation of rays
%     sigmaX_l(i) = sqrt(std(x_l(i, vig_l(i,:) == 0))^2 + sigmaP^2);
%     sigmaX_c(i) = sqrt(std(x_c(i, vig_c(i,:) == 0))^2 + sigmaP^2);
%     sigmaX_r(i) = sqrt(std(x_r(i, vig_r(i,:) == 0))^2 + sigmaP^2);
    sigmaX_l(i) = std(x_l(i, vig_l(i,:) == 0));
    sigmaX_c(i) = std(x_c(i, vig_c(i,:) == 0));
    sigmaX_r(i) = std(x_r(i, vig_r(i,:) == 0));
    
    % Convert to wavelength units
    sigmaL_l(i) = sqrt(std(cal_m(i) .* (x_l(i,vig_l(i,:) == 0) - x1(i)) + y1(i))^2 + ...
        (((cal_m(i) * (o_l - x1(i)) + y1(i)) - (cal_m(i) * (o_l + d_d - x1(i)) + y1(i)))/sqrt(12))^2);
    sigmaL_c(i) = sqrt(std(cal_m(i) .* (x_c(i,vig_c(i,:) == 0) - x1(i)) + y1(i))^2 + ...
        (((cal_m(i) * (o_c - x1(i)) + y1(i)) - (cal_m(i) * (o_c + d_d - x1(i)) + y1(i)))/sqrt(12))^2);
    sigmaL_r(i) = sqrt(std(cal_m(i) .* (x_r(i,vig_r(i,:) == 0) - x1(i)) + y1(i))^2 + ...
        (((cal_m(i) * (o_r - x1(i)) + y1(i)) - (cal_m(i) * (o_r + d_d - x1(i)) + y1(i)))/sqrt(12))^2);
    
    
    wav_l(i) = lam_l(i,1); % wavelength
    wav_c(i) = lam_c(i,1);
    wav_r(i) = lam_r(i,1);
    
    R_l(i) = 1 / (2 * sigmaL_l(i) / wav_l(i));
    R_c(i) = 1 / (2 * sigmaL_c(i) / wav_c(i));
    R_r(i) = 1 / (2 * sigmaL_r(i) / wav_r(i));
    
end

figure(7);
hold off
plot([wav_l', wav_c',wav_r'], [R_l',R_c', R_r']);
hold on
xlabel('wavelength (nm)');
ylabel('Resolving Power');
legend(sprintf('center offset = %0.3f µm\n ', o_l),sprintf('center offset = %0.3f µm\n', o_c),sprintf('center offset = %0.3f µm\n', o_r),'Location','NorthEast')
print(sprintf('%sresolution_vs_wavelength.eps', plot_dir), '-depsc');
print(sprintf('%sresolution_vs_wavelength.png', plot_dir), '-dpng');

figure(8);
hold off
plot([wav_l', wav_c',wav_r'], [sigmaL_l',sigmaL_c', sigmaL_r']);
hold on
title('Spot Standard Deviation (wavelength units) vs. Wavelength');
xlabel('wavelength (nm)');
ylabel('standard deviation (nm) ');
legend(sprintf('center offset = %0.3f µm\n', o_l),sprintf('center offset = %0.3f µm\n', o_c),sprintf('center offset = %0.3f µm\n', o_r),'Location','SouthEast')
print(sprintf('%ssigmaL_vs_wavelength.eps', plot_dir), '-depsc');
print(sprintf('%ssigmaL_vs_wavelength.png', plot_dir), '-dpng');

figure(9);
hold off
plot([wav_l', wav_c',wav_r'], [sigmaX_l',sigmaX_c', sigmaX_r']);
hold on
title('Spot Standard Deviation (detector units) vs. Wavelength');
xlabel('wavelength (nm)');
ylabel('standard deviation (microns) ');
legend(sprintf('center offset = %0.3f µm\n', o_l),sprintf('center offset = %0.3f µm\n', o_c),sprintf('center offset = %0.3f µm\n', o_r),'Location','SouthEast')
print(sprintf('%ssigmaX_vs_wavelength.eps', plot_dir), '-depsc');
print(sprintf('%ssigmaX_vs_wavelength.png', plot_dir), '-dpng');

end

