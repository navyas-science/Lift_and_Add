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
