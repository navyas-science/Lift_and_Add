# Author: Navya Shukla
# Affiliation: University of Melbourne
# Given a list of conserved elements, this script will compile the output target sequence per element. 

#!/bin/bash

#parse arguments

while [[ $# -gt 0 ]]; do
  case "$1" in
    --elements)
      ELEMENTS="$2"
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
    --dir)
      DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

#validate arguments
if [[ -z "$ELEMENTS" ]]; then
  echo "Error: List of elements (--elements) is required" >&2
  exit 1
fi

if [[ !  -f "$ELEMENTS" ]]; then
  echo "Error: List of elements does not exist" >&2
  exit 1
fi

if [[ -z "$GENOME_LIST" ]]; then
  echo "Error: list of genomes ( --genomes) required" >&2
  exit 1
fi

if [[ -z "$DIR" ]]; then
  echo "Error: Working directory name (--dir) is required" >&2
  exit 1
fi

if [[ ! -d "$DIR" ]]; then
  echo "Error: Working directory name (--dir) is required" >&2
  exit 1
fi

#execution

mkdir -p $DIR/compiled
IFS=',' read -r -a GENOME_DIRS <<< "$GENOME_LIST"

while read line;
do
        for  genome in "${GENOME_DIRS[@]}"
        do
		if test -f "$DIR"/"$genome"/*/"$line";then
		cat "$DIR"/"$genome"/*/"$line"  >> "$DIR"/compiled/"$line"
		fi
        done

done < "$ELEMENTS"
