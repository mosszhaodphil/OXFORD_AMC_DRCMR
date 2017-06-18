function new_matrix = group_TIs(old_matrix, n_dynamics, n_tis)

	[x, y, z, t] = size(old_matrix);
	new_matrix = zeros(x, y, z, t);

	%n_dynamics = 7;
	%n_tis = 11;

	count_index = 1;
	for i = 1 : n_dynamics

		for j = 1 : n_tis

			new_matrix(:, :, :, count_index) = old_matrix(:, :, :, n_dynamics * (j - 1) + i);

			count_index = count_index + 1;
		end

	end


end
