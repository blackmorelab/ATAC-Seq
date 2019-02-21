#!/usr/bin/Rscript
library(CENTIPEDE.tutorial)
library(CENTIPEDE)
library(Rsamtools)

args <- commandArgs(trailingOnly = TRUE)
print(args)

bamfile = args[1]
fimofile = args[2]
sample = toString(args[3])
outpath = toString(args[4])


cen <- centipede_data(bam_file = bamfile, fimo_file = fimofile, flank_size=1)

#compute posterior probability
fit <- fitCentipede(
  Xlist = list(DNase = cen$mat),
  Y = as.matrix(data.frame(
    Intercept = rep(1, nrow(cen$mat))
  ))
)


#create dataframes
df = as.data.frame(cbind(cen$regions, fit$PostPr))
filtdf = df[df$`fit$PostPr` >= 0.9,]

output_file <- paste(outpath, "/", sample, "_", "merged_footprints.csv",sep="")
write.csv(filtdf, file = output_file, row.names = FALSE, col.names = TRUE)
