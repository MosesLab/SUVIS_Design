function [ ] = plot_resolution( left, center, right, phi_s, dir )

% Create directory where output from this script will be stored
plot_dir = strcat(dir, 'resolution/');
mkdir(dir);

% Extract parameters of each ray
[lam_c, hx_c, hy_c, px_c, py_c, x_c, y_c, vig_c] = get_ray_data(center);
[lam_l, hx_l, hy_l, px_l, py_l, x_l, y_l, vig_l] = get_ray_data(left);
[lam_r, hx_r, hy_r, px_r, py_r, x_r, y_r, vig_r] = get_ray_data(right);

% subtract mean for accurate comparison
o_c = mean(x_c(:));
o_l = mean(x_l(:));
o_r = mean(x_r(:));
x_c = x_c - o_c;
x_l = x_l - o_l;
x_r = x_r - o_r;


% Approximately find two points on wavelength calibration curve
x1 = (mean(x_l,2) - mean(x_c,2)) / 2;
x2 = (mean(x_c,2) - mean(x_r,2)) / 2;
y1 = (lam_l(:,1) - lam_c(:,1)) / 2;
y2 = (lam_c(:,1) - lam_r(:,1)) / 2;

% Calculate calibration
cal_m = (y2 - y1) ./ (x2 - x1);

for i = 1:size(lam_c,1)
    
    % Calculate standard deviation of rays
    sigmaX_l(i) = std(x_l(i, vig_l(i,:) == 0));
    sigmaX_c(i) = std(x_c(i, vig_c(i,:) == 0));
    sigmaX_r(i) = std(x_r(i, vig_r(i,:) == 0));
    
    % Convert to wavelength units
    sigmaL_l(i) = std(cal_m(i) .* (x_l(i,vig_l(i,:) == 0) - x1(i)) + y1(i));
    sigmaL_c(i) = std(cal_m(i) .* (x_c(i,vig_c(i,:) == 0) - x1(i)) + y1(i));
    sigmaL_r(i) = std(cal_m(i) .* (x_r(i,vig_r(i,:) == 0) - x1(i)) + y1(i));  
    
    wav_l(i) = lam_l(i,1); % wavelength
    wav_c(i) = lam_c(i,1);
    wav_r(i) = lam_r(i,1);
    
    R_l(i) = 2 * sigmaL_l(i) / wav_l(i);
    R_c(i) = 2 * sigmaL_c(i) / wav_c(i);
    R_r(i) = 2 * sigmaL_r(i) / wav_r(i);
    
end

figure(1);
hold off
plot([wav_l', wav_c',wav_r'], [R_l',R_c', R_r']);
hold on

figure(3);
hold off
plot([wav_l', wav_c',wav_r'], [sigmaL_l',sigmaL_c', sigmaL_r']);
hold on

figure(2);
plot([wav_l', wav_c',wav_r'], [sigmaX_l',sigmaX_c', sigmaX_r']);

end

