# Conservation of Lola motifs

###Comments: I will compare lola motifs conservation with lola motifs not at promoters, not bound by lola, region around lola - 100 bp and promoters -300:0


**Project:** 

**Author:** [Vivek](mailto:vir@stowers.org)

**Generated:** Tue Nov 26 2019, 02:20 AM




```
## Warning in .Seqinfo.mergexy(x, y): Each of the 2 combined objects has sequence levels not in the other:
##   - in 'x': chrM, chrX_DS484099v1_random, chrX_DS484216v1_random, chrY_DS485329v1_random
##   - in 'y': chrUn_DS483562v1, chrUn_DS484160v1, chrUn_DS484280v1, chrX_DS484953v1_random
##   Make sure to always combine/compare objects based on the same reference
##   genome (use suppressWarnings() to suppress this warning).
```


![plot of chunk plots](figure1sb_lola_motif_conservation/plots-1.pdf)

```
## 
## 	Pairwise comparisons using Wilcoxon rank sum test 
## 
## data:  .$conservation and .$group_name 
## 
##                       control_around lola_motifs_bound
## lola_motifs_bound     <2e-16         -                
## lola_motifs_bound_not <2e-16         <2e-16           
## 
## P value adjustment method: bonferroni
```

![plot of chunk plots](figure1sb_lola_motif_conservation/plots-2.pdf)

```
## 
## 	Pairwise comparisons using Wilcoxon rank sum test 
## 
## data:  .$conservation and .$group_name 
## 
##                       control_around lola_motifs_bound
## lola_motifs_bound     <2e-16         -                
## lola_motifs_bound_not <2e-16         <2e-16           
## 
## P value adjustment method: bonferroni
```

![plot of chunk plots](figure1sb_lola_motif_conservation/plots-3.pdf)

```
## 
## 	Pairwise comparisons using Wilcoxon rank sum test 
## 
## data:  .$conservation and .$group_name 
## 
##                                       lola_motifs_bound_at_distal
## lola_motifs_bound_at_distal_around    < 2e-16                    
## lola_motifs_bound_at_promoters        0.00030                    
## lola_motifs_bound_at_promoters_around < 2e-16                    
## lola_motifs_not_bound_at_promoters    < 2e-16                    
## promoters_with_lola_motif_bound       < 2e-16                    
##                                       lola_motifs_bound_at_distal_around
## lola_motifs_bound_at_distal_around    -                                 
## lola_motifs_bound_at_promoters        < 2e-16                           
## lola_motifs_bound_at_promoters_around 1.1e-05                           
## lola_motifs_not_bound_at_promoters    0.72097                           
## promoters_with_lola_motif_bound       1.00000                           
##                                       lola_motifs_bound_at_promoters
## lola_motifs_bound_at_distal_around    -                             
## lola_motifs_bound_at_promoters        -                             
## lola_motifs_bound_at_promoters_around < 2e-16                       
## lola_motifs_not_bound_at_promoters    < 2e-16                       
## promoters_with_lola_motif_bound       < 2e-16                       
##                                       lola_motifs_bound_at_promoters_around
## lola_motifs_bound_at_distal_around    -                                    
## lola_motifs_bound_at_promoters        -                                    
## lola_motifs_bound_at_promoters_around -                                    
## lola_motifs_not_bound_at_promoters    0.00053                              
## promoters_with_lola_motif_bound       0.00023                              
##                                       lola_motifs_not_bound_at_promoters
## lola_motifs_bound_at_distal_around    -                                 
## lola_motifs_bound_at_promoters        -                                 
## lola_motifs_bound_at_promoters_around -                                 
## lola_motifs_not_bound_at_promoters    -                                 
## promoters_with_lola_motif_bound       0.19304                           
## 
## P value adjustment method: bonferroni
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
[17] tidyr_1.0.0                           plyr_1.8.4                           
[19] GenomicRanges_1.36.1                  GenomeInfoDb_1.20.0                  
[21] IRanges_2.18.2                        S4Vectors_0.22.1                     
[23] BiocGenerics_0.30.0                   knitr_1.24                           

loaded via a namespace (and not attached):
 [1] bit64_0.9-7              splines_3.6.1            Formula_1.2-3           
 [4] assertthat_0.2.1         highr_0.8                latticeExtra_0.6-28     
 [7] blob_1.2.0               Rsamtools_2.0.0          GenomeInfoDbData_1.2.1  
[10] pillar_1.4.2             RSQLite_2.1.2            backports_1.1.4         
[13] lattice_0.20-38          glue_1.3.1               digest_0.6.20           
[16] RColorBrewer_1.1-2       checkmate_1.9.4          colorspace_1.4-1        
[19] htmltools_0.3.6          Matrix_1.2-17            XML_3.98-1.20           
[22] pkgconfig_2.0.2          genefilter_1.66.0        zlibbioc_1.30.0         
[25] purrr_0.3.2              xtable_1.8-4             scales_1.0.0            
[28] htmlTable_1.13.1         tibble_2.1.3             annotate_1.62.0         
[31] withr_2.1.2              nnet_7.3-12              lazyeval_0.2.2          
[34] survival_2.44-1.1        crayon_1.3.4             memoise_1.1.0           
[37] evaluate_0.14            foreign_0.8-72           tools_3.6.1             
[40] data.table_1.12.2        lifecycle_0.1.0          stringr_1.4.0           
[43] locfit_1.5-9.1           munsell_0.5.0            cluster_2.1.0           
[46] AnnotationDbi_1.46.1     compiler_3.6.1           rlang_0.4.0             
[49] grid_3.6.1               RCurl_1.95-4.12          rstudioapi_0.10         
[52] htmlwidgets_1.3          labeling_0.3             bitops_1.0-6            
[55] base64enc_0.1-3          gtable_0.3.0             DBI_1.0.0               
[58] R6_2.4.0                 GenomicAlignments_1.20.1 gridExtra_2.3           
[61] bit_1.1-14               zeallot_0.1.0            Hmisc_4.2-0             
[64] stringi_1.4.3            Rcpp_1.0.2               geneplotter_1.62.0      
[67] vctrs_0.2.0              rpart_4.1-15             acepack_1.4.1           
[70] tidyselect_0.2.5         xfun_0.9                
```
