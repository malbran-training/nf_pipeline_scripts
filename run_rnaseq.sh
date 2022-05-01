#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
#
# Usage: run_rnaseq.sh [-h] -i input_directory -f reference.fasta -g reference.gff
#

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -i input_directory -r reference.gff"
   echo
   echo "Runs the rnaseq nextflow pipeline, see https://nf-co.re/nextflow/3.6"
   echo
   echo "optional arguments:"
   echo "  -h, --help           show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -i input_directory	directory containing a CSV file 'samplesheet.csv' that contains the paths to your FASTQ files - see https://nf-co.re/mag/2.1.1/usage"
   echo "  -f reference.fasta	reference file in FASTA format"
   echo "  -g reference.gff 	reference file in GFF format"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 3 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Check the input directory exists

INPUT_DIR=$1
INPUT=${INPUT_DIR}"/samplesheet.csv"
FASTA=$2
GFF=$3

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

if [ ! -f $FASTA ]
then
  help
  echo "!!! The fasta file $FASTA does not exist"
  echo
  exit;
fi

if [ ! -f $GFF ]
then
  help
  echo "!!! The gff file $GFF does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${INPUT_DIR}/rnaseq-3.6_${RAND}
WORK_DIR=${OUT_DIR}/work
NEXTFLOW_PIPELINE_DIR='/home/jk843/nf-pipelines/nf-core-rnaseq-3.6'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR
echo

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--outdir ${OUT_DIR} \
--fasta ${FASTA} \
--gff ${GFF} \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c /home/jk843/nf_pipeline_scripts/conf/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
