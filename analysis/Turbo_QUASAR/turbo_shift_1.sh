# The input file should be organised like this:
# Four big chuncks (1 regular chunck * 2 shifts * 2 repeats)
# Each dynamic has seven dynamics (Crushed, Crushed, Non-crushed, Crushed, Crushed, Non-crushed, Low flip angle)
# Each dynamic has 11 TIs (called cardca phases in Philips PAR file)
# Each TI has control and tag pairs

# Input data
# data_input=input

((n_dynamics=7))
((n_shift=1))
((n_tis=11))
((n_repeats=2))
((n_tc=2))
((n_dynamics_useful=6)) # dynamics that are useful, currently six (discard last flip angle)
partition_coefficient=0.9
inversion_efficiency=0.91
delta_TI=0.6
bolus_low=0.4

# Total number of TIs in each shift excluding tag-control pairs
((n_actual_tis_shift=$n_tis*$n_dynamics))
# Total number of TIs in each shift including tag-control pairs
((n_actual_tis_shift_tc=$n_tis*$n_dynamics*$n_tc))
# Total number of TIs in each repeat
((n_actual_tis_repeats=$n_tis*$n_dynamics*$n_shift*$n_tc))
# Total number of TIs in the entire dataset
((n_actual_tis_data=$n_tis*$n_dynamics*$n_shift*$n_tc*$n_repeats))
# First six dynamics
((n_actual_tis_first_six_dynamics=$n_tis*$n_shift*$n_dynamics_useful))
# Actual number of TIs in each dynamic (control, label, and difference)
((n_actual_tis_dynamic=$n_tis*$n_shift))

((shift_1_repeat_1_begin=$n_tis*$n_dynamics*$n_tc*0))
((shift_2_repeat_1_begin=$n_tis*$n_dynamics*$n_tc*1))
((shift_1_repeat_2_begin=$n_tis*$n_dynamics*$n_tc*2))
((shift_2_repeat_2_begin=$n_tis*$n_dynamics*$n_tc*3))


# Slice shifting parameters staring from zero for two shifts
break_1=0
break_2=8
break_3=15

segment_1_length=8
segment_2_length=8

# Slice shifting parameters starting from zero for four shifts


echo "Total number of sampling points: " $n_actual_tis_repeats " TIs"


#Function to split the repeat/shift
split_shift_repeat () {
  # $1: File folder name
  # $2: Input file to split

  mkdir $1
  fslsplit $2 $1/ti_

}


# Function to edit file name
edit_file_name () {
  # $1: File folder name
  cd $1
  for ((i=0; i<77; i++)); do
    if [ $i -lt 10 ]; then
      old_file_name="ti_000"$i
      new_file_name="ti_"$i

      immv $old_file_name $new_file_name
    else
      old_file_name="ti_00"$i
      new_file_name="ti_"$i

      immv $old_file_name $new_file_name
    fi
  done
  cd ..

}

# Function to create file list to merge
create_file_list () {
  # $1: Folder 1
  # $2: Folder 2
  # $3: Flago to indicate which comes first (1: Folder 1 then 2; 2: Folder 2 then 1)

  # Now create a list of file names to merge files
  file_list=" "
  for ((i=0; i<77; i++)); do
    file_list=$file_list$1"/ti_"$i" "
    file_list=$file_list$2"/ti_"$i" "
  done
  # Now write the file list to a file
  echo $file_list >> file_list_tis.txt

}

# Rotate image
#fslswapdim $data_input -y -x z $data_input


# Split the two shifts
#fslroi test2 data_dynamic_1_repeat_1 0 $n_actual_tis_shift_tc
#fslroi test2 data_dynamic_2_repeat_1 $n_actual_tis_shift_tc $n_actual_tis_shift_tc
#fslroi test2 data_dynamic_1_repeat_2 $n_actual_tis_repeats $n_actual_tis_shift_tc
#fslroi test2 data_dynamic_2_repeat_2 $haha $n_actual_tis_shift_tc

#fslmaths data_dynamic_1_repeat_1 -add data_dynamic_1_repeat_2 -div 2 data_mean_shift_1
#fslmaths data_dynamic_2_repeat_1 -add data_dynamic_2_repeat_2 -div 2 data_mean_shift_2


