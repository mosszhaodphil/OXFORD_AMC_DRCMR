# oxford_asl -i baseline_diff_avg -o output -m M0_brain_calib --wp --casl --tis 3.6 --bolus 1.8

# Generate mask
fslmaths baseline_control -Tmean baseline_control_mean
bet baseline_control_mean baseline_control_brain
fslmaths baseline_control_brain -bin mask

# Take tag control difference
fslmaths baseline_tag -sub baseline_control baseline_diff

# Average all repeats
fslmaths baseline_diff -Tmean baseline_diff_avg

# 1 White paper method
# Calculate the CBF factor exp(1.8/1.65) * 0.9 * 6000 / (2 * 0.85 * 1.65 * (1 - exp(-1.8/1.65)))
# Result is 
# 8630
cbf_factor=8630
# Compute CBF here
fslmaths baseline_diff_avg -mul $cbf_factor -div M0_brain_calib -mas M0_brain_calib cbf_wp


# 2 Model fitting method
basil -i baseline_diff -m mask -o output_basil -@ basil_options.txt
# Calibration
# Inversion efficiency
alpha=0.85
fslmaths output_basil/step1/mean_ftiss -div M0_brain_calib -div $alpha -mul 6000 output_basil/step1/cbf_basil
