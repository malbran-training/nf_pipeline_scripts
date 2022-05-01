#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
#
# Usage: run_bactmap.sh [-h] -d input_directory -r reference.fasta
#

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -i input_directory -r reference"
   echo
   echo "Runs the bactmap nextflow pipeline, see https://nf-co.re/bactmap/1.0.0"
   echo
   echo "optional arguments:"
   echo "  -h, --help		show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -i input_directory	directory containing a CSV file 'samplesheet.csv' that contains the paths to your FASTQ files - see https://nf-co.re/bactmap/1.0.0/usage"
   echo "  -r reference		reference fasta file"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 2 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Check the input directory and reference genome exists

INPUT_DIR=$1
INPUT=${INPUT_DIR}/"samplesheet.csv"
REF=$2

if [ ! -d $INPUT_DIR ]
then
  help
  echo "!!! The directory $INPUT_DIR does not exist"
  echo
  exit;
fi

if [ ! -f $INPUT ]
then
  help
  echo "!!! The file $INPUT does not exist"
  echo
  exit;
fi

if [ ! -f $REF ]
then
  help
  echo "!!! The reference file $REF does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${INPUT_DIR}/bactmap-1.0.0_${RAND}
WORK_DIR=${OUT_DIR}/work
NEXTFLOW_PIPELINE_DIR='/home/jk843/nf-pipelines/nf-core-bactmap-1.0.0'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT_DIR}/samplesheet.csv \
--outdir ${OUT_DIR} \
--reference ${REF} \
--iqtree \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c /home/jk843/nf_pipeline_scripts/conf/bakersrv1.config,/home/jk843/nf_pipeline_scripts/conf/pipelines/bactmap.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
