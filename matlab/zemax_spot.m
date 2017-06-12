meta_file = fopen('rays/meta.dat');
ray_file = fopen('rays/rays.dat');

% Read in metadata
wav_0 = fread(meta_file,1,'double');
wav_1 = fread(meta_file,1,'double');
wav_2 = fread(meta_file,1,'double');
num_rays = fread(meta_file,1,'int32')


% Read in ray data
rays = fread(ray_file, [7, num_rays], 'double');

fclose(meta_file);
fclose(ray_file);

lam = rays(1,:);
hx = rays(2,:);
hy = rays(3,:);
px = rays(4,:);
py = rays(5,:);
x = rays(6,:);  % Array of x-coordinates of rays on detector
y = rays(7,:);  % Array of y-coordinates of rays on detector

i_0 = find(lam == wav_0);
i_1 = find(lam == wav_1);
i_2 = find(lam == wav_2);
x_0 = x(i_0);
x_1 = x(i_1);
x_2 = x(i_2);
y_0 = y(i_0);
y_1 = y(i_1);
y_2 = y(i_2);


pt_sz = 30;
field_color = hx(i_0);
scatter(x_0,y_0,pt_sz, hx(i_0),'filled')

rms(x_0)

%scatter(x(hx==-1 & hy==-1 & wav == wav_0),y(hx==-1 & hy==-1 & wav == wav_0),pt_sz,px(hx==-1 & hy==-1 & wav == wav_0),'filled')