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
shift_factor=2
tau=0.6
bolus_low=0.4
mfree_edge_threshold=0.5
TI_1=0.04

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
break_2=7
break_3=14

segment_1_length=7
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


data_dir_root="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/data/"
result_dir_root="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/results/"
control_disease_dir="control/"
#control_disease_dir="disease/"
subject_dir_root="CRUISE_"

data_type="Turbo_QUASAR/"

exp_type="Acetazolamide/"
#exp_type="Baseline/"

current_working_dir=`pwd`

# Setting up working command
PATH=${FSLDEVDIR}/bin:${PATH}:$HOME/bin
export FSLDEVDIR PATH
fabber="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/bin/fabber_old"
asl_file="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/bin/asl_file"
#asl_mfree="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/bin/asl_mfree"
#asl_mfree=$FSLDIR"/bin/asl_mfree"
asl_mfree=asl_mfree


fabber_option="/panfs/pan01/vol034/data/engs-qubic/scro2665/oxford_amc_drcmr/src/fabber_options/turbo_quasar/"

for ((current_subject=1;current_subject<=11;current_subject=current_subject+1))
do


  exp_type="Acetazolamide/"
  #exp_type="Baseline/"

  # If subject ID is less than 10
    if [ $current_subject -lt 10 ]; then
    subject_name_dir='00'
    #subject_disease_dir='CRUISE10'
    else
    subject_name_dir='0'
    #subject_disease_dir='CRUISE10'
    fi


  # Input data
  current_subject_dir=$data_dir_root$control_disease_dir$subject_dir_root$subject_name_dir$current_subject"/"$data_type$exp_type
  echo $current_subject_dir

  # Results
  current_result_control_disease_dir=$result_dir_root$control_disease_dir
  mkdir $current_result_control_disease_dir
  current_result_subject_dir=$current_result_control_disease_dir$subject_dir_root$subject_name_dir$current_subject"/"
  mkdir $current_result_subject_dir
  current_data_type_dir=$current_result_subject_dir$data_type
  mkdir $current_data_type_dir
  current_exp_type_dir=$current_data_type_dir$exp_type
  mkdir $current_exp_type_dir

  current_result_dir=$result_dir_root$control_disease_dir$subject_dir_root$subject_name_dir$current_subject"/"$data_type$exp_type
  echo $current_result_dir

  temp_dir="temp_dir_"$exp_type
  mkdir $temp_dir
  cd $temp_dir

  shift_1_repeat_1_tag=$current_subject_dir"shift_1_repeat_1_tag"
  shift_1_repeat_1_control=$current_subject_dir"shift_1_repeat_1_control"
  shift_2_repeat_1_tag=$current_subject_dir"shift_2_repeat_1_tag"
  shift_2_repeat_1_control=$current_subject_dir"shift_2_repeat_1_control"

  # We first copy the input images to the temp directory
  imcp $shift_1_repeat_1_tag shift_1_repeat_1_tag
  imcp $shift_1_repeat_1_control shift_1_repeat_1_control
  imcp $shift_2_repeat_1_tag shift_2_repeat_1_tag
  imcp $shift_2_repeat_1_control shift_2_repeat_1_control

  shift_1_repeat_1_tag=shift_1_repeat_1_tag
  shift_1_repeat_1_control=shift_1_repeat_1_control
  shift_2_repeat_1_tag=shift_2_repeat_1_tag
  shift_2_repeat_1_control=shift_2_repeat_1_control

  # Motion correction
    # Append the four data into one volume
    #fslmerge -t data_motion $shift_1_repeat_1_tag $shift_1_repeat_1_control $shift_2_repeat_1_tag $shift_2_repeat_1_control

    # Do simple motion correction
    #mcflirt -in data_motion -out data_motion_correct

    # Split the motion corrected data
    #fslroi data_motion_correct shift_1_repeat_1_tag_mc     0 77
    #fslroi data_motion_correct shift_1_repeat_1_control_mc 77 77
    #fslroi data_motion_correct shift_2_repeat_1_tag_mc     154 77
    #fslroi data_motion_correct shift_2_repeat_1_control_mc 231 77

    #shift_1_repeat_1_tag=shift_1_repeat_1_tag_mc
    #shift_1_repeat_1_control=shift_1_repeat_1_control_mc
    #shift_2_repeat_1_tag=shift_2_repeat_1_tag_mc
    #shift_2_repeat_1_control=shift_2_repeat_1_control_mc
  # Done motion correction


  # Now rearrange z direction of different repeats
    # Do tag image of repeat 1 of tag image
    fslroi $shift_1_repeat_1_tag data_mean_shift_1_repeat_1_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_1_repeat_1_tag data_mean_shift_1_repeat_1_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
    fslroi $shift_2_repeat_1_tag data_mean_shift_2_repeat_1_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_2_repeat_1_tag data_mean_shift_2_repeat_1_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
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
    fslroi $shift_1_repeat_1_control data_mean_shift_1_repeat_1_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_1_repeat_1_control data_mean_shift_1_repeat_1_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
    fslroi $shift_2_repeat_1_control data_mean_shift_2_repeat_1_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_2_repeat_1_control data_mean_shift_2_repeat_1_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
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

  # Fit saturation recovery curve of the control image to determine voxel wise M0 and T1 (MT effects causes uncertainty here)
    #calib_options=$fabber_option"calib_options.txt"
    
    # Fit all six phases plus one low flip angle
    #$fabber --data=data_control --data-order=singlefile --output=calib -@ $calib_options

    #calib=calib
  # Done saturation recovery

  # Use the last TI as M0 image
    # Use the last TI (closest to M0)
    #asl_file --data=data_control --ntis=7 --ibf=tis --iaf=diff --split=data_control_
    
    # Extract last TI of the first six dynamic
    #last_TI=21
    #length=1
    #fslroi data_control_000 data_control_0_m_21 $last_TI $length
    #fslroi data_control_001 data_control_1_m_21 $last_TI $length
    #fslroi data_control_002 data_control_2_m_21 $last_TI $length
    #fslroi data_control_003 data_control_3_m_21 $last_TI $length
    #fslroi data_control_004 data_control_4_m_21 $last_TI $length
    #fslroi data_control_005 data_control_5_m_21 $last_TI $length
    #fslroi data_control_006 data_control_6_m_21 $last_TI $length

    # Average
    #fslmaths data_control_0_m_21 -add data_control_1_m_21 -add data_control_2_m_21 -add data_control_3_m_21 -add data_control_4_m_21 -add data_control_5_m_21 -div 6 -mas mask M0t_last_TI

    # Copy this to Calibration folder
    #calib=calib_last_TI
    #mkdir $calib
    #imcp M0t_last_TI $calib/mean_M0t

  # Done last TI

  # Use first seven TIs to avoid MT effects
    # Use the last TI (closest to M0)
    asl_file --data=data_control --ntis=7 --ibf=tis --iaf=diff --split=data_control_

    # Extract first 7 TI of the first six dynamic
    last_TI=0
    length=7
    fslroi data_control_000 data_control_0_m_0 $last_TI $length
    fslroi data_control_001 data_control_1_m_0 $last_TI $length
    fslroi data_control_002 data_control_2_m_0 $last_TI $length
    fslroi data_control_003 data_control_3_m_0 $last_TI $length
    fslroi data_control_004 data_control_4_m_0 $last_TI $length
    fslroi data_control_005 data_control_5_m_0 $last_TI $length
    fslroi data_control_006 data_control_6_m_0 $last_TI $length

    # Merge the first seven TIs
    fslmerge -t data_control_TI_7 data_control_0_m_0 data_control_1_m_0 data_control_2_m_0 data_control_3_m_0 data_control_4_m_0 data_control_5_m_0 data_control_6_m_0

    calib_options=$fabber_option"calib_options_first_7.txt"
    $fabber --data=data_control_TI_7 --data-order=singlefile --output=calib -@ $calib_options

    calib=calib
  # Done first seven TIs    

  # Correct M0 image
    # Use median filter to remove sharp artefact
    fslmaths $calib/mean_M0t -fmedian $calib/mean_M0t_median
    # Erode the edge of the calibration brain
    fslmaths $calib/mean_M0t_median -ero $calib/mean_M0t_ero
    # Extrapolate back the eroded voxels
    $asl_file --data=$calib/mean_M0t_ero --ntis=1 --mask=mask --extrapolate --neighbour=5 --out=$calib/mean_M0t_extrapolate
    # Get M0a map by multiplying partition coefficient
    fslmaths $calib/mean_M0t_extrapolate -mul $partition_coefficient $calib/M0a


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


  # CBF Estimation Fixed T1

  # Tissue only inference in spatial VB
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    #fabber_tissue_options_step_1=$fabber_option"fabber_blood_and_tissue_options_all_fixed_T1_step_1.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_T1_step1 -@ $fabber_tissue_options_step_1
    # Update MVN
    #mvntool --input=full_tissue_only_fixed_T1_step1/finalMVN --output=full_tissue_only_fixed_T1_step1/finalMVN2 --mask=mask --param=3 --new --val=1 --var=1
    # Step 2
    #fabber_tissue_options_step_2=$fabber_option"fabber_blood_and_tissue_options_all_fixed_T1_step_2.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_T1_step2 -@ $fabber_tissue_options_step_2 --continue-from-mvn=full_tissue_only_fixed_T1_step1/finalMVN2
    # Calibration
    #fslmaths full_tissue_only_fixed_T1_step2/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_T1_step2/CBF
    result_1_dir=full_tissue_only_fixed_T1_step1
    result_2_dir=full_tissue_only_fixed_T1_step2
  # Done inferring tissue only component


  # Tissue only inference in spatial VB without estimating bolus duration and fixing T1 value (assume bolus is 0.6s)
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    #fabber_tissue_options_fixed_bolus=$fabber_option"fabber_tissue_options_fixed_bolus_fixed_T1.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_bolus_fixed_T1 -@ $fabber_tissue_options_fixed_bolus
    # Calibration
    #fslmaths full_tissue_only_fixed_bolus_fixed_T1/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_bolus_fixed_T1/CBF
    result_3_dir=full_tissue_only_fixed_bolus_fixed_T1
  # Done inferring tissue only component





  # CBF Estimation Varying T1

  # Tissue only inference in spatial VB
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    fabber_tissue_options_step_1=$fabber_option"fabber_tissue_options_step_1.txt"

    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step1 -@ $fabber_tissue_options_step_1
    # Update MVN
    #mvntool --input=full_tissue_only_step1/finalMVN --output=full_tissue_only_step1/finalMVN2 --mask=mask --param=3 --new --val=1 --var=1
    # Step 2
    fabber_tissue_options_step_2=$fabber_option"fabber_tissue_options_step_2.txt"

    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step2 -@ $fabber_tissue_options_step_2 --continue-from-mvn=full_tissue_only_step1/finalMVN2
    # Calibration
    #fslmaths full_tissue_only_step2/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_step2/CBF
    
    result_1_dir=full_tissue_only_step1
    result_2_dir=full_tissue_only_step2
  # Done inferring tissue only component

  # Tissue only inference in spatial VB without estimating bolus duration and varying T1 value (use the T1 map from calibration as prior) (assume bolus is 0.6s)
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    fabber_tissue_options_fixed_bolus=$fabber_option"fabber_tissue_options_fixed_bolus.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_bolus -@ $fabber_tissue_options_fixed_bolus
    # Calibration
    #fslmaths full_tissue_only_fixed_bolus/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_bolus/CBF
    
    result_3_dir=full_tissue_only_fixed_bolus
  # Done inferring tissue only component



  # Model Free CBF estimation
  # We need to find out arterial blood volume (ABV) and arterial input function (AIF)

  # Some fixed parameter values
  t1_blood=1.6 # blood T1
  fa_degree=35  # Flip angle in degrees
  m_threshold=0.012

    fabber_blood_options_fixed_bolus=$fabber_option"fabber_blood_options_fixed_bolus.txt"

    result_blood_dir=fabber_blood_fixed_bolus

    $fabber --data=data_diff_arterial --data-order=singlefile --output=$result_blood_dir -@ $fabber_blood_options_fixed_bolus

    # Get arterial volume
    fslmaths $result_blood_dir/mean_fblood -div $calib/M0a -div $inversion_efficiency $result_blood_dir/abv

    # Get the shape of aif
    fslmaths $result_blood_dir/modelfit -div $result_blood_dir/mean_fblood $result_blood_dir/aifs

    # Smooth the tissue component a bit
    fslmaths data_diff_tissue -s 2.1 data_diff_tissue_smooth

    # Model free analysis
    # We also estimate the arrival time. --bat option
    echo 'We are using the older version of ASL_MFREE without Turbo QUASAR options!!!'
    #delta_TI=0.6
    #$asl_mfree --data=data_diff_tissue_smooth --mask=mask --out=modfree --bat --aif=$result_blood_dir/aifs --metric=$result_blood_dir/abv --mthresh=$m_threshold --tcorrect --t1=$t1_blood --fa=$fa_degree --dt=$delta_TI
    $asl_mfree --data=data_diff_tissue_smooth --mask=mask --out=modfree --bat --bat_grad_thr=$mfree_edge_threshold --aif=$result_blood_dir/aifs --metric=$result_blood_dir/abv --mthresh=$m_threshold --tcorrect --bata=$result_blood_dir/mean_deltblood --t1=$t1_blood --fa=$fa_degree --dt=$delta_TI --turbo_quasar --shift_factor=2
    #$asl_mfree --data=data_diff_tissue_smooth --mask=mask --out=modfree --bat --aif=$result_blood_dir/aifs --metric=$result_blood_dir/abv --mthresh=$m_threshold --t1=$t1_blood --fa=$fa_degree --dt=$delta_TI --turbo_quasar --shift_factor=2

    # Calibration
    #fslmaths modfree_magntiude -div $calib/M0a -div $inversion_efficiency -mul 6000 -div $tau -nan modfree_CBF
    fslmaths modfree_magntiude -div $calib/M0a -div $inversion_efficiency -mul 6000 -div $tau -nan modfree_CBF

    # Correct arrival time
    fslmaths modfree_bat -add $TI_1 modfree_bat

    # Output
    model_free_dir="model_free_fixed_tau/"
    mkdir $model_free_dir
    immv modfree_magntiude modfree_CBF modfree_bat modfree_aifs modfree_residuals $model_free_dir

  # Complete model Free CBF estimation


  # Copy results
  mv calib $current_result_dir
  mv $calib $current_result_dir
  mv $result_1_dir $current_result_dir
  mv $result_2_dir $current_result_dir
  mv $result_3_dir $current_result_dir
  mv $result_blood_dir $current_result_dir
  mv $model_free_dir $current_result_dir
  

  # This subject complete
  cd $current_working_dir
  
  rm -rf $temp_dir


















  #exp_type="Acetazolamide/"
  exp_type="Baseline/"

  # If subject ID is less than 10
    if [ $current_subject -lt 10 ]; then
    subject_name_dir='00'
    #subject_disease_dir='CRUISE10'
    else
    subject_name_dir='0'
    #subject_disease_dir='CRUISE10'
    fi


  # Input data
  current_subject_dir=$data_dir_root$control_disease_dir$subject_dir_root$subject_name_dir$current_subject"/"$data_type$exp_type
  echo $current_subject_dir

  # Results
  current_result_control_disease_dir=$result_dir_root$control_disease_dir
  mkdir $current_result_control_disease_dir
  current_result_subject_dir=$current_result_control_disease_dir$subject_dir_root$subject_name_dir$current_subject"/"
  mkdir $current_result_subject_dir
  current_data_type_dir=$current_result_subject_dir$data_type
  mkdir $current_data_type_dir
  current_exp_type_dir=$current_data_type_dir$exp_type
  mkdir $current_exp_type_dir

  current_result_dir=$result_dir_root$control_disease_dir$subject_dir_root$subject_name_dir$current_subject"/"$data_type$exp_type
  echo $current_result_dir

  temp_dir="temp_dir_"$exp_type
  mkdir $temp_dir
  cd $temp_dir

  shift_1_repeat_1_tag=$current_subject_dir"shift_1_repeat_1_tag"
  shift_1_repeat_1_control=$current_subject_dir"shift_1_repeat_1_control"
  shift_2_repeat_1_tag=$current_subject_dir"shift_2_repeat_1_tag"
  shift_2_repeat_1_control=$current_subject_dir"shift_2_repeat_1_control"

  # We first copy the input images to the temp directory
  imcp $shift_1_repeat_1_tag shift_1_repeat_1_tag
  imcp $shift_1_repeat_1_control shift_1_repeat_1_control
  imcp $shift_2_repeat_1_tag shift_2_repeat_1_tag
  imcp $shift_2_repeat_1_control shift_2_repeat_1_control

  shift_1_repeat_1_tag=shift_1_repeat_1_tag
  shift_1_repeat_1_control=shift_1_repeat_1_control
  shift_2_repeat_1_tag=shift_2_repeat_1_tag
  shift_2_repeat_1_control=shift_2_repeat_1_control

  # Motion correction
    # Append the four data into one volume
    #fslmerge -t data_motion $shift_1_repeat_1_tag $shift_1_repeat_1_control $shift_2_repeat_1_tag $shift_2_repeat_1_control

    # Do simple motion correction
    #mcflirt -in data_motion -out data_motion_correct

    # Split the motion corrected data
    #fslroi data_motion_correct shift_1_repeat_1_tag_mc     0 77
    #fslroi data_motion_correct shift_1_repeat_1_control_mc 77 77
    #fslroi data_motion_correct shift_2_repeat_1_tag_mc     154 77
    #fslroi data_motion_correct shift_2_repeat_1_control_mc 231 77

    #shift_1_repeat_1_tag=shift_1_repeat_1_tag_mc
    #shift_1_repeat_1_control=shift_1_repeat_1_control_mc
    #shift_2_repeat_1_tag=shift_2_repeat_1_tag_mc
    #shift_2_repeat_1_control=shift_2_repeat_1_control_mc
  # Done motion correction


  # Now rearrange z direction of different repeats
    # Do tag image of repeat 1 of tag image
    fslroi $shift_1_repeat_1_tag data_mean_shift_1_repeat_1_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_1_repeat_1_tag data_mean_shift_1_repeat_1_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
    fslroi $shift_2_repeat_1_tag data_mean_shift_2_repeat_1_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_2_repeat_1_tag data_mean_shift_2_repeat_1_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
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
    fslroi $shift_1_repeat_1_control data_mean_shift_1_repeat_1_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_1_repeat_1_control data_mean_shift_1_repeat_1_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
    fslroi $shift_2_repeat_1_control data_mean_shift_2_repeat_1_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
    fslroi $shift_2_repeat_1_control data_mean_shift_2_repeat_1_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
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

  # Fit saturation recovery curve of the control image to determine voxel wise M0 and T1 (MT effects causes uncertainty here)
    #calib_options=$fabber_option"calib_options.txt"
    
    # Fit all six phases plus one low flip angle
    #$fabber --data=data_control --data-order=singlefile --output=calib -@ $calib_options

    #calib=calib
  # Done saturation recovery

  # Use the last TI as M0 image
    # Use the last TI (closest to M0)
    #asl_file --data=data_control --ntis=7 --ibf=tis --iaf=diff --split=data_control_
    
    # Extract last TI of the first six dynamic
    #last_TI=21
    #length=1
    #fslroi data_control_000 data_control_0_m_21 $last_TI $length
    #fslroi data_control_001 data_control_1_m_21 $last_TI $length
    #fslroi data_control_002 data_control_2_m_21 $last_TI $length
    #fslroi data_control_003 data_control_3_m_21 $last_TI $length
    #fslroi data_control_004 data_control_4_m_21 $last_TI $length
    #fslroi data_control_005 data_control_5_m_21 $last_TI $length
    #fslroi data_control_006 data_control_6_m_21 $last_TI $length

    # Average
    #fslmaths data_control_0_m_21 -add data_control_1_m_21 -add data_control_2_m_21 -add data_control_3_m_21 -add data_control_4_m_21 -add data_control_5_m_21 -div 6 -mas mask M0t_last_TI

    # Copy this to Calibration folder
    #calib=calib_last_TI
    #mkdir $calib
    #imcp M0t_last_TI $calib/mean_M0t

  # Done last TI

  # Use first seven TIs to avoid MT effects
    # Use the last TI (closest to M0)
    asl_file --data=data_control --ntis=7 --ibf=tis --iaf=diff --split=data_control_

    # Extract first 7 TI of the first six dynamic
    last_TI=0
    length=7
    fslroi data_control_000 data_control_0_m_0 $last_TI $length
    fslroi data_control_001 data_control_1_m_0 $last_TI $length
    fslroi data_control_002 data_control_2_m_0 $last_TI $length
    fslroi data_control_003 data_control_3_m_0 $last_TI $length
    fslroi data_control_004 data_control_4_m_0 $last_TI $length
    fslroi data_control_005 data_control_5_m_0 $last_TI $length
    fslroi data_control_006 data_control_6_m_0 $last_TI $length

    # Merge the first seven TIs
    fslmerge -t data_control_TI_7 data_control_0_m_0 data_control_1_m_0 data_control_2_m_0 data_control_3_m_0 data_control_4_m_0 data_control_5_m_0 data_control_6_m_0

    calib_options=$fabber_option"calib_options_first_7.txt"
    $fabber --data=data_control_TI_7 --data-order=singlefile --output=calib -@ $calib_options

    calib=calib
  # Done first seven TIs    

  # Correct M0 image
    # Use median filter to remove sharp artefact
    fslmaths $calib/mean_M0t -fmedian $calib/mean_M0t_median
    # Erode the edge of the calibration brain
    fslmaths $calib/mean_M0t_median -ero $calib/mean_M0t_ero
    # Extrapolate back the eroded voxels
    $asl_file --data=$calib/mean_M0t_ero --ntis=1 --mask=mask --extrapolate --neighbour=5 --out=$calib/mean_M0t_extrapolate
    # Get M0a map by multiplying partition coefficient
    fslmaths $calib/mean_M0t_extrapolate -mul $partition_coefficient $calib/M0a


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


  # CBF Estimation Fixed T1

  # Tissue only inference in spatial VB
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    #fabber_tissue_options_step_1=$fabber_option"fabber_blood_and_tissue_options_all_fixed_T1_step_1.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_T1_step1 -@ $fabber_tissue_options_step_1
    # Update MVN
    #mvntool --input=full_tissue_only_fixed_T1_step1/finalMVN --output=full_tissue_only_fixed_T1_step1/finalMVN2 --mask=mask --param=3 --new --val=1 --var=1
    # Step 2
    #fabber_tissue_options_step_2=$fabber_option"fabber_blood_and_tissue_options_all_fixed_T1_step_2.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_T1_step2 -@ $fabber_tissue_options_step_2 --continue-from-mvn=full_tissue_only_fixed_T1_step1/finalMVN2
    # Calibration
    #fslmaths full_tissue_only_fixed_T1_step2/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_T1_step2/CBF
    result_1_dir=full_tissue_only_fixed_T1_step1
    result_2_dir=full_tissue_only_fixed_T1_step2
  # Done inferring tissue only component


  # Tissue only inference in spatial VB without estimating bolus duration and fixing T1 value (assume bolus is 0.6s)
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    #fabber_tissue_options_fixed_bolus=$fabber_option"fabber_tissue_options_fixed_bolus_fixed_T1.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_bolus_fixed_T1 -@ $fabber_tissue_options_fixed_bolus
    # Calibration
    #fslmaths full_tissue_only_fixed_bolus_fixed_T1/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_bolus_fixed_T1/CBF
    result_3_dir=full_tissue_only_fixed_bolus_fixed_T1
  # Done inferring tissue only component





  # CBF Estimation Varying T1

  # Tissue only inference in spatial VB
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    fabber_tissue_options_step_1=$fabber_option"fabber_tissue_options_step_1.txt"

    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step1 -@ $fabber_tissue_options_step_1
    # Update MVN
    #mvntool --input=full_tissue_only_step1/finalMVN --output=full_tissue_only_step1/finalMVN2 --mask=mask --param=3 --new --val=1 --var=1
    # Step 2
    #fabber_tissue_options_step_2=$fabber_option"fabber_tissue_options_step_2.txt"

    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_step2 -@ $fabber_tissue_options_step_2 --continue-from-mvn=full_tissue_only_step1/finalMVN2
    # Calibration
    #fslmaths full_tissue_only_step2/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_step2/CBF
    
    result_1_dir=full_tissue_only_step1
    result_2_dir=full_tissue_only_step2
  # Done inferring tissue only component

  # Tissue only inference in spatial VB without estimating bolus duration and varying T1 value (use the T1 map from calibration as prior) (assume bolus is 0.6s)
    # Do it in two steps: 1 inference CBF and arrival time; 2 inference CBF, arrival time, and bolus duration
    # Step 1
    #fabber_tissue_options_fixed_bolus=$fabber_option"fabber_tissue_options_fixed_bolus.txt"
    #$fabber --data=data_diff_tissue --data-order=singlefile --output=full_tissue_only_fixed_bolus -@ $fabber_tissue_options_fixed_bolus
    # Calibration
    #fslmaths full_tissue_only_fixed_bolus/mean_ftiss -div $calib/M0a -div $inversion_efficiency -mul 6000 full_tissue_only_fixed_bolus/CBF
    
    result_3_dir=full_tissue_only_fixed_bolus
  # Done inferring tissue only component



  # Model Free CBF estimation
  # We need to find out arterial blood volume (ABV) and arterial input function (AIF)

  # Some fixed parameter values
  t1_blood=1.6 # blood T1
  fa_degree=35  # Flip angle in degrees
  m_threshold=0.012

    fabber_blood_options_fixed_bolus=$fabber_option"fabber_blood_options_fixed_bolus.txt"

    result_blood_dir=fabber_blood_fixed_bolus

    $fabber --data=data_diff_arterial --data-order=singlefile --output=$result_blood_dir -@ $fabber_blood_options_fixed_bolus

    # Get arterial volume
    fslmaths $result_blood_dir/mean_fblood -div $calib/M0a -div $inversion_efficiency $result_blood_dir/abv

    # Get the shape of aif
    fslmaths $result_blood_dir/modelfit -div $result_blood_dir/mean_fblood $result_blood_dir/aifs

    # Smooth the tissue component a bit
    fslmaths data_diff_tissue -s 2.1 data_diff_tissue_smooth

    # Model free analysis
    # We also estimate the arrival time. --bat option
    # echo 'We are using the older version of ASL_MFREE without Turbo QUASAR options!!!'
    #delta_TI=0.6
    #$asl_mfree --data=data_diff_tissue_smooth --mask=mask --out=modfree --bat --aif=$result_blood_dir/aifs --metric=$result_blood_dir/abv --mthresh=$m_threshold --tcorrect --t1=$t1_blood --fa=$fa_degree --dt=$delta_TI
    $asl_mfree --data=data_diff_tissue_smooth --mask=mask --out=modfree --bat --bat_grad_thr=$mfree_edge_threshold --aif=$result_blood_dir/aifs --metric=$result_blood_dir/abv --mthresh=$m_threshold --tcorrect --bata=$result_blood_dir/mean_deltblood --t1=$t1_blood --fa=$fa_degree --dt=$delta_TI --turbo_quasar --shift_factor=2
    #$asl_mfree --data=data_diff_tissue_smooth --mask=mask --out=modfree --bat --aif=$result_blood_dir/aifs --metric=$result_blood_dir/abv --mthresh=$m_threshold --t1=$t1_blood --fa=$fa_degree --dt=$delta_TI --turbo_quasar --shift_factor=2

    # Calibration
    #fslmaths modfree_magntiude -div $calib/M0a -div $inversion_efficiency -mul 6000 -div $tau -nan modfree_CBF
    fslmaths modfree_magntiude -div $calib/M0a -div $inversion_efficiency -mul 6000 -div $tau -nan modfree_CBF

    # Correct arrival time
    fslmaths modfree_bat -add $TI_1 modfree_bat

    # Output
    model_free_dir="model_free_fixed_tau/"
    mkdir $model_free_dir
    immv modfree_magntiude modfree_CBF modfree_bat modfree_aifs modfree_residuals $model_free_dir

  # Complete model Free CBF estimation


  # Copy results
  mv calib $current_result_dir
  mv $calib $current_result_dir
  mv $result_1_dir $current_result_dir
  mv $result_2_dir $current_result_dir
  mv $result_3_dir $current_result_dir
  mv $result_blood_dir $current_result_dir
  mv $model_free_dir $current_result_dir
  

  # This subject complete
  cd $current_working_dir
  
  rm -rf $temp_dir

done

echo "Turbo QUASAR analysis done!"

