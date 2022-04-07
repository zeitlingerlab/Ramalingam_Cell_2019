

# Calculating Lola binding at Late promoters


**Project:** Promoter Opening

**Author:** [Vivek](mailto:vir@stowers.org)

**Generated:** Mon Dec 02 2019, 08:05 PM



## Samples overview

We will calculate the pol II enrichments for the following samples

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    label       factor   window_upstream   window_downstream                             ip                              wce   normalization   replicate   minimum_value   max_quantile     color   
-------------- -------- ----------------- ------------------- --------------------------------------------------------- ----- --------------- ----------- --------------- -------------- -----------
  wt_14-17h      ATAC          150                150          ../bw/dme_emb_orer_14_17h_atac_8.bam_from0to100_rpm.bw    NA        FALSE           1             0             0.85       "#6C1E10" 

  wt_14-17h      ATAC          150                150          ../bw/dme_emb_orer_14_17h_atac_9.bam_from0to100_rpm.bw    NA        FALSE           2             0             0.85       "#6C1E10" 

 orc4_14-17h     ATAC          150                150          ../bw/dme_emb_28267_14_17h_atac_1.bam_from0to100_rpm.bw   NA        FALSE           1             0             0.85       "#6C1E10" 

 orc4_14-17h     ATAC          150                150          ../bw/dme_emb_28267_14_17h_atac_2.bam_from0to100_rpm.bw   NA        FALSE           2             0             0.85       "#6C1E10" 

 orc4_17-20h     ATAC          150                150          ../bw/dme_emb_28267_17_20h_atac_1.bam_from0to100_rpm.bw   NA        FALSE           1             0             0.85       "#6C1E10" 

 orc4_17-20h     ATAC          150                150          ../bw/dme_emb_28267_17_20h_atac_2.bam_from0to100_rpm.bw   NA        FALSE           2             0             0.85       "#6C1E10" 

 ore50_14-17h    ATAC          150                150          dme_emb_ore50_orc4_14_17h_atac_1.bam_from0to100_rpm.bw    NA        FALSE           1             0             0.85       "#6C1E10" 

 ore50_14-17h    ATAC          150                150          dme_emb_ore50_orc4_14_17h_atac_2.bam_from0to100_rpm.bw    NA        FALSE           2             0             0.85       "#6C1E10" 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## load the samples



## Calculate enrichments

Before calculating enrichment, we floor the WCE signal for each region at the median WCE signal level among all transcripts.



## Save results






```
## 
## 	Pairwise comparisons using Wilcoxon rank sum test 
## 
## data:  .$enrichment and .$time 
## 
##              wt_14-17h orc4_14-17h orc4_17-20h
## orc4_14-17h  2.2e-10   -           -          
## orc4_17-20h  3.4e-11   0.69        -          
## ore50_14-17h 1.2e-14   0.19        0.69       
## 
## P value adjustment method: holm
```

```
## 
## 	Pairwise comparisons using Wilcoxon rank sum test 
## 
## data:  .$enrichment and .$time 
## 
##              wt_14-17h orc4_14-17h orc4_17-20h
## orc4_14-17h  0.687     -           -          
## orc4_17-20h  0.046     0.018       -          
## ore50_14-17h 0.549     0.362       0.549      
## 
## P value adjustment method: holm
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
[1] parallel  stats4    stats     graphics  grDevices utils     datasets 
[8] methods   base     

other attached packages:
 [1] BSgenome.Dmelanogaster.UCSC.dm6_1.4.1 BSgenome_1.52.0                      
 [3] Biostrings_2.52.0                     XVector_0.24.0                       
 [5] rtracklayer_1.44.4                    GenomicRanges_1.36.1                 
 [7] GenomeInfoDb_1.20.0                   IRanges_2.18.2                       
 [9] S4Vectors_0.22.1                      BiocGenerics_0.30.0                  
[11] pander_0.6.3                          magrittr_1.5                         
[13] tidyr_1.0.0                           dplyr_0.8.3                          
[15] ggplot2_3.2.1                         knitr_1.24                           

loaded via a namespace (and not attached):
 [1] SummarizedExperiment_1.14.1 tidyselect_0.2.5           
 [3] xfun_0.9                    purrr_0.3.2                
 [5] lattice_0.20-38             colorspace_1.4-1           
 [7] vctrs_0.2.0                 XML_3.98-1.20              
 [9] rlang_0.4.0                 pillar_1.4.2               
[11] glue_1.3.1                  withr_2.1.2                
[13] BiocParallel_1.18.1         matrixStats_0.55.0         
[15] GenomeInfoDbData_1.2.1      lifecycle_0.1.0            
[17] stringr_1.4.0               zlibbioc_1.30.0            
[19] munsell_0.5.0               gtable_0.3.0               
[21] evaluate_0.14               Biobase_2.44.0             
[23] Rcpp_1.0.2                  backports_1.1.4            
[25] scales_1.0.0                DelayedArray_0.10.0        
[27] Rsamtools_2.0.0             digest_0.6.20              
[29] stringi_1.4.3               grid_3.6.1                 
[31] tools_3.6.1                 bitops_1.0-6               
[33] lazyeval_0.2.2              RCurl_1.95-4.12            
[35] tibble_2.1.3                crayon_1.3.4               
[37] pkgconfig_2.0.2             zeallot_0.1.0              
[39] ellipsis_0.2.0.1            Matrix_1.2-17              
[41] assertthat_0.2.1            R6_2.4.0                   
[43] GenomicAlignments_1.20.1    compiler_3.6.1             
```
