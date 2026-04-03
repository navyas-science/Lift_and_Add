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
