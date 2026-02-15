# Author: Navya Shukla
# Affiliation: University of Melbourne
# This script adds the set of output target sequences for a vertebrate conserved elements back to its original alignments with MAFFT. 

#!/bin/bash

# target path, argument

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      DIR="$2"
      shift 2
      ;;
    --conserved-elements)
      CONSERVED="$2"
      shift 2
      ;;
    --num-cores)
      CORES="$2"
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

if [[ -z "$CONSERVED" ]]; then
  echo "Error: directory containing aligned fasta files of  conserved elements (--conserved) is required" >&2
  exit 1
fi

if [[ ! -d "$CONSERVED" ]]; then
  echo "Error: directory containing aligned fasta files of  conserved elements (--conserved) does not exist" >&2
  exit 1
fi

if [[ -z "$CORES" ]]; then
  echo "Error: Specify number of cores" >&2
  exit 1
fi


#Execution

mkdir -p "$DIR"/mafft_aligned
N="$CORES"

(
	for fasta in "$CONSERVED"/*.fa ;
	do
		((i=i%N)); ((i++==0)) && wait -n
		root=`basename "$fasta" .fa`
		if test -f "$DIR"/compiled/"$root".fa ;then
		mafft --anysymbol --adjustdirectionaccurately  --keeplength  --localpair --nuc --add "$DIR"/compiled/"$root".fa --reorder "$fasta" > "$DIR"/mafft_aligned/"$root".afa
                fi &
	done
)
