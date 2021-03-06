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

mat_files.into { mat_files_speed; mat_files_motion }
//mat_files_speed.subscribe { println "Matlab file to be processed:" + it }

process get_speed {
  
  input:
  file file_worm from mat_files_speed
  
  output: 
  file '*_speed.csv' into speed_files
  
  script:
  println "Matlab file containing worm behavior processed: $file_worm"

  """
  $HOME/git/pergola/test/c_elegans_data_test/extract_worm_speed.py -i \"$file_worm\"
  """
}

speed_files_name = speed_files.flatten().map { speed_file_name ->   
  println speed_file_name.name
  
  [ speed_file_name, speed_file_name.name ]
}

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
  set file ('speed_file'), val (name_file) from speed_files_name  
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
  
  set '*.no_tr.bed', body_part, name_file into bed_speed_no_track_line
  set '*.no_tr.bedGraph', body_part, name_file into bedGraph_speed_no_track_line
  
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

// read_worm_data.py command example 
// $HOME/git/pergola/test/c_elegans_data_test/read_worm_data.py -i "575 JU440 on food L_2011_02_17__11_00___3___1_features.mat"

//./extract_worm_motion.py -i "575 JU440 on food L_2011_02_17__11_00___3___1_features.mat"

process get_motion {
  
  input:
  file file_worm from mat_files_motion
  
  output: 
  file '*.csv' into motion_files
  
  script:
  println "Matlab file containing worm behavior processed: $file_worm"

  """
  $HOME/git/pergola/test/c_elegans_data_test/extract_worm_motion.py -i \"$file_worm\"
  """
}

motion_files_name = motion_files.flatten().map { motion_file_name ->   
  println motion_file_name.name
  
  [ motion_file_name, motion_file_name.name ]
}

map_motion_path = "$HOME/git/pergola/test/c_elegans_data_test/worms_motion2p.txt"
map_motion=file(map_motion_path)

process motion_to_pergola {
  input:
  set file ('motion_file'), val (name_file) from motion_files_name
  set worms_motion2p from map_motion
  
  output:
  set 'tr*.bed', name_file into bed_motion, bed_motion_wr
  set 'tr*.bedGraph', name_file into bedGraph_motion
  
  """
  pergola_rules.py -i $motion_file -m $worms_motion2p -nt
  pergola_rules.py -i $motion_file -m $worms_motion2p -f bedGraph -w 1 -nt 
  """
} 

//This ones can directly be processed with motion bed file
map_bed_path = "$HOME/git/pergola/test/c_elegans_data_test/bed2pergola.txt"
map_bed_pergola = file(map_bed_path)

bed_speed_spread_motion = bed_speed_no_track_line.spread( bed_motion )

process intersect_speed_motion {
	input:
	//set file ('bed_speed_no_tr'), val (body_part), val(speed_name) from bed_speed_no_track_line
	//set file ('motion_file'), val (motion_name) from bed_motion
	set file ('bed_speed_no_tr'), val (body_part), val(speed_name), file ('motion_file'), val (motion_name) from bed_speed_spread_motion
	file bed2pergola from map_bed_pergola
	
	output:
	set '*.mean.bed', body_part, speed_name, motion_name into bed_mean_speed_motion
	
	"""
	$HOME/git/pergola/test/c_elegans_data_test/celegans_speed_i_motion.py -s $bed_speed_no_tr -m $motion_file -b $bed2pergola 
	"""
}

// Creating results folder
result_dir_GB = file("$baseDir/results_GB")

result_dir_GB.with {
     if( !empty() ) { deleteDir() }
     mkdirs()
     println "Created: $result_dir_GB"
}

//tblOutDev = 'tblEvalOneOutDev.tbl'
//myFileDev = resultDirDev.resolve (tblOutDev)

out_fasta.subscribe {   
  fasta_file = it[0]
  //fasta_file.copyTo ( it[1] + ".fa" )
  fasta_file.copyTo( result_dir_GB.resolve ( it[1] + ".fa" ) )
}

bed_speed_no_nas.subscribe {   
  bed_file = it[0]
  //bed_file.copyTo ( it[1] + "." + it[2] + ".GB.bed" )
  bed_file.copyTo ( result_dir_GB.resolve ( it[1] + "." + it[2] + ".GB.bed" ) )
}

bedGraph_speed_no_nas.subscribe {   
  bedGraph_file = it[0]
  //bedGraph_file.copyTo ( it[1] + "." + it[2] + ".GB.bedGraph" )
  bedGraph_file.copyTo (result_dir_GB.resolve ( it[1] + "." + it[2] + ".GB.bedGraph" ) )
}

// Creating results folder
result_dir_mean = file("$baseDir/results_mean")

result_dir_mean.with {
     if( !empty() ) { deleteDir() }
     mkdirs()
     println "Created: $result_dir_mean"
}

bed_mean_speed_motion.subscribe {
  def pattern = it[3] =~/^*+.features_([a-z]+).csv$/
  bed_mean_file = it[0]
  //println "............" + pattern [0][1]  
  //bed_mean_file.copyTo ( it[1] + "." + it[2] + "." + pattern[0][1] + ".mean.bed" )
  bed_mean_file.copyTo ( result_dir_mean.resolve ( it[1] + "." + it[2] + "." + pattern[0][1] + ".mean.bed" ) )
}

// Creating motion results folder
result_dir_motion_GB = file("$baseDir/results_motion_GB")

result_dir_motion_GB.with {
     if( !empty() ) { deleteDir() }
     mkdirs()
     println "Created: $result_dir_motion_GB"
}

bed_motion_wr.subscribe {
  it[0].copyTo ( result_dir_motion_GB.resolve ( it[1] + ".motion.bed" ))
}
