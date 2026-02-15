#!/bin/bash

OUT="/data/gpfs/projects/punim0586/nshukla/thylacine_canid_convergence_reanalysis/output/100_way_phastcons_0.9"

while read line;
do
mafft --anysymbol  --keeplength --add "$OUT"/compiled/"$line".fa --reorder "$OUT"/hg38_alt/"$line".fa > "$OUT"/mafft_output/"$line"_a1.afa
done <"$1"
