#!/usr/bin/env nextflow

/*
#################################################################################
### Jose Espinosa-Carrasco. CB/CSN-CRG. April 2016                            ###
#################################################################################
### Code : 04.12                                                              ### 
### Worm DB processed by pergola for paper                                    ###
#################################################################################
*/

//path_files = "$HOME/2016_worm_DB/ju440_all/"
params.path_files = "$HOME/git/pergola/test/c_elegans_data_test/"

mat_files_path = "${params.path_files}*.mat"
mat_files = Channel.fromPath(mat_files_path)

// read_worm_data.py command example 
// $HOME/git/pergola/test/c_elegans_data_test/read_worm_data.py -i "575 JU440 on food L_2011_02_17__11_00___3___1_features.mat"


// Name of input file and file 
mat_files_name = mat_files.flatten().map { mat_files_file ->      
   def content = mat_files_file
   def name = mat_files_file.name.replaceAll(/ /,'_')
   [ content, name ]
}

mat_files_name.into { mat_files_speed; mat_files_motion }

process get_speed {

  input:
  set file ('file_worm'), val (name_file_worm) from mat_files_speed

  
  output:  
  set '*_speed.csv', name_file_worm into speed_files, speed_files_toprint
    
  script:
  println "Matlab file containing worm behavior processed: $name_file_worm"

  """
  $HOME/git/pergola/test/c_elegans_data_test/extract_worm_speed.py -i $file_worm
  """
}


speed_files_toprint.subscribe {
	println ">>>> ${it[0].name}"	
}

/*
speed_files_name = speed_files.flatten().map { //speed_file_name ->
  file_speed = it[0]  
  mat_file_name = it[1]
  //println speed_file_name.name
  println "file_speed_name -------- mat_file_name"
  //[ speed_file_name, speed_file_name.name ]
  [ file_speed, file_speed_name, mat_file_name ]
}
*/


// pergola command

// pergola_rules.py -i "575 JU440 on food L_2011_02_17__11_00___3___1_features_speed.csv" -m worms_speed2p.txt
"575 JU440 on food L_2011_02_17__11_00___3___1_features_speed.csv"
//-d one_per_channel 
//-nt -nh -s

map_speed_path = "$HOME/git/pergola/test/c_elegans_data_test/worms_speed2p.txt"
map_speed=file(map_speed_path)

body_parts =  ['head', 'headTip', 'midbody', 'tail', 'tailTip']

process speed_to_pergola {
  input:
  set file ('speed_file'), val (name_file) from speed_files  
  file worms_speed2p from map_speed
  each body_part from body_parts
  
  output: 
  set 'tr*.bed', body_part, name_file into bed_speed
  set 'tr*.bedGraph', body_part, name_file into bedGraph_speed
  set '*.fa', name_file, name_file into out_fasta
  
  """
  cat $worms_speed2p | sed 's/behavioural_file:$body_part > pergola:dummy/behavioural_file:$body_part > pergola:data_value/g' > mod_map_file   
  pergola_rules.py -i $speed_file -m mod_map_file
  pergola_rules.py -i $speed_file -m mod_map_file -f bedGraph -w 1 
  """
}

process zeros_bed_and_bedGraph {
  input:
  set file ('bed_file'), val(body_part), val(name_file) from bed_speed
  set file ('bedGraph_file'), val(body_part), val(name_file) from bedGraph_speed
  	
  output:
  set '*.no_na.bed', body_part, name_file into bed_speed_no_nas
  set '*.no_na.bedGraph', body_part, name_file into bedGraph_speed_no_nas
  
  //set '*.no_tr.bed', body_part, name_file into bed_speed_no_track_line
  //set '*.no_tr.bedGraph', body_part, name_file into bedGraph_speed_no_track_line
  set name_file, body_part, '*.no_tr.bed' into bed_speed_no_track_line
  set name_file, body_part, '*.no_tr.bedGraph' into bedGraph_speed_no_track_line
  
  //cat ${bed_file}".tmp" | sed 's/-10000/0/g' > ${bed_file}".bedZeros"
  //cat ${bedGraph_file}".tmp" | sed 's/-10000/0/g' > ${bedGraph_file}".bedGraphZeros"
 
  //echo -e "chr1\t0\t100\t.\t-10000\t+\t0\t100\t135,206,250" >> ${bed_file}${name_file}".no_na.bed"
  //echo -e "chr1\t0\t100\t100000" >> ${bedGraph_file}".no_na.bedGraph"
  //cat ${bed_file}${name_file}".no_na.bed" | grep -v "track name" > ${bed_file}".no_tr.bed" || echo -e "chr1\t0\t100\t.\t100000\t+\t0\t100\t135,206,250\n" > ${bed_file}".no_tr.bed"
   
  """
  cat $bed_file | sed 's/track name=\"1_a\"/track name=\"${body_part}_speed\"/g' > ${bed_file}".tmp"
  cat ${bed_file}".tmp" | grep -v "\\-10000" > ${bed_file}${name_file}".no_na.bed"  
  cat ${bed_file}${name_file}".no_na.bed" | grep -v "track name" > ${bed_file}".no_tr.bed" || echo -e "chr1\t0\t100\t.\t-10000\t+\t0\t100\t135,206,250" > ${bed_file}".no_tr.bed"
  
  cat $bedGraph_file | sed 's/track name=\"1_a\"/track name=\"${body_part}_speed\"/g' > ${bedGraph_file}".tmp"
  cat ${bedGraph_file}".tmp" | grep -v "\\-10000" > ${bedGraph_file}".no_na.bedGraph"  
  cat ${bedGraph_file}".no_na.bedGraph" | grep -v "track name" > ${bedGraph_file}".no_tr.bedGraph" || echo -e echo -e "chr1\t0\t100\t100000" > ${bedGraph_file}".no_tr.bedGraph" 
  """			
}

