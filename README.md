# A workflow to add new genomes to existing alignments of vertebrate conserved elements # 

This repository consists of all the Snakemake files, config files and bash scripts required for the workflow detailed in Shukla and Gallego Romero, 2025. 

## Tools ## 

  + BEDTools v2.3.1
  + BEDOPS, v2.4.4.1
  + Liftoff v1.6.3
  + MAFFT v7.5
  + Python 3.10.8
  + R v4.4.0 
      + UpSetR v1.4.0
  + Snakemake v7.32.4
  + UCSC liftOver
  + UCSC faSplit

(Conda environment also available to install from the liftadd.yaml file.) 

## Glossary ##

 + Reference genome/species - the reference genome for the whole genome alignment from which the vertebrate conserved elements are derived. This is the mm10 mouse genome in corresponding manuscript. The elements are named in accordance to their location in the mouse genome (chrN:start-stop); chromosomal locations below also refer to the reference chromosome to which a vertebrate conserved element was aligning too. 
 + Query genome/species - the query genome(s) in Liftoff (i.e. wallaby and Tasmanian devil in Shukla and Gallego Romero, 2025).  
 + Target genome/species - the target genome(s) in Liftoff. 
 
## Overall conceptualisation ##

![](chapter4\_figure1.svg)

## Workflow, execution ##

### Step 0: Get discrete multiple species alignments for vertebrate conserved elements ###

