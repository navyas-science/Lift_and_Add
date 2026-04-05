import os

#Convert the output bed file from liftOver to gff, for Liftoff

rule bed2gtf:
 input:
    "{path}/{chr}_phastCons60way_{query}_liftover.bed"
 output:
    gtf="{path}/{chr}_phastCons60way_{query}_liftover.gtf"
 log:
    "{path}/logfiles/{chr}_phastCons60way_{query}.gtf.log"
 shell:
    """
    python scripts/bed2gff.py {input} {output.gtf} 2> {log} 
    """
    
rule editgtf:
  input:
    gtf="{path}/{chr}_phastCons60way_{query}_liftover.gtf"
  output:
    edited_gtf="{path}/{chr}_phastCons60way_{query}_liftover_edited.gtf"
  log:
    "{path}/logfiles/{chr}_phastCons60way_{query}_edited.gtf.log"
  shell:
    """
    sed 's/ /\t/g' {input.gtf} > {output.edited_gtf} 2> {log}
    """

#Liftoff from the query genome to each of the target genomes 

checkpoint liftoff:
 input:
    gtf="{path}/{chr}_phastCons60way_{query}_liftover_edited.gtf",
    features=config["features"],
    query_genome=config["genome_path_query"],
    target_genome=genome_for_species,
    intermediate_dir=config["intermediate"]
 output:
    mapped="{path}/{chr}_phastCons60way_{query}_{target_species}_mapped.gtf",
    unmapped="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped.txt"
 resources:
    exclusive=1
 log:
    "{path}/logfiles/{chr}_phastCons60way_{query}_{target_species}_mapped.gtf.log"
 params:
    flank=config["flank"]
 shell:
    """
    liftoff -g {input.gtf} -f {input.features} -exclude_partial -dir {input.intermediate_dir}  -flank {params.flank} {input.target_genome} {input.query_genome} -o {output.mapped} -u {output.unmapped}  2> {log}
    """

#Checkpoint - are there any unmapped elements?
def check_unmapped(wildcards):
    ckpt = checkpoints.liftoff.get(**wildcards)
    mapped = ckpt.output.mapped
    unmapped = ckpt.output.unmapped

    if os.path.getsize(unmapped) == 0:
       return [mapped]
    else:
       return [mapped, "{path}/{chr}_phastCons60way_{query}_{target_species}_remapped.gtf"]

#Retrieve and format elements that did not map without any flanking sequences 

rule get_unmapped:
 input:
     unmapped="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped.txt"
 output:
     unmappedtxt="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped_edited.txt",
 log:
     "{path}/logfiles/{chr}_phastCons60way_{query}_{target_species}_unmapped.log"
 shell:
     """
     sed 's/_1$/;/g' {input.unmapped} > {output.unmappedtxt} 2> {log}
     """ 

rule format_unmapped:
  input:
     unmappedtxt="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped_edited.txt",
     gtf="{path}/{chr}_phastCons60way_{query}_liftover_edited.gtf"
  output:
     unmappedgtf="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped.gtf"
  log:
     "{path}/logfiles/{chr}_phastCons60way_{query}_{target_species}_unmapped_format.log"
  shell:
     """
     awk 'NR==FNR {{include[$1]; next}} $9 in include' {input.unmappedtxt} {input.gtf} > {output.unmappedgtf} 2> {log}
     """
  
#Re-map with Liftoff unmapped elements with added flanking sequence

rule remap:
 input:
    gtf="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped.gtf",
    features=config["features"],
    query_genome=config["genome_path_query"],
    target_genome=genome_for_species,
    intermediate_dir=config["intermediate"]
 output: 
    mapped="{path}/{chr}_phastCons60way_{query}_{target_species}_remapped.gtf",
    unmapped="{path}/{chr}_phastCons60way_{query}_{target_species}_remapfail.txt"
 resources:
    exclusive=1
 log:
    "{path}/logfiles/{chr}_phastCons60way_{query}_{target_species}_remapped.gtf.log"
 params:
    flank=config["flank_remap"]
 shell:
    """
    liftoff -g {input.gtf} -f {input.features} -dir {input.intermediate_dir} -exclude_partial  -flank {params.flank} {input.target_genome} {input.query_genome} -o {output.mapped} -u {output.unmapped} 2> {log}
    """

#Combine Liftoff output from the two rounds of mapping and convert to bed format. 

rule combine_mapped:
 input:
    check_unmapped
 output:
    combined="{path}/{chr}_phastCons60way_{query}_{target_species}_combined.gtf",
 log:
    "{path}/logfiles/{chr}_phastCons60way_liftoff_{query}_{target_species}.mapped.bed.log"
 shell:
    """
    cat {input} > {output.combined} 2> {log}
    """
    
rule gtf2bed:
 input:
    combined="{path}/{chr}_phastCons60way_{query}_{target_species}_combined.gtf",
 output:
    bed="{path}/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped.bed",
 log:
    "{path}/logfiles/{chr}_phastCons60way_liftoff_{query}_{target_species}.mapped.bed.log"
 shell:
    """
    gtf2bed < {input.combined} > {output.bed} 2> log
    """

rule clean_bedfile:
 input:
    bed="{path}/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped.bed",
 output:
    cleaned_bed="{path}/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped_cleaned.bed"
 log:
    "{path}/logfiles/{chr}_phastCons60way_liftoff_{query}_{target_species}.mapped.bed.log"
 shell:
    """
    Rscript scripts/bedClean.R {input.bed} {output.cleaned_bed} 2> {log}
    """
