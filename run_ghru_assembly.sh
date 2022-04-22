#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   echo "Runs the ghru assembly nextflow pipeline."
   echo
   echo "Usage: run_ghru_asembly.sh fastq_directory"
   echo "Input:"
   echo "fastq_directory     A directory containing the input fastq files"
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

DATA_DIR=$1

if [ ! -d $DATA_DIR ]
then
  help
  echo "The directory $DATA_DIR does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${DATA_DIR}/ghru-assembly-2.1.2_${RAND}
NEXTFLOW_PIPELINE_DIR='/home/vagrant/nf-pipelines/ghru-assembly-2.1.2'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input data is: "$DATA_DIR
echo "Output will be written to: "$OUT_DIR

nextflow run \
${NEXTFLOW_PIPELINE_DIR}/main.nf \
--adapter_file ${NEXTFLOW_PIPELINE_DIR}/adapters.fas \
--qc_conditions ${NEXTFLOW_PIPELINE_DIR}/qc_conditions_nextera_relaxed.yml \
--input_dir ${DATA_DIR} \
--fastq_pattern '*{R,_}{1,2}.f*q.gz' \
--output_dir ${OUT_DIR} \
--depth_cutoff 100 \
--confindr_db_path /data/dbs/confindr/ \
--careful \
-w ${OUT_DIR}/work \
-profile singularity \
-with-tower -resume \
-c /home/vagrant/nf_pipeline_scripts/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${OUT_DIR}/work
fi
