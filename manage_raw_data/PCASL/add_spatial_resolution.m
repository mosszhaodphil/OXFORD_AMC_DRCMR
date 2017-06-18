% This function adds spatial resolution to nifti file


function add_spatial_resolution(input_file_name, output_file_name, x_mm, y_mm, z_mm)

	file_handle = load_nii(strcat(input_file_name, '.nii.gz'));

	file_handle.hdr.dime.pixdim = [1.00 x_mm y_mm z_mm 1.00 0 0 0];

	save_nii(file_handle, strcat(output_file_name, '.nii.gz'));


end
