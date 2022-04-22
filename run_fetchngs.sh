#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   echo "Runs the fetchngs nextflow pipeline."
   echo "Details of the pipeline found at https://nf-co.re/fetchngs"
   echo
   echo "Usage: run_fetchngs.sh file_of_accessions output_directory"
   echo "Input:"
   echo "file_of_accesions    List of accessions to download"
   echo "output_directory     Location to store the downloaded data"
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

INPUT=$1
OUTPUT=$2

if [ ! -f $INPUT ]
then
  help
  echo "The file $INPUT does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
WORK_DIR=${OUTPUT}/${RAND}
NEXTFLOW_PIPELINE_DIR='/home/vagrant/nf-pipelines/nf-core-fetchngs-1.5'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUTPUT

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--outdir ${OUTPUT} \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
#-c /home/vagrant/nf_pipeline_scripts/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
