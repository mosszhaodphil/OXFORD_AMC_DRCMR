clear all;

input_file_name = 'CRUISE-001_NOCRUSH_M0_SENSE_14_1';

[value, info] = loadParRec(input_file_name);

% 80    80    19     1    140    1     1     1     1     1     2

% [x, y, z, unknown, dynamics, cardic_phase, asl] = size(value);

size(value)

x = size(value, 1);
y = size(value, 2);
z = size(value, 3);
dynamic = size(value, 5); % Number of 
cardiac_phase = size(value, 6); % Number of TIs in each dynamic
asl_mode = size(value, 11);

res_x = info.imgdef.pixel_spacing_x_y.uniq(1);
res_y = info.imgdef.pixel_spacing_x_y.uniq(2);
res_z = info.imgdef.slice_thickness_in_mm.uniq(1);

resolution = [res_x, res_y, res_z]; % You should know the resolution of the data

%value = rot90(rot90(rot90(value)));

% Now deal with the orientation of the image
value_save = permute(value, [2 1 3]);
% Then reverse the direction of each new axis
%value_save = flip(value_save, 1);
value_save = flip(value_save, 2);
%value_save = flip(value_save, 3);

file_name = strcat('M0', '.nii.gz');

file_handle = make_nii(value_save, resolution);
% Same rotation with before
%[file_handle, orient, pattern] = rri_orient(file_handle);
% Select this way:
% X: From Anterior to Posterior
% Y: From Left to Right
% Z: From Inferior to Superior
save_nii(file_handle, file_name);

%info
'Warning: The image is in NEUROLOGICAL orientation!'
'Warning: We use RADIOLOGICAL orientation in Oxford-AMC-DRCMR project!'
'Warning: Use fslorient to convert to RADIOLOGICAL orientation!'