# Take the mean of all repeats
# asl_file --data=$data_input --ntis=$n_actual_tis_repeats --ibf=rpt --mean=data_mean



# Split the two shifts and two repeats
# fslroi <input> <output> <starting TI> <total number of TIs>
  #fslroi $data_input data_mean_shift_1_repeat_1 $shift_1_repeat_1_begin $n_actual_tis_shift_tc
  #fslroi $data_input data_mean_shift_2_repeat_1 $shift_2_repeat_1_begin $n_actual_tis_shift_tc
  #fslroi $data_input data_mean_shift_1_repeat_2 $shift_1_repeat_2_begin $n_actual_tis_shift_tc
  #fslroi $data_input data_mean_shift_2_repeat_2 $shift_2_repeat_2_begin $n_actual_tis_shift_tc
# Done splitting each repeat and shift


# Extract tag and control of each shift and repeat (control comes first)
# extract control images
# Now even is control and odd is tag
  #asl_file --data=data_mean_shift_1_repeat_1 --ntis=$n_actual_tis_shift --ibf=rpt --iaf=ct --spairs --out=data_mean_shift_1_repeat_1
  #immv data_mean_shift_1_repeat_1_even data_mean_shift_1_repeat_1_control
  #immv data_mean_shift_1_repeat_1_odd data_mean_shift_1_repeat_1_tag

  #asl_file --data=data_mean_shift_2_repeat_1 --ntis=$n_actual_tis_shift --ibf=rpt --iaf=ct --spairs --out=data_mean_shift_2_repeat_1
  #immv data_mean_shift_2_repeat_1_even data_mean_shift_2_repeat_1_control
  #immv data_mean_shift_2_repeat_1_odd data_mean_shift_2_repeat_1_tag

  #asl_file --data=data_mean_shift_1_repeat_2 --ntis=$n_actual_tis_shift --ibf=rpt --iaf=ct --spairs --out=data_mean_shift_1_repeat_2
  #immv data_mean_shift_1_repeat_2_even data_mean_shift_1_repeat_2_control
  #immv data_mean_shift_1_repeat_2_odd data_mean_shift_1_repeat_2_tag

  #asl_file --data=data_mean_shift_2_repeat_2 --ntis=$n_actual_tis_shift --ibf=rpt --iaf=ct --spairs --out=data_mean_shift_2_repeat_2
  #immv data_mean_shift_2_repeat_2_even data_mean_shift_2_repeat_2_control
  #immv data_mean_shift_2_repeat_2_odd data_mean_shift_2_repeat_2_tag
# Done extracting control and tag images

