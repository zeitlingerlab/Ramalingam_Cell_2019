#!/bin/bash
FASTQ_R1=fastq/mnase/newsamples/`basename $1 _R1.fastq.gz`_R1.fastq.gz
FASTQ_R2=fastq/mnase/newsamples/`basename $1 _R1.fastq.gz`_R2.fastq.gz
BAM=bam/mnase/`basename $1 _R1.fastq.gz`.bam

bowtie -p 8 -S -m 1 -k 1 -v 2 -X 1000 \
        --best --strata --chunkmbs=512 \
        /lola_paper/aws/genomes/dm6/dm6 \
        -1 <(zcat $FASTQ_R1) \
	-2 <(zcat $FASTQ_R2) | samtools view -F 4 -Sbo $BAM -

