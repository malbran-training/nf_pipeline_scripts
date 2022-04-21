#!/bin/bash

#export HTTP_PROXY='http://wwwcache.sanger.ac.uk:3128'
#export HTTPS_PROXY='http://wwwcache.sanger.ac.uk:3128'
export NXF_ANSI_LOG=false
#export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

# Check number of input parameters and that files/directories exist
DATA_DIR=$1
REF=$2

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
-c /home/software/nf_pipeline_scripts/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${OUT_DIR}/work
fi
