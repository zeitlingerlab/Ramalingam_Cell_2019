#!/bin/bash

echo Sorting $1
SORT_TEMP_NAME=`dirname $1`/`basename $1 .bam`_tmp_sorting
echo $SORT_TEMP_NAME
samtools sort -@ 5 -m 30G -o $1 -T $SORT_TEMP_NAME $1
