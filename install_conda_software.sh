#!/bin/bash

set -eu

conda config --set always_yes yes

# Install software using miniconda
echo "Reading bioconda software list!"
while read -r line;
do
    echo "Installing ${line}"
    # Split line on comma into environment and software list
    IFS=',' read -a myarray <<<  $line
    environment=${myarray[0]}
    software=${myarray[1]}
    # Create a new conda environment with the software
    conda create -n $environment $software
done < software.txt

conda config --set always_yes no

set +eu
