#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   echo "Runs the mag nextflow pipeline."
   echo "Details of the pipeline found at https://nf-co.re/mag/2.1.1"
   echo
   echo "Usage: run_mag.sh input_directory"
   echo "Input:"
   echo "input_file     File listing the fastq files to process, see https://nf-co.re/mag/2.1.1/usage"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 1 ]
then
  help
  echo "Please provide the correct number of input arguments"
  echo
  exit;
fi

# Check the input directory exists

INPUT=$1

if [ ! -f $INPUT ]
then
  help
  echo "The file $INPUT does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${INPUT}/mag-2.1.1_${RAND}
NEXTFLOW_PIPELINE_DIR='/home/vagrant/nf-pipelines/nf-core-mag-2.1.1'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--outdir ${OUTPUT} \
-w ${OUT_DIR}/work \
-profile singularity \
-with-tower -resume \
#-c /home/vagrant/nf_pipeline_scripts/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${OUT_DIR}/work
fi
