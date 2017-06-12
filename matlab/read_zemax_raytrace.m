function [ left, center, right ] = read_zemax_raytrace( )

    % Open temporaray files containing raytrace data
    meta_file = fopen('rays/meta.dat');
    ray_file = fopen('rays/rays.dat');

    % Read in metadata
    wav_0 = fread(meta_file,1,'double');
    wav_1 = fread(meta_file,1,'double');
    wav_2 = fread(meta_file,1,'double');
    num_rays = fread(meta_file,1,'int32');

    % Read in ray data
    rays = fread(ray_file, [8, num_rays], 'double');
    
    % select column with wavelengths
    lam = rays(1,:);

    % Ray data is arranged with center, left, right data. Reshape into separate
    % arrays
    c = rays(:, lam == wav_0);
    l = rays(:, lam == wav_1);
    r = rays(:, lam == wav_2);
    
    center = reshape(c, 8, 1, []);
    left = reshape(l, 8, 1, []);
    right = reshape(r, 8, 1, []);
    
end

