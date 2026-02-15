#!/bin/bash

DIR="/data/gpfs/projects/punim0586/nshukla/thylacine_canid_convergence_reanalysis/output/60_way_phastcons_0.9"
array_0=(ThyCyn2.0 mSarHar1.11 AStuM DasVivv1.0 mMyrFas1 mDroGli1 mMacEug1 GCA900497805.2 mTriVul1 mBetpen1 phaCin4.1 PUasm1.0)
array_1=(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr18 chr19 chr20 chr21 chr22)

for a0 in "${array_0[@]}"
do
   for a1 in "${array_1[@]}"
   do
	 mkdir -p "$DIR/$a0/$a1"
   done
done
