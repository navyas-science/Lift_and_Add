# Author: Navya Shukla
# Affiliation: University of Melbourne
# This script performs a series of bioinformatic steps to map a specified set of vertebrate conseved elements from their reference genome to a set of marsupial genomes, using a combination of liftOver and Liftoff. 

configfile: "config_snakemake.yaml" 
CHR = config["chromosomes"]
path=config["working_dir"]
target_species=config["target_species_list"]
query_species=config["query_species"]

##### Read table with target genome paths and convert to pandas dataframe #####

import pandas as pd
targets = pd.read_csv(config["target_species_path"], sep="\t").set_index("assembly", drop=False)

##### Target genome path input function #####
def genome_for_species(wildcards):
  return targets.loc[wildcards.target_species, "genomePath"]

##### Target genome index input function #####
def index_for_species(wildcards):
  return targets.loc[wildcards.target_species, "index"]

##### load rules #####

include: "rules/liftover.smk"
include: "rules/liftoff.smk"
include: "rules/get_fasta_seqs.smk"
include: "rules/summary_file.smk"

rule all:
 input:
   chr=CHR,
   path=path,
   query=query_species

