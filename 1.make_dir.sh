# Author: Navya Shukla
# Affiliation: University of Melbourne
# This script creates a set of directories for each target genome, to store output of Lift&Add
# It needs three arguments to run: --dir, the target directory, --genomes, as comma-seperated list of target genomes
# and --chr, a comma-seperated list of chromosomes. 

#!/bin/bash

# parse  arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      DIR="$2"
      shift 2
      ;;
    --genomes)
      GENOME_LIST="$2"
      shift 2
      ;;
    --chrs)
      CHR_LIST="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

#validate arguments
if [[ -z "$DIR" ]]; then
  echo "Error: output directory (--dir) is required" >&2
  exit 1
fi

if [[ -z "$GENOME_LIST" ]]; then
  echo "Error: list of genomes ( --genomes) required" >&2
  exit 1
fi

if [[ -z "$CHR_LIST" ]]; then
  echo "Error: list of chromosomes (--chr) is required" >&2
  exit 1
fi


IFS=',' read -r -a GENOMES <<< "$GENOME_LIST"
IFS=',' read -r -a CHRS  <<< "$CHR_LIST"

## array of target genome basenames
## array_0=(ThyCyn2.0 mSarHar1.11 AStuM DasVivv1.0 mMyrFas1 mDroGli1 mMacEug1 GCA900497805.2 mTriVul1 mBetpen1 phaCin4.1 PUasm1.0 mCanLor1.2)
## array of chromosomes
## array_1=(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr18 chr19 chr20 chr21 chr22)
## array_1=(chr19)

for genome in "${GENOMES[@]}"
do
   for chr in "${CHRS[@]}"
   do
	mkdir -p "$DIR/$genome/$chr"
   done
done
