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
matrix_of_presence <- as.data.frame(fromList(species_regions))
matrix_of_presence$region_name <- unique(unlist(species_regions))
matrix_of_presence <- matrix_of_presence[,c(ncol(matrix_of_presence),1:ncol(matrix_of_presence)-1)]
colnames(matrix_of_presence)[2:ncol(matrix_of_presence)] <- args[1:num_files]

if(ncol(matrix_of_presence) > 2)
{
matrix_of_presence$sum <- rowSums(matrix_of_presence[,2:ncol(matrix_of_presence)])
}else(matrix_of_presence$sum <- 1)

write.table(matrix_of_presence, summary_outfile, sep = "\t", row.names = F, col.names = T, quote=F)
write.table(matrix_of_presence$region_name, list_outfile, sep = "\t", row.names = F, col.names = F, quote=F)

