# motif enrichements at different gene groups

###Comments: I am using one transcript per gene.


**Project:** 

**Author:** [Vivek](mailto:vir@stowers.org)

**Generated:** Tue Nov 26 2019, 01:51 AM

```
## Error in library(doMC): there is no package called 'doMC'
```





 



```
## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect

## Warning in prop.test(m, alternative = alt.test): Chi-squared approximation may
## be incorrect
```

```
##                                motif s1_W s1_WO s2_W s2_WO  test_type
## 1       FF-lola_SOLEXA_5_FBgn0005630  162   330   51   792 enrichment
## 2       FF-lola_SANGER_5_FBgn0005630  126   366   43   800 enrichment
## 3              cispb_1.02-M5228_1.02  113   379   93   750 enrichment
## 4  FF-lola.PG_SANGER_2.5_FBgn0005630   41   451   17   826 enrichment
## 5              cispb_1.02-M4893_1.02   24   468  115   728  depletion
## 6              cispb_1.02-M5017_1.02   46   446   27   816 enrichment
## 7              cispb_1.02-M2533_1.02   56   436   40   803 enrichment
## 8              cispb_1.02-M4969_1.02   37   455  136   707  depletion
## 9        FF-ken_SOLEXA_5_FBgn0011236   70   422   58   785 enrichment
## 10     FF-GATAe_SANGER_5_FBgn0038391   41   451   26   817 enrichment
## 11     FF-HLH4C_SANGER_5_FBgn0011277   90   402   88   755 enrichment
## 12             cispb_1.02-M5234_1.02  109   383  115   728 enrichment
## 13   FF-ss_tgo_SANGER_10_FBgn0003513   39   453   26   817 enrichment
## 14   FF-ss_tgo_SANGER_10_FBgn0015014   39   453   26   817 enrichment
## 15          JASPAR_2014-pnr-MA0536.1   30   462  108   735  depletion
##          pvalue enrichment         padj
## 1  3.804494e-38   5.442611 6.064364e-35
## 2  2.001378e-27   5.020703 1.595099e-24
## 3  4.592702e-09   2.081891 2.440256e-06
## 4  5.119088e-08   4.132353 2.039957e-05
## 5  3.438498e-07  -2.796560 1.096193e-04
## 6  1.737485e-06   2.919151 4.615918e-04
## 7  4.966548e-06   2.398780 9.895847e-04
## 8  4.591421e-06  -2.145234 9.895847e-04
## 9  8.453236e-06   2.067914 1.497162e-03
## 10 1.997845e-05   2.701923 3.184565e-03
## 11 3.319838e-05   1.752356 4.810747e-03
## 12 4.083543e-05   1.624019 5.424306e-03
## 13 6.297707e-05   2.570122 7.170389e-03
## 14 6.297707e-05   2.570122 7.170389e-03
## 15 7.415681e-05  -2.101068 7.880397e-03
```



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
[1] parallel  stats4    stats     graphics  grDevices utils     datasets 
[8] methods   base     

other attached packages:
 [1] BSgenome.Dmelanogaster.UCSC.dm6_1.4.1 BSgenome_1.52.0                      
 [3] Biostrings_2.52.0                     XVector_0.24.0                       
 [5] rtracklayer_1.44.4                    pander_0.6.3                         
 [7] dplyr_0.8.3                           DESeq2_1.24.0                        
 [9] SummarizedExperiment_1.14.1           DelayedArray_0.10.0                  
[11] BiocParallel_1.18.1                   matrixStats_0.55.0                   
[13] Biobase_2.44.0                        reshape2_1.4.3                       
[15] ggplot2_3.2.1                         magrittr_1.5                         
[17] plyr_1.8.4                            GenomicRanges_1.36.1                 
[19] GenomeInfoDb_1.20.0                   IRanges_2.18.2                       
[21] S4Vectors_0.22.1                      BiocGenerics_0.30.0                  
[23] knitr_1.24                           

loaded via a namespace (and not attached):
 [1] bit64_0.9-7              splines_3.6.1            Formula_1.2-3           
 [4] assertthat_0.2.1         latticeExtra_0.6-28      blob_1.2.0              
 [7] Rsamtools_2.0.0          GenomeInfoDbData_1.2.1   pillar_1.4.2            
[10] RSQLite_2.1.2            backports_1.1.4          lattice_0.20-38         
[13] glue_1.3.1               digest_0.6.20            RColorBrewer_1.1-2      
[16] checkmate_1.9.4          colorspace_1.4-1         htmltools_0.3.6         
[19] Matrix_1.2-17            XML_3.98-1.20            pkgconfig_2.0.2         
[22] genefilter_1.66.0        zlibbioc_1.30.0          purrr_0.3.2             
[25] xtable_1.8-4             scales_1.0.0             htmlTable_1.13.1        
[28] tibble_2.1.3             annotate_1.62.0          withr_2.1.2             
[31] nnet_7.3-12              lazyeval_0.2.2           survival_2.44-1.1       
[34] crayon_1.3.4             memoise_1.1.0            evaluate_0.14           
[37] foreign_0.8-72           tools_3.6.1              data.table_1.12.2       
[40] stringr_1.4.0            locfit_1.5-9.1           munsell_0.5.0           
[43] cluster_2.1.0            AnnotationDbi_1.46.1     compiler_3.6.1          
[46] rlang_0.4.0              grid_3.6.1               RCurl_1.95-4.12         
[49] rstudioapi_0.10          htmlwidgets_1.3          bitops_1.0-6            
[52] base64enc_0.1-3          gtable_0.3.0             DBI_1.0.0               
[55] R6_2.4.0                 GenomicAlignments_1.20.1 gridExtra_2.3           
[58] zeallot_0.1.0            bit_1.1-14               Hmisc_4.2-0             
[61] stringi_1.4.3            Rcpp_1.0.2               geneplotter_1.62.0      
[64] vctrs_0.2.0              rpart_4.1-15             acepack_1.4.1           
[67] tidyselect_0.2.5         xfun_0.9                
```
