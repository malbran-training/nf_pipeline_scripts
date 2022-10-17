#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
# URL:    https://www.cambridgebioinformatics.com
#
# Usage: run_mag.sh [-h] -i input_file -o output_directory
#

set -eu

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -i input_directory"
   echo
   echo "Runs the mag nextflow pipeline, see https://nf-co.re/mag/2.1.1"
   echo
   echo "optional arguments:"
   echo "  -h           show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -i input_file	a CSV file that contains the paths to your FASTQ files - see https://nf-co.re/mag/2.1.1/usage"
   echo "  -o output_directory	directory to write the pipeline results to"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 1 ] && [ $NAG -ne 4 ] && [ $NAG -ne 5 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Get the options
while getopts "hi:o:" option; do
   case $option in
      h) # display help
         help
         exit;;
      i) # Input file
         INPUT=$OPTARG;;
      o) # Output directory
         OUTPUT_DIR=$OPTARG;;
     \?) # Invalid option
         help
         echo "!!! Error: Invalid arguments"
         exit;;
   esac
done

# Check the input file exists
if [ ! -f $INPUT ]
then
  help
  echo "!!! The input file $INPUT does not exist"
  echo
  exit;
fi

# Check the output directory exists
if [ ! -d $OUTPUT_DIR ]
then
  help
  echo "!!! The output directory $OUTPUT_DIR does not exist"
  echo
  exit;
fi

# Create a unique directory to store the output
RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${OUPUT_DIR}/mag-2.1.1_${RAND}
WORK_DIR=${OUT_DIR}/work

# Set the nextflow pipeline directory
NEXTFLOW_PIPELINE_DIR='/home/software/nf-pipelines/nf-core-mag-2.1.1'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR
echo

# Run the pipeline
nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--outdir ${OUT_DIR} \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c /home/software/nf_pipeline_scripts/conf/bioinfsrv1.config

# Clean up on success (exit 0)
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi

set +eu
