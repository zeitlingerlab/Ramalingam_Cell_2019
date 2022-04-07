#!/bin/bash

FASTQ=$1
BAM=/lola_paper/aws/bam/dhs/`basename $FASTQ fastq.gz`bam

bowtie -p 40  -S -m 1 -k 1 -v 2 --best --strata --chunkmbs=512 /lola_paper/aws/genomes/dm6/dm6 <(zcat $FASTQ ) | samtools view -F 4 -Sbo $BAM -