# Now rearrange z direction of different repeats
  # Do tag image of repeat 1 of tag image
  fslroi shift_1_repeat_1_tag data_mean_shift_1_repeat_1_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_1_repeat_1_tag data_mean_shift_1_repeat_1_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  fslroi shift_2_repeat_1_tag data_mean_shift_2_repeat_1_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_2_repeat_1_tag data_mean_shift_2_repeat_1_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  # Local function to split each TI
  split_shift_repeat shift_1_repeat_1_tag_z_0_z_6 data_mean_shift_1_repeat_1_tag_z_0_z_6
  split_shift_repeat shift_1_repeat_1_tag_z_7_z_14 data_mean_shift_1_repeat_1_tag_z_7_z_14
  split_shift_repeat shift_2_repeat_1_tag_z_0_z_6 data_mean_shift_2_repeat_1_tag_z_0_z_6
  split_shift_repeat shift_2_repeat_1_tag_z_7_z_14 data_mean_shift_2_repeat_1_tag_z_7_z_14
  # Local function to rename each TI
  edit_file_name shift_1_repeat_1_tag_z_0_z_6
  edit_file_name shift_2_repeat_1_tag_z_0_z_6
  edit_file_name shift_1_repeat_1_tag_z_7_z_14
  edit_file_name shift_2_repeat_1_tag_z_7_z_14

  # Local funcion to merge file
  # Merge the bottom slices
  create_file_list shift_1_repeat_1_tag_z_0_z_6 shift_2_repeat_1_tag_z_0_z_6
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_1_tag_z_0_z_6 $read_in_file_list
  rm file_list_tis.txt
  # Merge the upper slices
  create_file_list shift_2_repeat_1_tag_z_7_z_14 shift_1_repeat_1_tag_z_7_z_14
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_1_tag_z_7_z_14 $read_in_file_list
  rm file_list_tis.txt

  # Merge the bottom and top slices
  fslmerge -z repeat_1_tag repeat_1_tag_z_0_z_6 repeat_1_tag_z_7_z_14





  # Here do the same thing for the control images
  # Do control image of repeat 1 of control image
  fslroi shift_1_repeat_1_control data_mean_shift_1_repeat_1_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_1_repeat_1_control data_mean_shift_1_repeat_1_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  fslroi shift_2_repeat_1_control data_mean_shift_2_repeat_1_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_2_repeat_1_control data_mean_shift_2_repeat_1_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  # Local function to split each TI
  split_shift_repeat shift_1_repeat_1_control_z_0_z_6 data_mean_shift_1_repeat_1_control_z_0_z_6
  split_shift_repeat shift_1_repeat_1_control_z_7_z_14 data_mean_shift_1_repeat_1_control_z_7_z_14
  split_shift_repeat shift_2_repeat_1_control_z_0_z_6 data_mean_shift_2_repeat_1_control_z_0_z_6
  split_shift_repeat shift_2_repeat_1_control_z_7_z_14 data_mean_shift_2_repeat_1_control_z_7_z_14
  # Local function to rename each TI
  edit_file_name shift_1_repeat_1_control_z_0_z_6
  edit_file_name shift_2_repeat_1_control_z_0_z_6
  edit_file_name shift_1_repeat_1_control_z_7_z_14
  edit_file_name shift_2_repeat_1_control_z_7_z_14

  # Local funcion to merge file
  # Merge the bottom slices
  create_file_list shift_1_repeat_1_control_z_0_z_6 shift_2_repeat_1_control_z_0_z_6
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_1_control_z_0_z_6 $read_in_file_list
  rm file_list_tis.txt
  # Merge the upper slices
  create_file_list shift_2_repeat_1_control_z_7_z_14 shift_1_repeat_1_control_z_7_z_14
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_1_control_z_7_z_14 $read_in_file_list
  rm file_list_tis.txt

  # Merge the bottom and top slices
  fslmerge -z repeat_1_control repeat_1_control_z_0_z_6 repeat_1_control_z_7_z_14




# Completed increasing sampling rate


# Now average the repeats
  fslmaths repeat_1_tag -add repeat_1_tag -div 2 data_tag
  fslmaths repeat_1_control -add repeat_1_control -div 2 data_control
# Done average repeats


# Take tag control difference
  fslmaths data_tag -sub data_control data_diff
# Done computing tag control difference

#fslmaths shift_1_repeat_1_tag -sub shift_1_repeat_2_control data_diff


# Produce a mask using control image
  fslmaths data_control -Tmean data_control_mean
  bet data_control_mean mask -m
# Done creating mask

# Use the latest version of fabber
fabber=fabber_asl

# Fit saturation recovery curve of the control image to determine voxel wise M0 and T1
  # Fit all six phases plus one low flip angle
  $fabber --data=data_control --data-order=singlefile --output=calib -@ calib_options.txt
  # Use median filter to remove sharp artefact
  fslmaths calib/mean_M0t -fmedian calib/mean_M0t_median
  # Erode the edge of the calibration brain
  fslmaths calib/mean_M0t_median -ero calib/mean_M0t_ero
  # Extrapolate back the eroded voxels
  asl_file --data=calib/mean_M0t_ero --ntis=1 --mask=mask --extrapolate --neighbour=5 --out=calib/mean_M0t_extrapolate
  # Get M0a map by multiplying partition coefficient
  fslmaths calib/mean_M0t_extrapolate -mul $partition_coefficient calib/M0a

  # Average the six phases and fit (not very necessary now)
  #asl_file --data=data_control --ntis=$n_dynamics --ibf=tis --iaf=diff --split=data_control_ph_
  #fslmaths data_control_ph_000 -add data_control_ph_001 -add data_control_ph_002 -add data_control_ph_003 -add data_control_ph_004 -add data_control_ph_005 -div 6 data_control_ph_avg
  #$fabber --data=data_control_ph_avg --data-order=singlefile --output=calib_avg -@ calib_options_one_phase.txt
  #fslmaths calib_avg/mean_M0t -mul $partition_coefficient calib_avg/M0a
