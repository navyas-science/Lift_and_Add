#!/bin/bash

OUT="/data/gpfs/projects/punim0586/nshukla/thylacine_canid_convergence_reanalysis/output/60_way_phastcons_mostconserved"
N="$1"
(
	for file in "$OUT"/mafft_sarHar1/*.afa;
	do
		((i=i%N)); ((i++==0)) && wait -n
		root=`basename "$file" .fa`
		distmat -nucmethod 1 "$file" -outfile "$OUT"/emboss_sarHar1/"$root".mat &
		done
)
