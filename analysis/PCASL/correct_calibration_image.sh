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


