#!/bin/bash
FASTQ_R1=fastq/atac/`basename $1 _R1.fastq.gz`_R1.fastq.gz
FASTQ_R2=fastq/atac/`basename $1 _R1.fastq.gz`_R2.fastq.gz
BAM=bam/atac/`basename $1 _R1.fastq.gz`.bam

bowtie -p 10 -S -m 1 -k 1 -v 2 -X 1000 \
        --best --strata --chunkmbs=512 \
        /data/effector_genes/genomes/dm6/dm6 \
        -1 <(zcat $FASTQ_R1 | fastx_trimmer -Q 33 -l 50 ) \
        -2 <(zcat $FASTQ_R2 | fastx_trimmer -Q 33 -l 50 ) | samtools view -F 4 -Sbo $BAM -

