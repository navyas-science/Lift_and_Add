#!/bin/bash

OUT="/data/gpfs/projects/punim0586/nshukla/thylacine_canid_convergence_reanalysis/output/100_way_phastcons_0.9"
declare -a dirs=("mMonDom1" "ThyCyn2.0" "mSarHar1.11" "AStuM" "DasVivv1.0" "mMyrFas1" "mDroGli1" "mMacEug1" "GCA900497805.2" "mTriVul1" "mBetpen1" "phaCin4.1" "PUasm1.0")

while read line;
do
        for  dir in "${dirs[@]}"
        do
        	if test -f "$OUT"/"$dir"/"$line";then
        	cat "$OUT"/"$dir"/"$line" >> "$OUT"/compiled_ALT/"$line"
		else
		rm -f "$OUT"/compiled/"$line"
		break
		fi
        done

done <"$1"