////////

// read_worm_data.py command example 
// $HOME/git/pergola/test/c_elegans_data_test/read_worm_data.py -i "575 JU440 on food L_2011_02_17__11_00___3___1_features.mat"

//./extract_worm_motion.py -i "575 JU440 on food L_2011_02_17__11_00___3___1_features.mat"

process get_motion {
  
  input:
  set file ('file_worm'), val (name_file_worm) from mat_files_motion
  
  output: 
  set name_file_worm, '*.csv' into motion_files, motion_files_cp
    
  script:
  println "Matlab file containing worm behavior processed: $file_worm"

  """
  $HOME/git/pergola/test/c_elegans_data_test/extract_worm_motion.py -i \"$file_worm\"
  """
}

motion_files_cp.subscribe {
	//println "************" + it[0]
	println it[1]
	
}

// From 1 mat I get 3 motions (forward, paused, backward)
// I made a channel with matfile1 -> forward
//                       matfile1 -> backward
//                       matfile1 -> paused
//                       matfile2 -> forward ...

motion_files_flat = motion_files.map { name_mat, motion_f ->
        motion_f.collect {            
            [ it, name_mat ]
        }
    }
    .flatMap()

/*
motion_files_flat.subscribe {
	println "#############" + it[0] + it[1]
}
*/
    
map_motion_path = "$HOME/git/pergola/test/c_elegans_data_test/worms_motion2p.txt"
map_motion=file(map_motion_path)

process motion_to_pergola {
  input:
  set file ('motion_file'), val (name_file) from motion_files_flat
  set worms_motion2p from map_motion
  
  output:
  set name_file, 'tr*.bed' into bed_motion, bed_motion_wr
  set name_file, 'tr*.bedGraph' into bedGraph_motion
  
  """
  pergola_rules.py -i $motion_file -m $worms_motion2p -nt
  pergola_rules.py -i $motion_file -m $worms_motion2p -f bedGraph -w 1 -nt 
  """
} 

//This ones can directly be processed with motion bed file
map_bed_path = "$HOME/git/pergola/test/c_elegans_data_test/bed2pergola.txt"
map_bed_pergola = file(map_bed_path)

//set name_file, body_part, '*.no_tr.bed' into bed_speed_no_track_line

//bed_speed_motion = bed_speed_no_track_line.phase(bed_motion).flatten().toList()
//.map { name_mat, motion_f ->
//bed_speed_motion = bed_speed_no_track_line.phase(bed_motion) {

bed_speed_motion = bed_speed_no_track_line.phase(bed_motion).map { speed, motion ->
		//println "kkkkkkkkk" + speed + motion
		[ speed[0], speed[1], speed[2], motion[0], motion[1] ]
		//[ it[0][0], it[0][1], it[0][2], it[1][0], it[1][1] ]
		//[ it[0][0], it[0][1], it[0][2] ]
	}

/*
bed_speed_motion.subscribe { 
		println "####=+++++++++++" + it		
	}
*/	


/*
.map {
	[ it[0], it[1], it[2], it[3], it[4] ]
}


.map { //speed_file_name ->
  file_speed = it[0]  
  mat_file_name = it[1]
  //println speed_file_name.name
  println "file_speed_name -------- mat_file_name"
  //[ speed_file_name, speed_file_name.name ]
  [ file_speed, file_speed_name, mat_file_name ]
}

mat_files_name = mat_files.flatten().map { mat_files_file ->      
   def content = mat_files_file
   def name = mat_files_file.name.replaceAll(/ /,'_')
   [ content, name ]
}
*/


	
process intersect_speed_motion {
	input:
	set val (mat_file_speed), val (body_part), file ('bed_speed_no_tr'), val (mat_motion_file), file ('motion_file') from bed_speed_motion
	file bed2pergola from map_bed_pergola
	
	output:
	set '*.mean.bed', body_part, mat_file_speed, mat_motion_file into bed_mean_speed_motion
	//set '*.del' into del_file
	
	
	"""
	$HOME/git/pergola/test/c_elegans_data_test/celegans_speed_i_motion.py -s $bed_speed_no_tr -m $motion_file -b $bed2pergola	
	"""
}


