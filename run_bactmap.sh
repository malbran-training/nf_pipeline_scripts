#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

# Check number of input parameters and that files/directories exist
DATA_DIR=$1
REF=$2

NEXTFLOW_PIPELINE_DIR='/home/vagrant/nf-pipelines/nf-core-bactmap-1.0.0'
#OUT_DIR - randomise with the date and time

echo $NEXTFLOW_PIPELINE_DIR
echo $DATA_DIR
echo $REF

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${DATA_DIR}/samplesheet.csv \
--outdir ${DATA_DIR}/bactmap-1.0.0 \
--reference ${REF} \
--iqtree \
-w ${DATA_DIR}/bactmap-1.0.0/work \
-with-tower -qs 1000 -resume
#-c ${NEXTFLOW_PIPELINE_DIR}/user.config \

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${DATA_DIR}/bactmap-1.0.0/work
fi
