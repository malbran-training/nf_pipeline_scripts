#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
# URL:    https://www.cambridgebioinformatics.com
#
# Usage: run_ghru_mlst.sh [-h] -s species -i input_directory -o output_directory
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
   echo "usage: "$script" [-h] -s species -i input_directory -o output_directory"
   echo
   echo "Runs the ghru mlst nextflow pipeline, see https://gitlab.com/cgps/ghru/pipelines/dsl2/pipelines/mlst"
   echo
   echo "optional arguments:"
   echo "  -h		show this help message and exit"
   echo "  -l		show valid species list"
   echo
   echo "required arguments:"
   echo "  -s species		      species"
   echo "  -i input_directory	   directory containing the FASTQ files to analyse"
   echo "  -o output_directory	directory to write the pipeline results to"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

function list
{
   # display list of valid species
   cat << EOM
The valid MLST schemes are:
achromobacter_spp.
acinetobacter_baumannii
aeromonas_spp.
anaplasma_phagocytophilum
arcobacter_spp.
aspergillus_fumigatus
bacillus_cereus
bacillus_licheniformis
bacillus_subtilis
bartonella_bacilliformis
bartonella_henselae
bartonella_washoensis
bordetella_spp.
borrelia_spp.
brachyspira_hampsonii
brachyspira_hyodysenteriae
brachyspira_intermedia
brachyspira_pilosicoli
brachyspira_spp.
brucella_spp.
burkholderia_cepacia_complex
burkholderia_pseudomallei
campylobacter_concisus_curvus
campylobacter_fetus
campylobacter_helveticus
campylobacter_hyointestinalis
campylobacter_insulaenigrae
campylobacter_jejuni
campylobacter_lanienae
campylobacter_lari
campylobacter_sputorum
campylobacter_upsaliensis
candida_albicans
candida_glabrata
candida_krusei
candida_tropicalis
candidatus_liberibacter_solanacearum
carnobacterium_maltaromaticum
chlamydiales_spp.
citrobacter_freundii
clonorchis_sinensis
clostridioides_difficile
clostridium_botulinum
clostridium_septicum
corynebacterium_diphtheriae
cronobacter_spp.
dichelobacter_nodosus
edwardsiella_spp.
enterobacter_cloacae
enterococcus_faecalis
enterococcus_faecium
escherichia_coli
flavobacterium_psychrophilum
gallibacterium_anatis
haemophilus_influenzae
haemophilus_parasuis
helicobacter_cinaedi
helicobacter_pylori
helicobacter_suis
kingella_kingae
klebsiella_aerogenes
klebsiella_oxytoca
klebsiella_pneumoniae
kudoa_septempunctata
lactobacillus_salivarius
leptospira_spp.
listeria_monocytogenes
macrococcus_canis
macrococcus_caseolyticus
mannheimia_haemolytica
melissococcus_plutonius
moraxella_catarrhalis
mycobacteria_spp.
mycobacterium_abscessus
mycobacterium_massiliense
mycoplasma_agalactiae
mycoplasma_bovis
mycoplasma_flocculare
mycoplasma_hominis
mycoplasma_hyopneumoniae
mycoplasma_hyorhinis
mycoplasma_iowae
mycoplasma_pneumoniae
mycoplasma_synoviae
neisseria_spp.
orientia_tsutsugamushi
ornithobacterium_rhinotracheale
paenibacillus_larvae
pasteurella_multocida
pediococcus_pentosaceus
photobacterium_damselae
piscirickettsia_salmonis
porphyromonas_gingivalis
propionibacterium_acnes
pseudomonas_aeruginosa
pseudomonas_fluorescens
pseudomonas_putida
rhodococcus_spp.
riemerella_anatipestifer
salmonella_enterica
saprolegnia_parasitica
sinorhizobium_spp.
staphylococcus_aureus
staphylococcus_epidermidis
staphylococcus_haemolyticus
staphylococcus_hominis
staphylococcus_lugdunensis
staphylococcus_pseudintermedius
stenotrophomonas_maltophilia
streptococcus_agalactiae
streptococcus_bovis_equinus_complex
streptococcus_canis
streptococcus_dysgalactiae_equisimilis
streptococcus_gallolyticus
streptococcus_oralis
streptococcus_pneumoniae
streptococcus_pyogenes
streptococcus_suis
streptococcus_thermophilus
streptococcus_uberis
streptococcus_zooepidemicus
streptomyces_spp
taylorella_spp.
tenacibaculum_spp.
treponema_pallidum
trichomonas_vaginalis
ureaplasma_spp.
vibrio_cholerae
vibrio_parahaemolyticus
vibrio_spp.
vibrio_tapetis
vibrio_vulnificus
wolbachia
xylella_fastidiosa
yersinia_pseudotuberculosis
yersinia_ruckeri
EOM
}

# Set the specis to empty
SPECIES=""

# Check number of input parameters
NAG=$#
if [ $NAG -ne 1 ] && [ $NAG -ne 2 ] && [ $NAG -ne 6 ] && [ $NAG -ne 7 ] && [ $NAG -ne 8 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Get the options
while getopts "hls:i:o:" option; do
   case $option in
      h) # display help
         help
         exit;;
      l) # display species list
         list
         exit;;
      s) # Species
         SPECIES=$OPTARG;;
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

