

**Project:** 

**Author:** [Vivek](mailto:vir@stowers.org)

**Generated:** Mon Sep 16 2019, 06:30 PM

```r
lola_pi_peaks.gr <-import("/lola_paper/aws/bed/lola_i_peaks_1_summits.bed")

lola_pi_peaks.gr <- lola_pi_peaks.gr[order(lola_pi_peaks.gr$score,decreasing=TRUE)][1:500]


lola_pi_peaks.gr <- resize(lola_pi_peaks.gr, width=100, fix="center")
lola_pi_peaks.gr
```

```
## GRanges object with 500 ranges and 2 metadata columns:
##         seqnames            ranges strand |                     name
##            <Rle>         <IRanges>  <Rle> |              <character>
##     [1]    chr2L 21397384-21397483      * |  lola_i_peaks_1_peak_323
##     [2]    chr3L 16930641-16930740      * |  lola_i_peaks_1_peak_968
##     [3]    chr3R 10100694-10100793      * | lola_i_peaks_1_peak_1183
##     [4]     chrX 13563596-13563695      * | lola_i_peaks_1_peak_1653
##     [5]    chr3R 26261587-26261686      * | lola_i_peaks_1_peak_1418
##     ...      ...               ...    ... .                      ...
##   [496]    chr2L   7358854-7358953      * |  lola_i_peaks_1_peak_127
##   [497]    chr2R   6740689-6740788      * |  lola_i_peaks_1_peak_355
##   [498]    chr2R   9658192-9658291      * |  lola_i_peaks_1_peak_438
##   [499]    chr3R   5861916-5862015      * | lola_i_peaks_1_peak_1116
##   [500]    chr2R 25190577-25190676      * |  lola_i_peaks_1_peak_715
##              score
##          <numeric>
##     [1] 4288.05762
##     [2] 4154.95703
##     [3]  3950.8147
##     [4] 2978.07568
##     [5] 2608.04272
##     ...        ...
##   [496]   79.00821
##   [497]   78.98331
##   [498]   78.93363
##   [499]   78.39815
##   [500]   78.20503
##   -------
##   seqinfo: 14 sequences from an unspecified genome; no seqlengths
```

```r
peaks.seq <- getSeq(Dmelanogaster, lola_pi_peaks.gr)
names(peaks.seq) <- paste0("peak_", 1:length(peaks.seq))
writeXStringSet(peaks.seq, filepath="macs_peaks_lola_pi_14_17.fasta")



# meme macs_peaks_lola_pi_14_17.fasta -oc macs_peaks_lola_pi_meme_output_14_17 -p 10 -mod zoops -dna -nmotifs 10 -revcomp -maxw 12 -maxsize 5000000
```


## Session information

For reproducibility, this analysis was performed with the following R/Bioconductor session:


```
R version 3.6.1 (2019-07-05)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 18.04.2 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1

locale:
 [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
 [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
 [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
[10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   

attached base packages:
[1] stats4    parallel  stats     graphics  grDevices utils     datasets 
[8] methods   base     

other attached packages:
 [1] BSgenome.Dmelanogaster.UCSC.dm6_1.4.1
 [2] BSgenome_1.52.0                      
 [3] rtracklayer_1.44.4                   
 [4] GenomicRanges_1.36.1                 
 [5] GenomeInfoDb_1.20.0                  
 [6] Biostrings_2.52.0                    
 [7] XVector_0.24.0                       
 [8] IRanges_2.18.2                       
 [9] S4Vectors_0.22.1                     
[10] BiocGenerics_0.30.0                  
[11] xtable_1.8-4                         
[12] knitr_1.24                           

loaded via a namespace (and not attached):
 [1] magrittr_1.5                zlibbioc_1.30.0            
 [3] GenomicAlignments_1.20.1    BiocParallel_1.18.1        
 [5] lattice_0.20-38             stringr_1.4.0              
 [7] tools_3.6.1                 grid_3.6.1                 
 [9] SummarizedExperiment_1.14.1 Biobase_2.44.0             
[11] xfun_0.9                    matrixStats_0.55.0         
[13] Matrix_1.2-17               GenomeInfoDbData_1.2.1     
[15] bitops_1.0-6                RCurl_1.95-4.12            
[17] evaluate_0.14               DelayedArray_0.10.0        
[19] stringi_1.4.3               compiler_3.6.1             
[21] Rsamtools_2.0.0             XML_3.98-1.20              
```
