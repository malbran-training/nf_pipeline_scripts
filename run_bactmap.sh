#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
# URL:    https://www.cambridgebioinformatics.com
#
# Usage: run_bactmap.sh [-h] [-g] -i input_samplesheet -r reference_file -o output_directory
#

set -eu 

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

source $MINICONDA/etc/profile.d/conda.sh

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] [-g] -i samplesheet.csv -r reference_file -o output_directory"
   echo
   echo "Runs the bactmap nextflow pipeline, see https://nf-co.re/bactmap/1.0.0"
   echo
   echo "optional arguments:"
   echo "  -h			show this help message and exit"
   echo "  -g			remove recombination with gubbins, default is to not run gubbins"
   echo
   echo "required arguments:"
   echo "  -i samplesheet.csv	a CSV file 'samplesheet.csv' that contains the paths to your FASTQ files - see https://nf-co.re/bactmap/1.0.0/usage"
   echo "  -r reference		reference fasta file"
   echo "  -o output_directory  directory to store the output from the pipelines"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Assume do not remove recombination
GUBBINS=""

# Check number of input parameters 
NAG=$#
if [ $NAG -ne 1 ] && [ $NAG -ne 6 ] && [ $NAG -ne 7 ] && [ $NAG -ne 8 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Get the options
while getopts "hgi:r:o:" option; do
   case $option in
      h) # display help
         help
         exit;;
      g) # Remove recombination
         GUBBINS="--remove_recombination";;
      i) # Input file
         INPUT=$OPTARG;;
      r) # Reference
         REF=$OPTARG;;
      o) # Output directory
         OUTPUT_DIR=$OPTARG;;
     \?) # Invalid option
         help
	 echo "!!!Error: Invalid arguments"
         exit;;
   esac
done

# Check the input directory and reference genome exists
if [ ! -f $INPUT ]
then
  help
  echo "!!! The input file $INPUT does not exist"
  echo
  exit;
fi

# Check the refernce genome exists
if [ ! -f $REF ]
then
  help
  echo "!!! The reference file $REF does not exist"
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

# Create a unique directory for the outout
RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${OUTPUT_DIR}/bactmap-1.0.0_${RAND}
WORK_DIR=${OUT_DIR}/work

# Set the pipeline directory
NEXTFLOW_PIPELINE_DIR='/home/software/nf-pipelines/nf-core-bactmap-1.0.0'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR

# Run the pipeline
nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--outdir ${OUT_DIR} \
--reference ${REF} \
--iqtree \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c /home/software/nf_pipeline_scripts/conf/bioinfsrv1.config,/home/software/nf_pipeline_scripts/conf/pipelines/bactmap.config \
${GUBBINS}

# Clean up on success (exit 0)
status=$?
if [[ $status -eq 0 ]]; then
   rm -r ${WORK_DIR}
   # Generate coverage stats
   OUT_DIR_PATH=$(realpath $OUT_DIR)
   REF_PATH=$(realpath $REF)
   cd ${OUT_DIR_PATH}/samtools
   FILES="./*.bam"
   conda activate samtools-1.15
   for f in $FILES
    do
      samtools coverage --reference $REF_PATH $f > $f.coverage
   done
   awk '{print FILENAME"\t"$0}' *.coverage > all.tsv
   less all.tsv | sort | uniq > coverage_summary.tsv
   mv coverage_summary.tsv ../multiqc
   conda deactivate
fi

set +eu
