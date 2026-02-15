args <- commandArgs(trailingOnly = TRUE)

bed_file <- args[1]
out_file <- args[2]

bed <- read.table(bed_file, fill = T)
bed$hg38 <- NULL

for(i in seq(nrow(bed)))
{
  bed$hg38[i] <- strsplit(bed[i,10], ";")[[1]][2]
  bed$hg38[i] <- gsub("=", "", bed$hg38[i])
}

bed_final <- data.frame(bed$V1, bed$V2, bed$V3, bed$hg38)

write.table(bed_final,out_file, quote=F,row.names=F, col.names=F, sep = "\t")