I defined a set of vertebrate conserved elements with phastCONS (more details in Shukla and Gallego Romero, 2025), used the UCSC mafFrags utility (\url{https://github.com/ucscGenomeBrowser/kent}) to extract discrete MSAS for each vertebrate conserved element. The output Multiple Alignment Format (MAF) file was converted to FASTA with the Galaxy MAF to FASTA tool (\url{https://usegalaxy.org.au/root?tool\_id=MAF\_To\_Fasta1}), and split into a separate FASTA file for each vertebrate conserved element. 

### Step 1: Make individual directories per target species ###

Make directories in a specified path. Directory structure created is {output directory}/{target genome}/{chromosome}. 

~~~
bash 1.make_dir.sh --dir {output directory} --genomes {list of target genomes, comma-seperated} --chrs {list of chromosomes, comma-seperated}
~~~

Example:

~~~
bash 1.make_dir.sh --dir "output" --genomes ThyCyn2.0,mSarHar1.11,AStuM,DasVivv1.0,mMyrFas1,mDroGli1 --chrs chr17,chr18,chr19
~~~

### Step 2: liftOver and Liftoff ###

This step maps vertebrate conserved elements firstly from the reference genome (mouse, mm10) to a specified Liftoff reference/query genome (e.g. Tasmanian devil, sarHar1). Next, it maps elements from this query genome to specified Liftoff target genomes (e.g. Thylacine, ThyCyn2.0). This step can repeated multiple times with different sets of Liftoff query and target genomes. The workflow has been parallelised by target genome and chromosome; note however that multiple Liftoff cannot run successfully in parallel and hence those particular rules (rule liftoff and rule remap) only execute one at a time (necessary to specify --resources exclusive=1). 

~~~
snakemake -s 2.Snakefile --cores [number of cores] {path}/{query_species}_workflow_summary.txt --resources exclusive=1
~~~

Example:

~~~
snakemake -s 2.Snakefile --cores 6 output/sarHar1_workflow_summary.txt --resources exclusive=1
~~~

**Sample DAG, single chromosome, five target genomes:**

![](Snakefile\_dag.svg)

#### Inputs ####
  * Snakefile
      + path to the dataset of vertebrate conserved elements being mapped, labelled with their chromosomal location in mouse (e.g. "{chr}\_phastCons60way\_sarHar1\_liftover.bed")

  * Config file (config\_compiled.yaml)
    + query\_species: basename for the Liftoff query species. 
    + genome\_path\_query : path for the  Liftoff query species genome. 
    + target\_species\_list: list of basenames for the target species genome(s)
    + target\_species\_path: a tsv file with the basenames, genome path and genome index paths for each target species. 
    + list of chromosomes 
    + liftover parameters
    + Liftoff parameters
    
#### Outputs ####
  
  * rule liftover  
    + {chr}\_phastCons60way\_{query}\_liftover.bed - conserved regions successfully lifted from the reference to the query genome with liftOver. 
    + {chr}\_phastCons60way\_{query}\_unlifted.bed - regions not successfully lifted. 
  * rule bed2gtf
    + {chr}\_phastCons60way\_{query}\_liftover.gtf - converting liftOver output file from bed to gtf. 
  * rule editgtf
    + {chr}\_phastCons60way\_{query}\_liftover\_edited.gtf - edited gtf with the correct tab-seperated format. 
  * rule liftoff
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_mapped.gtf - gtf file of conserved elements successfully mapped from the query to target genome with Liftoff (target coordinates)
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_unmapped.txt - list of regions not mapped with Liftoff.
  * rule get\_unmapped
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_unmapped\_edited.txt - list of regions not mapped in the first Liftoff, edited to remove unnecessary formatting. 
  * rule format\_unmapped
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_unmapped.gtf - gtf file of conserved elements (query coordinates) not mapped to the target genome from the query with the first Liftoff. 
  * rule remap
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_remapped.gtf - gtf of conserved query elements that were mapped to the target genome in the second Liftoff, with addition of flanking sequence. 
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_remapfail.txt - list of conserved elements not mapped with either Liftoff commands. 
  * rule combine\_mapped
    + {chr}\_phastCons60way\_{query}\_{target\_species}\_combined.gtf - combined gtf file of elements mapped and re-mapped to the target genome from the query genome. 
  * rule gtf2bed
    + {chr}\_phastCons60way\_liftoff\_{query}\_{target\_species}\_mapped.bed - bed file of elements mapped and re-mapped to the target genome from the query genome. 
  * rule clean\_bedfile
    + {chr}\_phastCons60way\_liftoff\_{query}\_{target\_species}\_mapped\_cleaned.bed - bed file of elements mapped and re-mapped to the target genome from the query genome, unnecessary formatting removed. 
  * rule getfasta 
    + {chr}\_phastCons60way\_liftoff\_{query}\_{target\_species}\_mapped\_cleaned.fa - fasta file containing the target genome sequences for conserved elements mapped from the query genome. 
  * rule split\_fasta
    + {chr}\_{query}\_{target\_species}\_list.txt - list of query genome sequences mapped and re-mapped to each target genome. 
    + Individual fasta files per conserved element that was mapped from the query to the target genome, present in the target genome directory. 
  * rule finish
    + {query}\_workflow\_summary.txt - a tab-seperated file summarising which query elements were mapped to which target genomes. 
    + {query}\_regions\_list.txt - a list of of conserved elements mapped to at least one target genome. 

### Step 3: Move files and change header ###

The output fasta files from the previous step are all stored in the designated target species folder; the script first moves files to the right chromosome directory within each species directory (which was for some reason impossible to encode in the Snakefile). It then changes, for each individual fasta file, the header from the element name to the correct species name (e.g. ">chr1:10001:10005" to ">ThyCyn2.0")

~~~
bash 3.mv_edit_files.sh  --dir {output directory} --genomes {list of genomes, comma-seperated} --chrs {list of chromosomes, comma-seperated}
~~~

Example:

~~~
bash 3.mv_edit_files.sh  --dir output --genomes AStuM,DasVivv1.0,mDroGli1,mMyrFas1,mSarHar1.11,ThyCyn2.0 --chrs chr19
~~~

### Step 4: Combine target sequences into single fasta files ###

Given a list of regions, this script will combine target sequences for that region in a seperate fasta file. 2.Snakefile gives an output with a list of conserved regions mapped from a query genome to one or more target genomes, that can be used as input here. If there are multiple query genomes being used, i.e. Step 2 is run more than once with a different combination of species, the output lists from each run will need to be merged.

~~~
bash 4.combine_seq.sh --elements {list of conserved regions}  --genomes {list of genomes, comma-seperated} --dir {output directory}
~~~

Example:

~~~
bash 4.combine_seq.sh --elements output/sarHar1_regions_list.txt  --genomes AStuM,DasVivv1.0,mDroGli1,mMyrFas1,mSarHar1.11,ThyCyn2.0 --dir output
~~~

### Step 5: Alignment with MAFFT  ###

This script, in parallel, runs MAFFT, taking as input for each conserved genomic regions the *discrete multiple species alignment* and the *fasta files* with compiled sequences from target genomes. Importantly, both the MSA and target fasta files have the *same basenames* (e.g. chr1:10001\_10005.fa) for this script to work (as do the output alignments). 

~~~
bash 5.mafft.sh --dir {path to output directory} --conserved-elements {path to directory containing conserved element alignments} --cores {number of cores}
~~~

Example:

~~~
bash 5.mafft_add.sh --dir output --conserved-elements data/mm10/alignments --num-cores 2
~~~

The MAFFT command in the script is as follows:

~~~
mafft --anysymbol --adjustdirectionaccurately  --keeplength  --localpair --nuc --add  [FASTA.fa] --reorder [MSA.fa] > [OUTPUT_ALIGNMENT.fa]
~~~

  * --add - add the target sequences to the multiple species alignment.
  * --reorder - reorder the sequences in the final alignment according to alignment. 
  * --adjustdirectionaccurately - ensures alignment of the sequence is attempted in both orientations. 
  * --keeplength - keep length of the original alignments, trim any extra bases from the target sequences.
  * --localpair - L-IN-S, the most accurate MAFFT algorithm,recommended for <2000 sequences. 
  * --anysymbol - accept all nucleotides (a,c,t,g,u) and both uppercase and lowercase. 
  * --nuc - DNA alignment

Note, that in the output alignment files, if the reverse complement of a target sequence is aligned, it will have "\_R\_" at the head of the sequence title - use GNU grep to remove these instances before any further steps. 


  
