input_file_name = 'CRUISE-001_ASL-PSEUDO_1800_SENSE_13_1';

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
% Rescale parameters
%rescale_intercept = 0;
%rescale_slope = 5.62662;
%scale_slope = 0.000721;

n_asl = 2;
dynamic_begin = 1;
dynamic_end = 35;
n_repeat = dynamic_end - dynamic_begin + 1; % You should know how many repeats there are
n_shift = 1; % You should know how many shift there are

n_tis_each_repeat_shift = dynamic * cardiac_phase / (n_repeat * n_shift);
n_dynamc_each_repeat_shift = dynamic / (n_repeat * n_shift);

for i = 1 : n_asl

	current_volume = value(:, :, :, :, dynamic_begin : dynamic_end, :, :, :, :, :, i);

	current_data_4D = reshape(current_volume, [x, y, z, n_repeat]);


	% Rotate the image
	% current_data_4D = rot90(rot90(rot90(current_data_4D)));

	current_data_4D = permute(current_data_4D, [2 1 3 4]);
	% Then reverse the direction of each new axis
	%current_data_4D = flip(current_data_4D, 1);
	current_data_4D = flip(current_data_4D, 2);
	%current_data_4D = flip(current_data_4D, 3);

	file_name = 'baseline_';

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

	file_name = strcat(file_name, tag_or_control_name, '.nii.gz');

	file_handle = make_nii(current_data_4D, resolution);
	% Same rotation with before
	%[file_handle, orient, pattern] = rri_orient(file_handle);
	% Select this way:
	% X: From Anterior to Posterior
	% Y: From Left to Right
	% Z: From Inferior to Superior
	save_nii(file_handle, file_name);


end

n_asl = 2;
dynamic_begin = 36;
dynamic_end = 140;
n_repeat = dynamic_end - dynamic_begin + 1; % You should know how many repeats there are
n_shift = 1; % You should know how many shift there are


for i = 1 : n_asl

	current_volume = value(:, :, :, :, dynamic_begin : dynamic_end, :, :, :, :, :, i);

	current_data_4D = reshape(current_volume, [x, y, z, n_repeat]);


	% Rotate the image
	% current_data_4D = rot90(rot90(rot90(current_data_4D)));

	current_data_4D = permute(current_data_4D, [2 1 3 4]);
	% Then reverse the direction of each new axis
	%current_data_4D = flip(current_data_4D, 1);
	current_data_4D = flip(current_data_4D, 2);
	%current_data_4D = flip(current_data_4D, 3);

	file_name = 'acetazolamide_';

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

	file_name = strcat(file_name, tag_or_control_name, '.nii.gz');

	file_handle = make_nii(current_data_4D, resolution);
	% Same rotation with before
	%[file_handle, orient, pattern] = rri_orient(file_handle);
	% Select this way:
	% X: From Anterior to Posterior
	% Y: From Left to Right
	% Z: From Inferior to Superior
	save_nii(file_handle, file_name);


end


%info
'Warning: The images are in NEUROLOGICAL orientation!'
'Warning: We use RADIOLOGICAL orientation in Oxford-AMC-DRCMR project!'
'Warning: Use fslorient to convert to RADIOLOGICAL orientation!'

% Interleave the control and tag images