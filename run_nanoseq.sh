#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   echo "Runs the nanoseq nextflow pipeline."
   echo "Details of the pipeline found at https://nf-co.re/nanoseq"
   echo
   echo "Usage: run_nanoseq.sh file_of_accessions output_directory"
   echo "Input:"
   echo "input_file 	      File of information about samples to be processed, see https://nf-co.re/nanoseq/usage for details"
   echo "output_directory     Where to store the results of the pipeline"
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
NEXTFLOW_PIPELINE_DIR='/home/vagrant/nf-pipelines/nf-core-nanoseq-2.0.1'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUTPUT

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--input_path ./fast5/ \
--protocol DNA \
--flowcell FLO-MIN106 \
--kit SQK-LSK109 \
--barcode_kit SQK-PBK004 \
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
