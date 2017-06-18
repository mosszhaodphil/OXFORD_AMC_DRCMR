

function inter_leave_control_tag(input_file_1, input_file_2, output_file, resolution)

	handle_1 = load_nii(strcat(input_file_1, '.nii.gz'));
	handle_2 = load_nii(strcat(input_file_2, '.nii.gz'));

	matrix_1 = handle_1.img;
	matrix_2 = handle_2.img;

	[x, y, z, t] = size(matrix_1);

	matrix_out = zeros(x, y, z, 2 * t);

	for i = 1 : t
		matrix_out(:, :, :, 2 * i - 1) = matrix_1(:, :, :, i);
		matrix_out(:, :, :, 2 * i) = matrix_2(:, :, :, i);
	end

	handle_out = make_nii(matrix_out, resolution);

	save_nii(handle_out, strcat(output_file, '.nii.gz'));

end

