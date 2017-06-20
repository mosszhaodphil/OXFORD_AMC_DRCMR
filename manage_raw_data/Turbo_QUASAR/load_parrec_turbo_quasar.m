clear all;

input_file_name = 'CRUISE_003_TurboQUASAR_EPI_7-0-2_SENSE_11_1';

[value, info] = loadParRec(input_file_name);

% 64    64    15     1    28    11     1     1     1     1     2

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

% Rescale parameters
%rescale_intercept = 0;
%rescale_slope = 5.62662;
%scale_slope = 0.000721;

n_asl = 2;
n_repeat = 1; % You should know how many repeats there are
n_shift = 2; % You should know how many shift there are

n_tis_each_repeat_shift = dynamic * cardiac_phase / (n_repeat * n_shift);
n_dynamc_each_repeat_shift = dynamic / (n_repeat * n_shift);

for i = 1 : n_asl

	dynamic_begin = 1;

	for j = 1 : n_repeat

		repeat_name = strcat('repeat_', num2str(j), '_');

		for k = 1 : n_shift

			shift_name = strcat('shift_', num2str(k), '_');

			dynamic_end = dynamic_begin + n_dynamc_each_repeat_shift - 1;

			current_volume = value(:, :, :, :, dynamic_begin : dynamic_end, :, :, :, :, :, i);

			dynamic_begin = dynamic_begin + n_dynamc_each_repeat_shift;

			% Reshape the data
			current_data_4D = reshape(current_volume, [x, y, z, n_tis_each_repeat_shift]);

			% Re-arrange TIs
			current_data_4D = group_TIs(current_data_4D, n_dynamc_each_repeat_shift, cardiac_phase);

			% Rescale the value to floating point values
			%current_data_4D = rescale_to_float(current_data_4D, rescale_intercept, rescale_slope, scale_slope);

			% Rotate the image
			%current_data_4D = permute(current_data_4D, [2 1 3 4]);
			%current_data_4D = flip(current_data_4D, 2);

			current_data_4D_save = permute(current_data_4D, [2 1 3 4]);
			% Then reverse the direction of each new axis
			%current_data_4D_save = flip(current_data_4D_save, 1);
			current_data_4D_save = flip(current_data_4D_save, 2);
			%value_save = flip(value_save, 3);

			% Equavelant transformation
			%current_data_4D = rot90(rot90(rot90(current_data_4D)));

			% Save the current data
			if(asl_mode == 1)
				if(i == 1)
					tag_or_control_name = 'control';
				end

				if(i == 2)
					tag_or_control_name = 'tag';
				end
			end

			% Save the current data
			if(asl_mode == 2)
				if(i == 1)
					tag_or_control_name = 'tag';
				end

				if(i == 2)
					tag_or_control_name = 'control';
				end
			end

			file_name = strcat(shift_name, repeat_name, tag_or_control_name, '.nii.gz');

			file_handle = make_nii(current_data_4D_save, resolution);
			% Same rotation with before
			%[file_handle, orient, pattern] = rri_orient(file_handle);
			% Select this way:
			% X: From Anterior to Posterior
			% Y: From Left to Right
			% Z: From Inferior to Superior
			save_nii(file_handle, file_name);

		end

	end

end

info


'Warning: Check orientation with MPRAGE image!!'
'Warning: The images are in NEUROLOGICAL orientation!'
'Warning: We use RADIOLOGICAL orientation in Oxford-AMC-DRCMR project!'
'Warning: Use fslorient to convert to RADIOLOGICAL orientation!'
