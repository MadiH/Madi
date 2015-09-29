#!/bin/bash
#PBS -N trimmomatic
#PBS -l walltime=02:00:00
#PBS -l select=1:ncpus=8:mem=22gb
#PBS -A uq-QAAFI


#Load modules
module load trimmomatic

# metrics for the run
START_TIME=$(date +%s)


# directories and files
BASE_DIR=/work2/uqrgilb3/
JOB_DIR=$BASE_DIR/$PBS_JOBID
INPUT_DIR=$JOB_DIR/input
LOG_FILE=$JOB_DIR/trimmomatic.log


# set up the run
mkdir -p $INPUT_DIR

# copy the data from your home folder to the compute node (insert the path to the folder which has your data below) change line 27 for each dataset
cp -pr $PBS_O_WORKDIR/Ross_3060_FR/mgm* $INPUT_DIR
cp -p $PBS_O_WORKDIR/illumina_primers_2012.txt $INPUT_DIR

# move to the compute node change line 31 according to raw dataset directory name
cd $INPUT_DIR

# Run trimmomatic and output to dir trimmomatic. Need to link to the program trimmomatic-0.32.jar, may need to use the full path to the software folder, need to set the -threads 2 depending on the number of cpu's specified above.
java -jar $TRIMM_JARS/trimmomatic-0.32.jar PE -threads 8 -phred33 *R1.fastq *R2.fastq 3060_output_forward_paired.fq.gz 3060_output_forward_unpaired.fq.gz 3060_output_reverse_paired.fq.gz 3060_output_reverse_unpaired.fq.gz ILLUMINACLIP:illumina_primers_2012.txt:2:40:15 SLIDINGWINDOW:4:15 MINLEN:36

# Delete original input files from the INPUT_DIR to reduce output file size, change the prefix according to the sample name
rm mgm* 

END_TIME=$(date +%s)
let "TOTAL = $END_TIME - $START_TIME"

echo "start time: $START_TIME" >> $LOG_FILE
echo "end time: $END_TIME" >> $LOG_FILE 
echo "Total time (seconds) = $TOTAL" >> $LOG_FILE

	#CLEANUP TMP FOLDER# this needs revision? the .fasta file will be different for trimmomatic as this program uses .fq input and output, so blank this out for testing then check what turns up in the tmp directory
#find /tmp -user uqrgilb3 -iname “.fasta” 2>&1 | grep -ve “Permission” | xargs -t -i rm {}

# now package up the results:
TAR_FILE_SUFFIX=trimmomatic.tar

cd $JOB_DIR/../
tar cf $PBS_JOBID.$TAR_FILE_SUFFIX $JOB_DIR/input $JOB_DIR/trimmomatic.log
gzip $PBS_JOBID.$TAR_FILE_SUFFIX 
cp -p $PBS_JOBID.$TAR_FILE_SUFFIX.gz $PBS_O_WORKDIR
rm -rf $JOB_DIR*