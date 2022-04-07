

**Project:** Promoter Opening

**Author:** [Vivek](mailto:vir@stowers.org)

**Generated:** Mon Sep 16 2019, 06:30 PM

```
## GRanges object with 492 ranges and 4 metadata columns:
##         seqnames            ranges strand |    fb_tx_id  fb_gene_id   fb_symbol
##            <Rle>         <IRanges>  <Rle> | <character> <character> <character>
##     [1]    chr3R 16934242-16934441      - | FBtr0083384 FBgn0000015       Abd-B
##     [2]    chr3R 13258777-13258976      - | FBtr0082780 FBgn0000024         Ace
##     [3]    chr3R 24485229-24485428      + | FBtr0084639 FBgn0000039 nAChRalpha2
##     [4]    chr2L   3888824-3889023      - | FBtr0077513 FBgn0000256        capu
##     [5]    chr3R 18705302-18705501      + | FBtr0089368 FBgn0000303        ChAT
##     ...      ...               ...    ... .         ...         ...         ...
##   [488]     chrX 16587172-16587371      - | FBtr0074292 FBgn0267912    CanA-14F
##   [489]    chr2L   3056399-3056598      + | FBtr0077659 FBgn0283427       FASN1
##   [490]     chrX 18116825-18117024      - | FBtr0308235 FBgn0283471        wupA
##   [491]    chr2L   2830248-2830447      - | FBtr0300382 FBgn0283531        Duox
##   [492]     chrX 13314823-13315022      + | FBtr0344169 FBgn0283680       IP3K2
##           gene_type
##         <character>
##     [1]        mRNA
##     [2]        mRNA
##     [3]        mRNA
##     [4]        mRNA
##     [5]        mRNA
##     ...         ...
##   [488]        mRNA
##   [489]        mRNA
##   [490]        mRNA
##   [491]        mRNA
##   [492]        mRNA
##   -------
##   seqinfo: 6 sequences from an unspecified genome; no seqlengths
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
 [1] pander_0.6.3                          dplyr_0.8.3                          
 [3] BSgenome.Dmelanogaster.UCSC.dm6_1.4.1 BSgenome_1.52.0                      
 [5] rtracklayer_1.44.4                    GenomicRanges_1.36.1                 
 [7] GenomeInfoDb_1.20.0                   Biostrings_2.52.0                    
 [9] XVector_0.24.0                        IRanges_2.18.2                       
[11] S4Vectors_0.22.1                      BiocGenerics_0.30.0                  
[13] xtable_1.8-4                          knitr_1.24                           

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.2                  compiler_3.6.1             
 [3] pillar_1.4.2                bitops_1.0-6               
 [5] tools_3.6.1                 zlibbioc_1.30.0            
 [7] digest_0.6.20               evaluate_0.14              
 [9] tibble_2.1.3                lattice_0.20-38            
[11] pkgconfig_2.0.2             rlang_0.4.0                
[13] Matrix_1.2-17               DelayedArray_0.10.0        
[15] xfun_0.9                    GenomeInfoDbData_1.2.1     
[17] stringr_1.4.0               tidyselect_0.2.5           
[19] grid_3.6.1                  glue_1.3.1                 
[21] Biobase_2.44.0              R6_2.4.0                   
[23] XML_3.98-1.20               BiocParallel_1.18.1        
[25] purrr_0.3.2                 magrittr_1.5               
[27] Rsamtools_2.0.0             matrixStats_0.55.0         
[29] GenomicAlignments_1.20.1    assertthat_0.2.1           
[31] SummarizedExperiment_1.14.1 stringi_1.4.3              
[33] RCurl_1.95-4.12             crayon_1.3.4               
```
