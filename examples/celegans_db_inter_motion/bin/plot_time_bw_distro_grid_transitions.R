#!/usr/bin/env Rscript

#  Copyright (c) 2014-2016, Centre for Genomic Regulation (CRG).
#  Copyright (c) 2014-2016, Jose Espinosa-Carrasco and the respective authors.
#
#  This file is part of Pergola.
#
#  Pergola is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Pergola is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Pergola.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
### Jose A Espinosa. NPMMD/CB-CRG Group. Apr 2015                         ###
#############################################################################
### Mean values for each group of worms                                   ###
### Using bed files raw data to calculate time between motion periods     ### 
#############################################################################

# To use this script in ant first export this:
# export R_LIBS="/software/R/packages"

##Getting HOME directory 
home <- Sys.getenv("HOME")

### Execution example
## Rscript plot_speed_motion_mean.R --body_part="midbody" --pattern_worm="575_ju440" --motion="backward"
## Rscript plot_speed_motion_mean.R --body_part="midbody" --pattern_worm="N2" --motion="forward"

# ggplot2 package loaded locally, cluster version is older and is causing problems
library(ggplot2)
# library(ggplot2, lib.loc="/users/cn/jespinosa/R/library")

# Loading params plot:
# source (paste (home, "/git/mwm/lib/R/plot_param_public.R", sep=""))
source("https://raw.githubusercontent.com/cbcrg/mwm/master/lib/R/plot_param_public.R")

#####################
### VARIABLES
#Reading arguments
args <- commandArgs (TRUE) #if not it doesn't start to count correctly

## Default setting when no arguments passed
if ( length(args) < 1) {
  args <- c("--help")
}

## Help section
if("--help" %in% args) {
  cat("
      plot_speed_motion_mean.R
      
      Arguments:
      --bed_file=concat_bed_file     - character      
      --help                         - print this text
      
      Example:
      ./plot_speed_motion_mean.R --bed_file=\"path_to_file\" \n")
  
  q (save="no")
}

# Use to parse arguments beginning by --
parseArgs <- function(x) 
{
  strsplit (sub ("^--", "", x), "=")
}

#Parsing arguments
argsDF <- as.data.frame (do.call("rbind", parseArgs(args)))
argsL <- as.list (as.character(argsDF$V2))
names (argsL) <- argsDF$V1

# All arguments are mandatory
{
  if (is.null (argsL$bed_file_all_tr)) 
  {
    stop ("[FATAL]: bed_file_all_tr arg is mandatory")
  }
  else
  {
    bed_file_all_tr <- argsL$bed_file_all_tr
  }
}

{
  if (is.null (argsL$bed_file_for_for)) 
  {
    stop ("[FATAL]: bed_file_for_for arg is mandatory")
  }
  else
  {    
    bed_file_for_for <- argsL$bed_file_for_for
  }
}

{
  if (is.null (argsL$bed_file_back_back)) 
  {
    stop ("[FATAL]: bed_file_back_back arg is mandatory")
  }
  else
  {    
    bed_file_back_back <- argsL$bed_file_back_back
  }
}

{
  if (is.null (argsL$bed_file_for_back)) 
  {
    stop ("[FATAL]: bed_file_for_back arg is mandatory")
  }
  else
  {    
    bed_file_for_back <- argsL$bed_file_for_back
  }
}

{
  if (is.null (argsL$bed_file_back_for)) 
  {
    stop ("[FATAL]: bed_file_back_for arg is mandatory")
  }
  else
  {    
    bed_file_back_for <- argsL$bed_file_back_for
  }
}

{
  if (is.null (argsL$strain)) 
  {
    stop ("[FATAL]: bed_file_back_for arg is mandatory")
  }
  else
  {    
    strain <- argsL$strain
  }
}

# bed_file_all_tr <- "/Users/jespinosa/git/pergola/test/c_elegans_data_test/work/67/6576b0d81781d844b5f5d679f65121/time_bw_motion"
# bed_file_for_for <- "/Users/jespinosa/git/pergola/test/c_elegans_data_test/work/67/6576b0d81781d844b5f5d679f65121/time_for_for"
# bed_file_back_back <- "/Users/jespinosa/git/pergola/test/c_elegans_data_test/work/67/6576b0d81781d844b5f5d679f65121/time_back_back"
# bed_file_for_back <- "/Users/jespinosa/git/pergola/test/c_elegans_data_test/work/67/6576b0d81781d844b5f5d679f65121/time_for_back"
# bed_file_back_for <- "/Users/jespinosa/git/pergola/test/c_elegans_data_test/work/67/6576b0d81781d844b5f5d679f65121/time_back_for"

read_bed <- function (path_bed, tag) {
  info = file.info(path_bed)
  
  if (info$size == 0) { 
    return(data.frame (chr="chr1", start=0,end=0, transition=tag))
  }
  else { df <- read.csv(file=path_bed, header=F, sep="\t")
         colnames (df) <- c("chr", "start", "end")
         df$transition <- tag 
         return (df)
  }  
}

df_bed_file_all_tr <- read_bed (bed_file_all_tr, "All motion transitions")
df_bed_file_for_for <- read_bed (bed_file_for_for, "Forward to forward")
df_bed_file_back_back <- read_bed (bed_file_back_back, "Backward to backward")
df_bed_file_for_back <- read_bed (bed_file_for_back, "Forward to backward")
df_bed_file_back_for <- read_bed (bed_file_back_for, "Backward to forward")

df_bed <- rbind (df_bed_file_all_tr, df_bed_file_for_for, df_bed_file_back_back, df_bed_file_for_back, df_bed_file_back_for)

# We remove this fake rows they were included just to avoid last line of code above to crash
df_bed <- df_bed [!(df_bed$start == 0 & df_bed$end == 0), ]

# all files are equally named
name_file <- strain
name_out <- paste(name_file, ".png", sep="")

fps <- 30.03003003
df_bed$time_bw <- df_bed$end - df_bed$start

size_strips <- 12
size_titles <- 13
size_axis <- 12
size_axis_ticks <- 10
xmin <- -500
xmax <- 500

ggplot(df_bed, aes(x=time_bw)) + geom_density() +
  labs (x = "\nTime between motion", y = "Density\n", title = paste(strain, "\n", sep=" ")) + 
  scale_x_continuous (breaks=c(xmin, 0, xmax), limits=c(xmin-100, xmax+100)) +
#   scale_y_continuous (limits=c(0, 0.02)) +
  facet_grid (. ~ transition) +
  theme(strip.text.x = element_text(size=size_strips, face="bold")) +
  theme(plot.title = element_text(size=size_titles)) + 
  theme(axis.title.x = element_text(size=size_axis)) +
  theme(axis.title.y = element_text(size=size_axis)) +
  theme(axis.text.x = element_text(size=size_axis_ticks)) +  
  theme(axis.text.y = element_text(size=size_axis_ticks)) +  
  theme(strip.background = element_blank()) 

ggsave(file=name_out, width=12, height=6)


