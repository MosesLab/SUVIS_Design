function [ ] = build_zemax_model( phi_s, phi_g, phi_d, R_g, w_g, d_s, d_g, d_d, N_d, m, r_s, field_den, ray_den )

% Construct call to Zemax
path = "..\c++\CppStandaloneApplication\Debug\CppStandaloneApplication ";
args = strcat(num2str(phi_s), " ", num2str(phi_g), " ", num2str(phi_d), " ", num2str(R_g), " ", ...
    num2str(w_g), " ", num2str(d_s), " ", num2str(d_g), " ", num2str(d_d), " ", num2str(N_d), ...
    " ", num2str(m), " ", num2str(r_s)," ", num2str(field_den), " ", num2str(ray_den));

% Call zemax c++ code with the above arguments
system(char(strcat(path, args)));

end

