# Correct Calibration image

input_image=M0
brain_image=$input_image"_brain"
brain_image_correct=$brain_image"_correct_tr"
brain_image_median=$brain_image"_median"
brain_image_ero=$brain_image"_ero"
brain_image_calib=$brain_image"_calib"

# Brain extraction
bet $input_image $brain_image

# Correct TR for proton density image
# 10.1002/mrm.25197
# multiple_factor=(1/(1-exp(-tr/T1_of_tissue)))
# In this case, TR=4.4
# So multiple_factor = 1.0351
# Assuming T1_of_tissue = 1.3
correct_TR_factor=1.0351
fslmaths $brain_image -mul $correct_TR_factor $brain_image_correct

# Apply a median filter to correct the sharp artefact
fslmaths $brain_image_correct -fmedian $brain_image_median

# Correct partial volume effects on the edge
# 1 Erode the edge
fslmaths $brain_image_median -ero $brain_image_ero
# 2 Extrapolate back the eroded voxels
asl_file --data=$brain_image_ero --ntis=1 --mask=$brain_image --extrapolate --neighbour=5 --out=$brain_image_calib







# Now process PCASL image
alpha=0.85 # inversion efficiency

# Baseline image (low CBF)
output_dir_basil=output_baseline_basil

# Generate mask
fslmaths baseline_control -Tmean baseline_control_mean
bet baseline_control_mean baseline_control_brain
fslmaths baseline_control_brain -bin mask_baseline

# Take tag control difference
fslmaths baseline_tag -sub baseline_control baseline_diff

# Average all repeats
fslmaths baseline_diff -Tmean baseline_diff_avg

# 1 White paper method
# Calculate the CBF factor exp(1.8/1.65) * 0.9 * 6000 / (2 * 0.85 * 1.65 * (1 - exp(-1.8/1.65)))
# Result is 
# 8630
#cbf_factor=8630
# Compute CBF here
#fslmaths baseline_diff_avg -mul $cbf_factor -div M0_brain_calib -mas M0_brain_calib cbf_wp


# 2 Model fitting method
basil -i baseline_diff -m mask_baseline -o $output_dir_basil --spatial -@ basil_options_baseline.txt
# Calibration
# Inversion efficiency

fslmaths $output_dir_basil/step2/mean_ftiss -div $brain_image_calib -div $alpha -mul 6000 $output_dir_basil/step2/cbf_baseline_basil



# Acetazolamide image (high CBF)
output_dir_basil=output_acetazolamide_basil

# Here we only need the last 35 dynamics of the PCASL
# Obtain the last 35 dynamics (TIs)
first_dynamic=69
num_of_dynamics=35
fslroi acetazolamide_control acetazolamide_control_last_35 $first_dynamic $num_of_dynamics
fslroi acetazolamide_tag acetazolamide_tag_last_35 $first_dynamic $num_of_dynamics

# Generate mask
fslmaths acetazolamide_control_last_35 -Tmean acetazolamide_control_mean
bet acetazolamide_control_mean acetazolamide_control_brain
fslmaths acetazolamide_control_brain -bin mask_acetazolamide

# Take tag control difference
fslmaths acetazolamide_tag_last_35 -sub acetazolamide_control_last_35 acetazolamide_diff

# Average all repeats
fslmaths acetazolamide_diff -Tmean acetazolamide_diff_avg

# 1 White paper method
# Calculate the CBF factor exp(1.8/1.65) * 0.9 * 6000 / (2 * 0.85 * 1.65 * (1 - exp(-1.8/1.65)))
# Result is 
# 8630
#cbf_factor=8630
# Compute CBF here
#fslmaths acetazolamide_diff_avg -mul $cbf_factor -div M0_brain_calib -mas M0_brain_calib cbf_wp


# 2 Model fitting method
basil -i acetazolamide_diff -m mask_acetazolamide -o $output_dir_basil --spatial -@ basil_options_acetazolamide.txt
# Calibration
# Inversion efficiency

fslmaths $output_dir_basil/step2/mean_ftiss -div $brain_image_calib -div $alpha -mul 6000 $output_dir_basil/step2/cbf_acetazolamide_basil


