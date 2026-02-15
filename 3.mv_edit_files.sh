# Author: Navya Shukla
# Affiliation: University of Melbourne
# This script moves output conserved elements fasta files obtained for each target genome into appropriate chromosome directory and renames the fasta header of each file  by species.

#!/bin/bash

#parse arguments

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      DIR="$2"
      shift 2
      ;;
    --genomes)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --genomes requires a comma-separated value list" >&2
        exit 1
      fi
      GENOME_LIST="$2"
      shift 2
      ;;
    --chrs)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --chrs requires a comma-separated value list" >&2
        exit 1
      fi
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

if [[ ! -d "$DIR" ]]; then
  echo "Error: output directory does not exist" >&2
  exit 1
fi

if [[ -z "$GENOME_LIST" ]]; then
  echo "Error: list of genomes (--genomes) is required" >&2
  exit 1
fi

if [[ -z "$CHR_LIST" ]]; then
  echo "Error: list of chromosomes (--chrs) is required" >&2
  exit 1
fi


#Execution

IFS=',' read -r -a GENOMES <<< "$GENOME_LIST"
IFS=',' read -r -a CHRS <<< "$CHR_LIST"


for genome in "${GENOMES[@]}"
do
   for chr in "${CHRS[@]}"
   do
     #Additional validation, does the chromosome folder exist in the genome folder?
     if [[ ! -d "$DIR/$genome/$chr" ]]; then
      echo "Error: directory "$DIR/$genome/$chr" does not exist" >&2
      exit 1
     fi

     mv  "$DIR/$genome/$chr"*.fa "$DIR"/"$genome"/"$chr"/
     sed -i "s/"$chr".*/"$genome"/g" "$DIR"/"$genome"/"$chr"/*.fa
   done
done