# Done fitting saturation recovery curve

# In Turbo-QUASAR only tissue component can be used

# Split the ASL data into tissue and arterial component
  asl_file --data=data_diff --ntis=$n_dynamics --ibf=tis --iaf=diff --split=data_diff_ph_
  # Tissue component
  fslmaths data_diff_ph_000 -add data_diff_ph_001 -add data_diff_ph_003 -add data_diff_ph_004 -div 4 data_diff_tissue
  # Arterial component
  fslmaths data_diff_ph_002 -add data_diff_ph_005 -div 2 -sub data_diff_tissue data_diff_arterial
  # Remove the intermediate images
  imrm data_diff_ph_000 data_diff_ph_001 data_diff_ph_002 data_diff_ph_003 data_diff_ph_004 data_diff_ph_005 data_diff_ph_006
# Done splitting


# Tissue only inference in spatial VB
  # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
  # Step 1
  $fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step1 -@ fabber_tissue_options_step_1.txt
  # Update MVN
  mvntool --input=full_tissue_only_step1/finalMVN --output=full_tissue_only_step1/finalMVN2 --mask=mask --param=3 --new --val=1 --var=1
  # Step 2
  $fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step2 -@ fabber_tissue_options_step_2.txt --continue-from-mvn=full_tissue_only_step1/finalMVN2
  # Calibration
  fslmaths full_tissue_only_step2/mean_ftiss -div calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_step2/CBF
# Done inferring tissue only component

# Tissue only inference in spatial VB without estimating bolus duration (assume bolus is 0.6s)
  # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
  # Step 1
  $fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_bolus -@ fabber_tissue_options_fixed_bolus.txt
  # Update MVN
  #mvntool --input=full_tissue_only_step1/finalMVN --output=full_tissue_only_step1/finalMVN2 --mask=mask --param=3 --new --val=1 --var=1
  # Step 2
  #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step2 -@ $fabber_tissue_options_step_2.txt --continue-from-mvn=full_tissue_only_step1/finalMVN2
  # Calibration
  fslmaths full_tissue_only_fixed_bolus/mean_ftiss -div calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_bolus/CBF
# Done inferring tissue only component



# Both tissue and arterial blood component inference in spatial VB
  # First we need to discard the low flip angle phase
  #fslroi data_diff data_diff_useful 0 $n_actual_tis_first_six_dynamics
  # Step 1 - only infer CBF and arrival time
  #$fabber --data=data_diff_useful --data-order=singlefile --output=full_tissue_and_arterial_step1 -@ $fabber_blood_and_tissue_options_all_step_1.txt
  # Step 2 - infer tissue and blood components with direction
  ### This section infers blood with its direction
  # Update MVN to infer tau
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=3 --new --val=1 --var=1
  # Update MVN to infer abv
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN2_dir --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=4 --new --val=0.05 --var=1
  # Update MVN to infer blood arrival time
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN2_dir --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=5 --new --val=1 --var=1
  # Update MVN to infer tau blood
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN2_dir --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=6 --new --val=1 --var=1
  # Update MVN to infer theta blood
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN2_dir --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=9 --new --val=1 --var=1
  # Update MVN to infer phi blood
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN2_dir --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=10 --new --val=1 --var=1
  # Update MVN to infer bvblood
  #mvntool --input=full_tissue_and_arterial_step1/finalMVN2_dir --output=full_tissue_and_arterial_step1/finalMVN2_dir --mask=mask --param=11 --new --val=1 --var=1
  # Step 2 inference
  #$fabber --data=data_diff_useful --data-order=singlefile --output=full_tissue_and_arterial_step2_dir -@ $fabber_blood_and_tissue_options_all_step_2_dir.txt --continue-from-mvn=full_tissue_and_arterial_step1/finalMVN2_dir
  # Calibration
  #fslmaths full_tissue_and_arterial_step2_dir/mean_ftiss -div calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_and_arterial_step2_dir/CBF
  #fslmaths full_tissue_and_arterial_step2_dir/mean_fblood -mul 100 full_tissue_and_arterial_step2_dir/ABV

  # Recalculate bolus duration
# Done model fitting



