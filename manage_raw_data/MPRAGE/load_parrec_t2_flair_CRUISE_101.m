clear all;

% This image was scanned/planned coronal instead of sagittal,
% there was a mistake in the clinical protocol which we fixed after subject 101.
% But if you look in the anatomical folder the "T1" is the flair image,
% just named t1 for compatibility with an analysis pipeline for ASL we are using.
% That one has been resliced to 1.5 isotropic voxels for all subjects so that might make it easier for registration.

input_file_name = 'CRUISE_101_3d_flair_SENSE_7_1';

[data, info] = loadParRec(input_file_name);

size(data)

[x, y, z] = size(data);
% 288 288 245

data_backup = data;

% First part of the data
data_new = data_backup(:, :, :, :, :, :, 1);

size(data_new)

% Rearrange data
% This part is equavalent to using the following FSL command
% fslswapdim <input_image> -z -y -x <output_image>
% First permute the axis
data_save = data_new;
data_save = permute(data_new, [2 1 3]);
%data_save = permute(data_new, [3 2 1]);
% Then reverse the direction of each new axis
data_save = flip(data_save, 1);
data_save = flip(data_save, 2);
%data_save = flip(data_save, 3);

% Get resolution imformation
res_x = info.imgdef.pixel_spacing_x_y.uniq(1);
res_y = info.imgdef.pixel_spacing_x_y.uniq(2);
res_z = info.imgdef.slice_thickness_in_mm.uniq(1);
resolution = [res_x, res_y, res_z] % You should know the resolution of the data
%resolution = [0.56, 0.978, 0.978]; % Hard coded value for T1
resolution = [0.978, 0.978, 0.56]; % Hard coded value for T1

% Save original file
file_handle = make_nii(data_save, resolution);
file_name = strcat(input_file_name, '.nii.gz');
file_name = strcat('T2_FLAIR', '.nii.gz');
save_nii(file_handle, file_name);



% Second part of the data
data_new = data_backup(:, :, :, :, :, :, 2);

size(data_new)

% Rearrange data
% This part is equavalent to using the following FSL command
% fslswapdim <input_image> -z -y -x <output_image>
% First permute the axis
data_save = data_new;
data_save = permute(data_new, [2 1 3]);
%data_save = permute(data_new, [3 2 1]);
% Then reverse the direction of each new axis
data_save = flip(data_save, 1);
data_save = flip(data_save, 2);
%data_save = flip(data_save, 3);

% Get resolution imformation
res_x = info.imgdef.pixel_spacing_x_y.uniq(1);
res_y = info.imgdef.pixel_spacing_x_y.uniq(2);
res_z = info.imgdef.slice_thickness_in_mm.uniq(1);
resolution = [res_x, res_y, res_z] % You should know the resolution of the data
%resolution = [0.56, 0.978, 0.978]; % Hard coded value for T1
resolution = [0.978, 0.978, 0.56]; % Hard coded value for T1

% Save original file
file_handle = make_nii(data_save, resolution);
file_name = strcat(input_file_name, '.nii.gz');
file_name = strcat('T2_FLAIR_corrupted', '.nii.gz');
save_nii(file_handle, file_name);

