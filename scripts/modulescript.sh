#!/bin/bash
set -e
#set -x
set -o pipefail

file=$1
outpath=$2
bed=$outpath/$file.bed
geneid=$outpath/$file.geneids
formatbed=$outpath/$file.formatted.bed
intersectfile=$outpath/$file.intersect.bed
combo=$outpath/$file.comboTF.tsv
combonodups=$outpath/$file.comboTF.nodups.tsv
ranked=$outpath/$file.rankedTF.tsv

echo "Formatting bed to get proper gene symbols.."
sed 1d $1 | cut -f1-4 | sed 's/_.*//g' > $bed

grep -Fwf <(cut -f4 $bed) ../ucscGeneSymbols.txt | sort > $geneid

join -1 4 -2 1 -o 1.1,1.2,1.3,2.2 <(sort -k 4,4 $bed) <(sort -k 1,1 $geneid) | tr ' ' '\t' > $formatbed

echo "Performing intersection with centipede output.."
grep -Fwf <(cut -f2 $geneid) <(intersectBed -a ../CENT-tf-genes-new.bed -b $formatbed -wa) | sortBed > $intersectfile

echo "Finding TF combinations for genes.."
bedtools merge -i $intersectfile -c 4,5 -o distinct,distinct | awk 'BEGIN {OFS="\t"} {print $5,$4}' | awk '$1==last {printf ",%s",$2; next} NR>1 {print "";} {last=$1; printf "%s",$0;} END{print "";}' > $combo 

bash rmdups.sh $combo > $combonodups
echo "ranking TFs.."
cut -f2 $combonodups | tr ',' '\n' | sort | uniq -c | sort -rn | awk 'BEGIN {OFS="\t"}{print $1,$2}' > $ranked
echo "All files created!"
