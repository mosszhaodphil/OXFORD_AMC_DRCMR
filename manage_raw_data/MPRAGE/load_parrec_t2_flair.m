input_file_name = 'Cruise_104_magnitude_7_4';

[data, info] = loadParRec(input_file_name);

size(data)

[x, y, z] = size(data);
% 288 288 245

% Rearrange data
% This part is equavalent to using the following FSL command
% fslswapdim <input_image> -z -y -x <output_image>
% First permute the axis
data_save = permute(data, [3 2 1]);
% Then reverse the direction of each new axis
data_save = flip(data_save, 1);
data_save = flip(data_save, 2);
data_save = flip(data_save, 3);

% Get resolution imformation
res_x = info.imgdef.pixel_spacing_x_y.uniq(1);
res_y = info.imgdef.pixel_spacing_x_y.uniq(2);
res_z = info.imgdef.slice_thickness_in_mm.uniq(1);
resolution = [res_x, res_y, res_z]; % You should know the resolution of the data
resolution = [0.56, 0.978, 0.978]; % Hard coded value for T1

% Save original file
file_handle = make_nii(data_save, resolution);
file_name = strcat(input_file_name, '.nii.gz');
file_name = strcat('T2_FLAIR', '.nii.gz');
save_nii(file_handle, file_name);

'Warning: Make sure structural image has the same orientation!'
'Warning: Check T1 or T2 resolution!'
'Warning: The image is in NEUROLOGICAL orientation!'
'Warning: We use RADIOLOGICAL orientation in Oxford-AMC-DRCMR project!'
'Warning: Use fslorient to convert to RADIOLOGICAL orientation!'
