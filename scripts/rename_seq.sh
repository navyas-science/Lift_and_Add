#!/bin/bash

OUT="/data/gpfs/projects/punim0586/nshukla/thylacine_canid_convergence_reanalysis/output/100_way_phastcons_0.9"
declare -a dirs=("mMonDom1" "ThyCyn2.0" "mSarHar1.11" "AStuM" "DasVivv1.0" "mMyrFas1" "mDroGli1" "mMacEug1" "GCA900497805.2" "mTriVul1" "mBetpen1" "phaCin4.1" "PUasm1.0" "ASM1834538v1" "ASM325472v2" "mCanLor1.2" "VulVul.2")

for  dir in "${dirs[@]}"
        do
		sed -i  "1 s/>.*$/>"$dir"/" "$OUT"/"$dir"/chr21/*.fa
        done




