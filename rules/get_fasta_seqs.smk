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
