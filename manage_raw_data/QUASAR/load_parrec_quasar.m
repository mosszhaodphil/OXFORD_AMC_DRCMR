clear all;

input_file_name = '20110125x1_11_1';

[data, info] = loadParRec(input_file_name);

size(data)
[x, y, z, fourth_dim, fifth_dim, cardic_phase] = size(data);
% 64    64    7     1    84    13

t = fourth_dim * fifth_dim * cardic_phase;

current_data_4D = reshape(data, [x, y, z, t]);

%current_data_4D = rot90(rot90(rot90(current_data_4D)));
% Now deal with the orientation of the image
current_data_4D_save = permute(current_data_4D, [2 1 3 4]);
% Then reverse the direction of each new axis
%current_data_4D_save = flip(current_data_4D_save, 1);
current_data_4D_save = flip(current_data_4D_save, 2);
%value_save = flip(value_save, 3);

% Record the resolution of the image
res_x = info.imgdef.pixel_spacing_x_y.uniq(1);
res_y = info.imgdef.pixel_spacing_x_y.uniq(2);
res_z = info.imgdef.slice_thickness_in_mm.uniq(1);

resolution = [res_x, res_y, res_z]; % You should know the resolution of the dat

% Save original file
file_handle = make_nii(current_data_4D_save, resolution);
file_name = strcat(input_file_name, '_new.nii.gz');
save_nii(file_handle, file_name);


'Warning: Make sure structural image has the same orientation (Left-Right direction)!'
