

function display_turbo_quasar_z_axis_perfusion_map(file_name, z_begin, z_end)

	file_handle = load_nii(strcat(file_name, '.nii.gz'));
	data = rot90(file_handle.img);

	[x, y, z] = size(data);

	num_of_maps = z_end - z_begin + 1;

	for i = z_begin : 1 : z_end

		im = data(:, :, i);

		current_figure = figure;

		imagesc(im);

		colormap hot;

		caxis([0 90]);
		set(gca, 'XTick', []);
		set(gca, 'YTick', []);

		hold on;

		%imtool(im);

		% Set Figure position
		figure_position = [2 2 21.05 21.05];
		current_figure.Units = 'centimeters';
		current_figure.Position = figure_position;

		file_name = strcat('z_', num2str(i));

		% Output image
		print(file_name,'-dpng','-r300');

	end;
end