# Check the MLST species
VALID_SPECIES=false
for TEST_SPECIES in achromobacter_spp. acinetobacter_baumannii aeromonas_spp. anaplasma_phagocytophilum arcobacter_spp. aspergillus_fumigatus bacillus_cereus bacillus_licheniformis bacillus_subtilis bartonella_bacilliformis bartonella_henselae bartonella_washoensis bordetella_spp. borrelia_spp. brachyspira_hampsonii brachyspira_hyodysenteriae brachyspira_intermedia brachyspira_pilosicoli brachyspira_spp. brucella_spp. burkholderia_cepacia_complex burkholderia_pseudomallei campylobacter_concisus_curvus campylobacter_fetus campylobacter_helveticus campylobacter_hyointestinalis campylobacter_insulaenigrae campylobacter_jejuni campylobacter_lanienae campylobacter_lari campylobacter_sputorum campylobacter_upsaliensis candida_albicans candida_glabrata candida_krusei candida_tropicalis candidatus_liberibacter_solanacearum carnobacterium_maltaromaticum chlamydiales_spp. citrobacter_freundii clonorchis_sinensis clostridioides_difficile clostridium_botulinum clostridium_septicum corynebacterium_diphtheriae cronobacter_spp. dichelobacter_nodosus edwardsiella_spp. enterobacter_cloacae enterococcus_faecalis enterococcus_faecium escherichia_coli flavobacterium_psychrophilum gallibacterium_anatis haemophilus_influenzae haemophilus_parasuis helicobacter_cinaedi helicobacter_pylori helicobacter_suis kingella_kingae klebsiella_aerogenes klebsiella_oxytoca klebsiella_pneumoniae kudoa_septempunctata lactobacillus_salivarius leptospira_spp. listeria_monocytogenes macrococcus_canis macrococcus_caseolyticus mannheimia_haemolytica melissococcus_plutonius moraxella_catarrhalis mycobacteria_spp. mycobacterium_abscessus mycobacterium_massiliense mycoplasma_agalactiae mycoplasma_bovis mycoplasma_flocculare mycoplasma_hominis mycoplasma_hyopneumoniae mycoplasma_hyorhinis mycoplasma_iowae mycoplasma_pneumoniae mycoplasma_synoviae neisseria_spp. orientia_tsutsugamushi ornithobacterium_rhinotracheale paenibacillus_larvae pasteurella_multocida pediococcus_pentosaceus photobacterium_damselae piscirickettsia_salmonis porphyromonas_gingivalis propionibacterium_acnes pseudomonas_aeruginosa pseudomonas_fluorescens pseudomonas_putida rhodococcus_spp. riemerella_anatipestifer salmonella_enterica saprolegnia_parasitica sinorhizobium_spp. staphylococcus_aureus staphylococcus_epidermidis staphylococcus_haemolyticus staphylococcus_hominis staphylococcus_lugdunensis staphylococcus_pseudintermedius stenotrophomonas_maltophilia streptococcus_agalactiae streptococcus_bovis_equinus_complex streptococcus_canis streptococcus_dysgalactiae_equisimilis streptococcus_gallolyticus streptococcus_oralis streptococcus_pneumoniae streptococcus_pyogenes streptococcus_suis streptococcus_thermophilus streptococcus_uberis streptococcus_zooepidemicus streptomyces_spp taylorella_spp. tenacibaculum_spp. treponema_pallidum trichomonas_vaginalis ureaplasma_spp. vibrio_cholerae vibrio_parahaemolyticus vibrio_spp. vibrio_tapetis vibrio_vulnificus wolbachia xylella_fastidiosa yersinia_pseudotuberculosis yersinia_ruckeri 
do
    if [[ ${TEST_SPECIES} == *_spp. ]]
    then
        TEST_GENUS=${TEST_SPECIES%*_spp.}
        SPECIES_GENUS=${SPECIES%*_*}
        if [[ $TEST_GENUS == $SPECIES_GENUS ]]
        then
            VALID_SPECIES=$TEST_SPECIES
        fi
    else
        if [[ $SPECIES == $TEST_SPECIES ]]
        then
            VALID_SPECIES=$TEST_SPECIES
        fi
    fi
done

if [[ $VALID_SPECIES == "false" ]]
then
   list
   exit;
fi
MLST_SPECIES=$(echo ${VALID_SPECIES} | sed -e 's/^\(.\)/\U\1/' | sed -e 's/_/ /g')

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

# Create a unique directory to store the output
RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${OUTPUT_DIR}/ghru-mlst-1.4_${RAND}
WORK_DIR=${OUT_DIR}/work

# Set the location of the nextflow pipeline
NEXTFLOW_PIPELINE_DIR='/home/manager/nf-pipelines/mlst-1.2'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input data is: "$INPUT_DIR
echo "Output will be written to: "$OUT_DIR
echo "Species is: "$SPECIES

# Run the nextflow pipeline
nextflow run \
${NEXTFLOW_PIPELINE_DIR}/main.nf \
--input_dir ${INPUT_DIR} \
--fastq_pattern '*{R,_}{1,2}.f*q.gz' \
--output_dir ${OUT_DIR} \
--read_polishing_depth_cutoff 100 \
--mlst_species "${MLST_SPECIES}" \
-w ${WORK_DIR} \
-with-tower -resume \
-c /home/manager/nf_pipeline_scripts/conf/bioinfsrv1.config,/home/manager/nf_pipeline_scripts/conf/pipelines/ghru_mlst.config

# Clean up on success (exit 0)
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi

set +eu
