# Process PCASL image
data_dir_root="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/data/"
result_dir_root="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/results/"


data_type="PCASL/"

#exp_type="Acetazolamide/"
#exp_type="Baseline/"

current_working_dir=`pwd`

# Setting up working command
PATH=${FSLDEVDIR}/bin:${PATH}:$HOME/bin
export FSLDEVDIR PATH
#fabber="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/bin/fabber_old"
asl_file="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/bin/asl_file"


fabber_option="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/src/fabber_options/pcasl/"

# Some scanning parameters
alpha=0.85 # inversion efficiency

# Correct TR for proton density image
# 10.1002/mrm.25197
# multiple_factor=(1/(1-exp(-tr/T1_of_tissue)))
# In this case, TR=4.4
# So multiple_factor = 1.0351
# Assuming T1_of_tissue = 1.3
correct_TR_factor=1.0351

# Useful Dynamics in Acetazolamide (we only need the last 35 dynamics)
#first_dynamic=69 # Most subject
#first_dynamic=58 # Subject 101
first_dynamic=0 # Subject 104
num_of_dynamics=35

#control_disease_dir="control/"
#control_disease_dir="disease/"
#subject_dir_root="CRUISE_"

for ((current_subject=110;current_subject<=110;current_subject=current_subject+1))
do

  # Healthy control subjects
  if [ $current_subject -lt 100 ]; then
    control_disease_dir="control/"
    # If subject ID is less than 10
      if [ $current_subject -lt 10 ]; then
        subject_dir_root='CRUISE_00'
        #subject_disease_dir='CRUISE10'
      else
        subject_dir_root='CRUISE_0'
        #subject_disease_dir='CRUISE10'
      fi
  else
    control_disease_dir="disease/"
    subject_dir_root='CRUISE_'
  fi


  # Input data directory
  current_subject_dir=$data_dir_root$control_disease_dir$subject_dir_root$current_subject"/"$data_type
  echo $current_subject_dir

  # Result directory
  # Results
  current_result_control_disease_dir=$result_dir_root$control_disease_dir
  mkdir $current_result_control_disease_dir
  current_result_subject_dir=$current_result_control_disease_dir$subject_dir_root$current_subject"/"
  mkdir $current_result_subject_dir
  current_result_dir=$current_result_subject_dir$data_type
  mkdir $current_result_dir
  echo $current_result_dir



  # create a temporary directory
  temp_dir="temp_dir_"$current_subject
  mkdir $temp_dir
  cd $temp_dir

  # Deal with M0 image
  current_M0_data=$current_subject_dir"M0/M0"

  brain_image="M0_brain"
  brain_image_correct=$brain_image"_correct_tr"
  brain_image_median=$brain_image"_median"
  brain_image_ero=$brain_image"_ero"
  brain_image_calib=$brain_image"_calib"

  # Brain extraction
  bet $current_M0_data $brain_image


  fslmaths $brain_image -mul $correct_TR_factor $brain_image_correct

  # Apply a median filter to correct the sharp artefact
  fslmaths $brain_image_correct -fmedian $brain_image_median

  # Correct partial volume effects on the edge
  # 1 Erode the edge
  fslmaths $brain_image_median -ero $brain_image_ero
  # 2 Extrapolate back the eroded voxels
  asl_file --data=$brain_image_ero --ntis=1 --mask=$brain_image --extrapolate --neighbour=5 --out=$brain_image_calib

  # Save the calibration results
  calib_dir="calib"
  mkdir $calib_dir
  imcp M0_brain $brain_image_calib $calib_dir


  # Now process ASL datsa
  # Baseline image (low CBF)
  exp_type="baseline_"
  current_asl_control_data=$current_subject_dir"ASL/"$exp_type"control"
  current_asl_tag_data=$current_subject_dir"ASL/"$exp_type"tag"
  basil_option_file=$fabber_option"basil_options_baseline.txt"

  current_asl_diff_data=$exp_type"diff"
  output_dir="output_baseline_basil"

  # Generate mask
  fslmaths $current_asl_control_data -Tmean baseline_control_mean
  bet baseline_control_mean baseline_control_brain
  fslmaths baseline_control_brain -bin mask

  # Take tag control difference
  fslmaths $current_asl_tag_data -sub $current_asl_control_data $current_asl_diff_data

  # 1 White paper method
  # Calculate the CBF factor exp(1.8/1.65) * 0.9 * 6000 / (2 * 0.85 * 1.65 * (1 - exp(-1.8/1.65)))
  # Result is 
  # 8630
  #cbf_factor=8630
  # Compute CBF here
  #fslmaths baseline_diff_avg -mul $cbf_factor -div M0_brain_calib -mas M0_brain_calib cbf_wp


  # 2 Model fitting method
  basil -i $current_asl_diff_data -m mask -o $output_dir --spatial -@ $basil_option_file
  # Calibration
  # Inversion efficiency

  fslmaths $output_dir/step2/mean_ftiss -div $brain_image_calib -div $alpha -mul 6000 $output_dir/step2/cbf_baseline_basil

  # Copy results
  mv $output_dir $current_result_dir


  # Acetazolamide image (high CBF)
  exp_type="acetazolamide_"
  current_asl_control_data=$current_subject_dir"ASL/"$exp_type"control"
  current_asl_tag_data=$current_subject_dir"ASL/"$exp_type"tag"
  basil_option_file=$fabber_option"basil_options_acetazolamide.txt"

  current_asl_diff_data=$exp_type"diff"
  output_dir="output_acetazolamide_basil"

  # Here we only need the last 35 dynamics of the PCASL
  # Obtain the last 35 dynamics (TIs)
  fslroi $current_asl_control_data acetazolamide_control_last_35 $first_dynamic $num_of_dynamics
  fslroi $current_asl_tag_data acetazolamide_tag_last_35 $first_dynamic $num_of_dynamics


  # Generate mask
  fslmaths acetazolamide_control_last_35 -Tmean acetazolamide_control_mean
  bet acetazolamide_control_mean acetazolamide_control_brain
  fslmaths acetazolamide_control_brain -bin mask_acetazolamide

  # Take tag control difference
  fslmaths acetazolamide_tag_last_35 -sub acetazolamide_control_last_35 acetazolamide_diff

  # 1 White paper method
  # Calculate the CBF factor exp(1.8/1.65) * 0.9 * 6000 / (2 * 0.85 * 1.65 * (1 - exp(-1.8/1.65)))
  # Result is 
  # 8630
  #cbf_factor=8630
  # Compute CBF here
  #fslmaths baseline_diff_avg -mul $cbf_factor -div M0_brain_calib -mas M0_brain_calib cbf_wp


  # 2 Model fitting method
  basil -i acetazolamide_diff -m mask_acetazolamide -o $output_dir --spatial -@ $basil_option_file
  # Calibration
  # Inversion efficiency

  fslmaths $output_dir/step2/mean_ftiss -div $brain_image_calib -div $alpha -mul 6000 $output_dir/step2/cbf_acetazolamide_basil


  # Copy results
  mv $output_dir $current_result_dir

  # Move calibration images
  mv $calib_dir $current_result_dir
  
  # This subject complete
  cd $current_working_dir
  
  rm -rf $temp_dir

done

echo "PCASL analysis done!"

