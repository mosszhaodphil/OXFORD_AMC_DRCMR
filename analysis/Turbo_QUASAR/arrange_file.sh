# The input file should be organised like this:
# Four big chuncks (1 regular chunck * 2 shifts * 2 repeats)
# Each dynamic has seven dynamics (Crushed, Crushed, Non-crushed, Crushed, Crushed, Non-crushed, Low flip angle)
# Each dynamic has 11 TIs (called cardca phases in Philips PAR file)
# Each TI has control and tag pairs

# Input data
data_input=input

((n_dynamics=7))
((n_shift=2))
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

  # Do the same thing for repeat 2 of tag image
  fslroi shift_1_repeat_2_tag data_mean_shift_1_repeat_2_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_1_repeat_2_tag data_mean_shift_1_repeat_2_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  fslroi shift_2_repeat_2_tag data_mean_shift_2_repeat_2_tag_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_2_repeat_2_tag data_mean_shift_2_repeat_2_tag_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  # Local function to split each TI
  split_shift_repeat shift_1_repeat_2_tag_z_0_z_6 data_mean_shift_1_repeat_2_tag_z_0_z_6
  split_shift_repeat shift_1_repeat_2_tag_z_7_z_14 data_mean_shift_1_repeat_2_tag_z_7_z_14
  split_shift_repeat shift_2_repeat_2_tag_z_0_z_6 data_mean_shift_2_repeat_2_tag_z_0_z_6
  split_shift_repeat shift_2_repeat_2_tag_z_7_z_14 data_mean_shift_2_repeat_2_tag_z_7_z_14
  # Local function to rename each TI
  edit_file_name shift_1_repeat_2_tag_z_0_z_6
  edit_file_name shift_2_repeat_2_tag_z_0_z_6
  edit_file_name shift_1_repeat_2_tag_z_7_z_14
  edit_file_name shift_2_repeat_2_tag_z_7_z_14

  # Local funcion to merge file
  # Merge the bottom slices
  create_file_list shift_1_repeat_2_tag_z_0_z_6 shift_2_repeat_2_tag_z_0_z_6
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_2_tag_z_0_z_6 $read_in_file_list
  rm file_list_tis.txt
  # Merge the upper slices
  create_file_list shift_2_repeat_2_tag_z_7_z_14 shift_1_repeat_2_tag_z_7_z_14
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_2_tag_z_7_z_14 $read_in_file_list
  rm file_list_tis.txt

  # Merge the bottom and top slices
  fslmerge -z repeat_2_tag repeat_2_tag_z_0_z_6 repeat_2_tag_z_7_z_14
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


  # Do control image of repeat 2 of control image
  fslroi shift_1_repeat_2_control data_mean_shift_1_repeat_2_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_1_repeat_2_control data_mean_shift_1_repeat_2_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  fslroi shift_2_repeat_2_control data_mean_shift_2_repeat_2_control_z_0_z_6 0 64 0 64 $break_1 $segment_1_length
  fslroi shift_2_repeat_2_control data_mean_shift_2_repeat_2_control_z_7_z_14 0 64 0 64 $break_2 $segment_2_length
  # Local function to split each TI
  split_shift_repeat shift_1_repeat_2_control_z_0_z_6 data_mean_shift_1_repeat_2_control_z_0_z_6
  split_shift_repeat shift_1_repeat_2_control_z_7_z_14 data_mean_shift_1_repeat_2_control_z_7_z_14
  split_shift_repeat shift_2_repeat_2_control_z_0_z_6 data_mean_shift_2_repeat_2_control_z_0_z_6
  split_shift_repeat shift_2_repeat_2_control_z_7_z_14 data_mean_shift_2_repeat_2_control_z_7_z_14
  # Local function to rename each TI
  edit_file_name shift_1_repeat_2_control_z_0_z_6
  edit_file_name shift_2_repeat_2_control_z_0_z_6
  edit_file_name shift_1_repeat_2_control_z_7_z_14
  edit_file_name shift_2_repeat_2_control_z_7_z_14

  # Local funcion to merge file
  # Merge the bottom slices
  create_file_list shift_1_repeat_2_control_z_0_z_6 shift_2_repeat_2_control_z_0_z_6
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_2_control_z_0_z_6 $read_in_file_list
  rm file_list_tis.txt
  # Merge the upper slices
  create_file_list shift_2_repeat_2_control_z_7_z_14 shift_1_repeat_2_control_z_7_z_14
  read_in_file_list=$(<file_list_tis.txt)
  fslmerge -t repeat_2_control_z_7_z_14 $read_in_file_list
  rm file_list_tis.txt

  # Merge the bottom and top slices
  fslmerge -z repeat_2_control repeat_2_control_z_0_z_6 repeat_2_control_z_7_z_14

# Completed increasing sampling rate


# Now average the repeats
  fslmaths repeat_1_tag -add repeat_2_tag -div 2 data_tag
  fslmaths repeat_1_control -add repeat_2_control -div 2 data_control
# Done average repeats


# Take tag control difference
  fslmaths data_tag -sub data_control data_diff
# Done computing tag control difference

#fslmaths shift_1_repeat_1_tag -sub shift_1_repeat_2_control data_diff


# Produce a mask using control image
  fslmaths data_control -Tmean data_control_mean
  bet data_control_mean mask -m
# Done creating mask


