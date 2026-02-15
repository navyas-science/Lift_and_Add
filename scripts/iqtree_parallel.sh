#!/bin/bash

OUT="/data/gpfs/projects/punim0586/nshukla/thylacine_canid_convergence_reanalysis/output/100_way_phastcons_0.9"
N="$1"
(
for file in "$OUT"/mafft_output/*.afa ;
do
((i=i%N)); ((i++==0)) && wait -n

iqtree2  -s  "$file" -m GTR+I+G -g "$OUT"/marsupial_topology.nh  -keep-ident &
done
)
