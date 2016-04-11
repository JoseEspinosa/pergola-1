#!/usr/bin/env python

################################################################
### Jose A Espinosa. CSN/CB-CRG Group. April 2016            ###
################################################################
### Script reads c elegans behavioral DB data in bed format  ###
### generated using pergola_rules.py containing speed for    ###   
### a given body part and and intersect it with intervals    ###  
### encoding motion of the same animal (backward, formward,  ###
### paused). Once files are intersected the mean speed is    ###
### is calculated for the given motion type                  ###
################################################################

import pybedtools
from os import path, getcwd
from pergola import mapping
from pergola import intervals

base_dir = path.dirname(getcwd())
dir_development = base_dir + "/c_elegans_data_test/"

# out_dir = base_dir + "/test/"
out_dir = base_dir + "/c_elegans_data_test/"

mapping_bed = mapping.MappingInfo(base_dir + "/" + "bed2pergola.txt")

# speed bed file
# read file from input args
bed_speed_file = dir_development + "midbody.575_JU440_on_food_L_2011_02_17__16_43___3___11_features_speed.csv.bed"

int_data_speed = intervals.IntData(bed_speed_file, map_dict=mapping_bed.correspondence, header=False, 
                                   fields_names=['chrm', 'start', 'end', 'nature', 'value', 'strain', 'color'])

## List for bedGraph fields
# ['chrm', 'start', 'end', 'value']

speed_data_read = int_data_speed.read(relative_coord=False)
# speed_data_read.data

###################
# Generate to BedTool objects containing motion type (forward, backward, paused)

### Write phases file
### mapping.write_cytoband(int_data, end = int_data.max - int_data.min, delta=43200, start_phase="dark")

# light_ph_f = out_dir +  "phases_light.bed"
# dark_ph_f = out_dir + "phases_dark.bed"
# light_bed = pybedtools.BedTool(light_ph_f)
# dark_bed = pybedtools.BedTool(dark_ph_f)

# this file has to be the second input to this script
motion_bed_file = dir_development +  "575_JU440_on_food_L_2011_02_17__11_00___3___1_features_forward.csv.bed"

int_data_motion = intervals.IntData(motion_bed_file, map_dict=mapping_bed.correspondence, header=False, 
                                    fields_names=['chrm', 'start', 'end', 'nature', 'value', 'strain', 'color'])

speed_data_read = int_data_speed.read(relative_coord=False)
bed_obj_speed = speed_data_read.convert(mode="bed")
speed_BedTools = bed_obj_speed['chr1', '.'].create_pybedtools()

motion_data_read = int_data_motion.read(relative_coord=False)
bed_obj_motion = motion_data_read.convert(mode="bed")
motion_BedTools=bed_obj_motion['chr1', '.'].create_pybedtools()


# get name from args using nextflow
speed_BedTools.intersect(motion_BedTools).saveas(out_dir + 'forward_speed_575_JU440' + ".bed")
