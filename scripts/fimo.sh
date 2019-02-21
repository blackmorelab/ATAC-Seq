#!/bin/bash

set -e

genome=/home/ishv99/rgtdata/mm10/genome_mm10.fa
meme=/vol_c/ATAC/motif_databases/MOUSE/HOCOMOCOv11_full_MOUSE_mono_meme_format.meme
centipede=/home/ishv99/scripts/centipede.R

peak=$1
samplename=$2
filtpeak=$samplename-gt8.narrowPeak.gz
atacfasta=$samplename-gt8.fa
fimo=$samplename-allTF.fimo.txt.gz
bamfile=$3
outputpath=$4

echo 'Filtering significant peaks...'
zcat $peak | awk '{if ($8 > 8) print}' | gzip > $filtpeak

echo 'Extracting sequence associated with those peaks using bedtools...'
bedtools getfasta -fi $genome -bed $filtpeak -fo $atacfasta

echo 'creating the fimo file..'
fimo --text --parse-genomic-coord $meme $atacfasta | gzip > $fimo

echo 'starting CENTIPEDE analysis...'
Rscript $centipede $bamfile $fimo $samplename $outputpath
