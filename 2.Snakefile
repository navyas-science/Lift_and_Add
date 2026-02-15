# Author: Navya Shukla
# Affiliation: University of Melbourne
# This script performs a series of bioinformatic steps to map a specified set of vertebrate conseved elements from their reference genome to a set of marsupial genomes, using a combination of liftOver and Liftoff. 

configfile: "config_can.yaml" 
CHR = config["chromosomes"]
path=config["working_dir"]
target_species=config["target_species_list"]
query_species=config["query_species"]

#Pandas dataframe with target genome paths

import pandas as pd
targets = pd.read_csv(config["target_species_path"], sep="\t").set_index("assembly", drop=False)

#Target genome path input function
def genome_for_species(wildcards):
  return targets.loc[wildcards.target_species, "genomePath"]

#Target genome index input function
def index_for_species(wildcards):
  return targets.loc[wildcards.target_species, "index"]

rule all:
 input:
   chr=CHR,
   path=path,
   query=query_species

#liftOver from mouse coordinates to query species coordinates 

rule liftover:
 input:
    chain=config["chain_file"],
    bed="data/mm10/{chr}_60way_most_conserved_merged_size_edited.bed", #path to conserved elements in bed format, must be pre-specified
 output:
    lifted_bed="{path}/{chr}_phastCons60way_{query}_liftover.bed",
    unlifted_bed="{path}/{chr}_phastCons60way_{query}_unlifted.bed"
 log:
    "{path}/logfiles/{chr}_phastCons60way_{query}_liftover.log"
 params:
    minmatch=config["minMatch"]
 shell:
    """
    liftOver -minMatch={params.minmatch} {input.bed} {input.chain} {output.lifted_bed} {output.unlifted_bed} 2> {log} 
    """

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

rule liftoff:
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

#Retrieve and format elements that did not map without any flanking sequences 

rule get_unmapped:
 input:
     unmapped="{path}/{chr}_phastCons60way_{query}_{target_species}_unmapped.txt",
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
    mapped="{path}/{chr}_phastCons60way_{query}_{target_species}_mapped.gtf",
    remapped="{path}/{chr}_phastCons60way_{query}_{target_species}_remapped.gtf"
 output:
    combined="{path}/{chr}_phastCons60way_{query}_{target_species}_combined.gtf",
 log:
    "{path}/logfiles/{chr}_phastCons60way_liftoff_{query}_{target_species}.mapped.bed.log"
 shell:
    """
    cat {input.mapped} {input.remapped} > {output.combined} 2> {log}
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

#Get fasta sequences from bed coordinates for each target genome

rule get_fasta:
 input:
    bed="{path}/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped_cleaned.bed",
    target_genome=genome_for_species,
    index=index_for_species
 output:
    fasta="{path}/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped_cleaned.fa"
 log:
    "{path}/logfiles/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped_cleaned_filtered.fa"
 shell:
    """
    bedtools getfasta -nameOnly -fi {input.target_genome} -bed {input.bed}  > {output.fasta} 2> {log}
    """

#Get individual fasta files per sequence 

rule split_fasta:
 input:
    fasta="{path}/{chr}_phastCons60way_liftoff_{query}_{target_species}_mapped_cleaned.fa",
    chr_dir="{path}/{target_species}"
 output:
    "{path}/{target_species}/{chr}_{query}_{target_species}_list.txt"
 log:
    "{path}/logfiles/{chr}_{query}_{target_species}_faSplit.log"
 shell:
    """
    faSplit byname {input.fasta} {input.chr_dir}/
    ls {input.chr_dir}/*.fa | xargs -n 1 basename  > {output} 2> {log}
    """

rule finish:
 input:
    files=expand("{path}/{target_species}/{chr}_{query}_{target_species}_list.txt", path=config["working_dir"], chr=config["chromosomes"],target_species=config["target_species_list"], query=config["query_species"])
 output:
    summary="{path}/{query}_workflow_summary.txt",
    list="{path}/{query}_regions_list.txt"
 log:
    "{path}/logfiles/{query}_finish.log"
 shell:
    """
    Rscript scripts/summary.R {input.files} {output.summary} {output.list} 2> {log}
    """
