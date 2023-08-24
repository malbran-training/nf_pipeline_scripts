#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
# URL:    https://www.cambridgebioinformatics.com
#
# Usage: run_ghru_assembly.sh [-h] -i input_directory -o output_directory
#

set -eu

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=23.04.1

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -i input_directory -o output_directory"
   echo
   echo "Runs the ghru assembly nextflow pipeline, see https://gitlab.com/cgps/ghru/pipelines/dsl2/pipelines/assembly"
   echo
   echo "optional arguments:"
   echo "  -h, --help           show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -i input_directory   directory containing the FASTQ files to be assembled"
   echo "  -o output_directory  directory to write the pipeline results to"
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
      i) # Input directory
         INPUT_DIR=$OPTARG;;
      o) # Output directory
         OUTPUT_DIR=$OPTARG;;
     \?) # Invalid option
         help
         echo "!!! Error: Invalid arguments"
         exit;;
   esac
done

# Check the input directory exists
if [ ! -d $INPUT_DIR ]
then
  help
  echo "!!! The input directory $INPUT_DIR does not exist"
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

# Create a unique directory for the output
RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${OUTPUT_DIR}/ghru-assembly-2.1.2_${RAND}
WORK_DIR=${OUT_DIR}/work

# Set the pipeline directory
NEXTFLOW_PIPELINE_DIR='/home/manager/nf-pipelines/assembly-2.1.2'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input data is: "$INPUT_DIR
echo "Output will be written to: "$OUT_DIR

# Run the pipeline
nextflow run \
${NEXTFLOW_PIPELINE_DIR}/main.nf \
--adapter_file ${NEXTFLOW_PIPELINE_DIR}/adapters.fas \
--qc_conditions ${NEXTFLOW_PIPELINE_DIR}/qc_conditions_nextera_relaxed.yml \
--input_dir ${INPUT_DIR} \
--fastq_pattern '*{R,_}{1,2}.f*q.gz' \
--output_dir ${OUT_DIR} \
--depth_cutoff 100 \
--confindr_db_path /home/manager/dbs/confindr/ \
--careful \
-w ${WORK_DIR} \
-with-tower -resume \
-c /home/manager/nf_pipeline_scripts/conf/bioinfsrv1.config,/home/manager/nf_pipeline_scripts/conf/pipelines/ghru_assembly.config

# Clean up on success (exit 0)
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi

set +eu
