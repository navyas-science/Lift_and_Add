library(UpSetR)
args = commandArgs(trailingOnly=TRUE)

number_of_args <- length(args)
num_files <- length(args) - 2

#outfiles
if(num_files > 1)
{  
summary_outfile <- args[number_of_args - 1]
list_outfile <- args[number_of_args]
}else{
  
summary_outfile <- args[2]
list_outfile <- args[3]
}

#read list of mapped elements for each species 
species_regions <- list(double(num_files))
for(s in seq(1:num_files))
{
  temp_table <- read.table(args[s])
  species_regions[[s]] <- temp_table$V1
}

#make a matrix of conserved elements 
names(species_regions) <- args[1:num_files]
matrix_of_presence <- as.data.frame(fromList(species_regions))
rownames(matrix_of_presence) <- unique(unlist(species_regions))

if(ncol(matrix_of_presence) > 1)
{
matrix_of_presence$sum <- rowSums(matrix_of_presence[,1:ncol(matrix_of_presence)])
}else(matrix_of_presence$sum <- 1)

write.table(matrix_of_presence, summary_outfile, sep = "\t", row.names = T, col.names = T, quote=F)
write.table(rownames(matrix_of_presence), list_outfile, sep = "\t", row.names = F, col.names = F, quote=F)

