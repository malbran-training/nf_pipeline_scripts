#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   echo "Runs the bactmap nextflow pipeline."
   echo "Details of the pipeline found at https://nf-co.re/bactmap"
   echo
   echo "Usage: run_bactmap.sh fastq_directory reference"
   echo "Input:"
   echo "fastq_directory     A directory containing the input fastq files and a file samplesheet.csv, see https://nf-co.re/bactmap/1.0.0/usage"
   echo "reference           A reference fasta file"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 2 ]
then
  help
  echo "Please provide the correct number of input arguments"
  echo
  exit;
fi

# Check the input directory and reference genome exists

DATA_DIR=$1
REF=$2

if [ ! -d $DATA_DIR ]
then
  help
  echo "The directory $DATA_DIR does not exist"
  echo
  exit;
fi

if [ ! -f $REF ]
then
  help
  echo "The reference file $REF does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${DATA_DIR}/bactmap-1.0.0_${RAND}
NEXTFLOW_PIPELINE_DIR='/home/vagrant/nf-pipelines/nf-core-bactmap-1.0.0'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input data is: "$DATA_DIR
echo "Output will be written to: "$OUT_DIR

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${DATA_DIR}/samplesheet.csv \
--outdir ${OUT_DIR} \
--reference ${REF} \
--iqtree \
-w ${OUT_DIR}/work \
-profile singularity \
-with-tower -resume \
-c /home/vagrant/nf_pipeline_scripts/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${OUT_DIR}/work
fi
