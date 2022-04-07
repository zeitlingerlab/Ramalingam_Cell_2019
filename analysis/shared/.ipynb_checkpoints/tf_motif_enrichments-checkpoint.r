significant_motifs<- function(sample.gr,control.gr,fimo.gr,cutoff=0.01,BH_correction=TRUE) {
	
	
motif_counts <- function(regions.gr, motifs.gr) {
  ol <- as.data.frame(findOverlaps(query=motifs.gr, subject=regions.gr, type="within", ignore.strand=TRUE))
  ol$motif <- mcols(motifs.gr)$name[ol$queryHits]
  ol$queryHits <- NULL
  hits.df <- ddply(ol, .(motif), plyr::summarize, with_motif=length(unique(subjectHits)))

  all.motifs <- unique(as.character(mcols(motifs.gr)$name))
  missing.motifs <- all.motifs[!all.motifs %in% hits.df$motif]
  
  if(length(missing.motifs) > 0) {
    missing.df <- data.frame(stringsAsFactors=FALSE, motif=missing.motifs, with_motif=0)
    hits.df <- rbind(hits.df, missing.df)
  }

  hits.df$without_motif <- length(regions.gr) - hits.df$with_motif
  hits.df[order(hits.df$with_motif, decreasing=TRUE), ]
}

proportion_test <- function(values, enrichment=TRUE) {
  stopifnot(is.logical(enrichment))
  m <- matrix(values, nrow=2, byrow=TRUE)
  alt.test <- ifelse(enrichment, "greater", "less")
  prop.test(m, alternative=alt.test)$p.value
}

single_motif_test <- function(row.df, enrichment) {
  proportion_test(as.numeric(c(row.df$s1_W, row.df$s1_WO, row.df$s2_W, row.df$s2_WO)), enrichment)
}

motif_count_comparison <- function(set1.df, set2.df) {
  stopifnot(nrow(set1.df) == nrow(set2.df))
  
  names(set1.df)[2:3] <- c("s1_W", "s1_WO")
  names(set2.df)[2:3] <- c("s2_W", "s2_WO")
  
  set.df <- merge(set1.df, set2.df)
  stopifnot(nrow(set.df) == nrow(set1.df))
  
  set_test.df   <- subset(set.df, s1_W > 0 | s2_W > 0)
  
  e_set_test.df <- set_test.df
  e_set_test.df$test_type <- "enrichment"
  
  e_set_test.df$pvalue <- as.vector(by(e_set_test.df, 1:nrow(e_set_test.df), single_motif_test, enrichment=TRUE))

  d_set_test.df <- set_test.df
  d_set_test.df$test_type <- "depletion"
  
  d_set_test.df$pvalue <- as.vector(by(d_set_test.df, 1:nrow(d_set_test.df), single_motif_test, enrichment=FALSE))

  set_test.df <- rbind(e_set_test.df, d_set_test.df)

  set_notest.df <- subset(set.df, s1_W == 0 & s2_W == 0)
  if(nrow(set_notest.df) > 0) {
    set_notest.df$pvalue <- 1
    e_set_notest.df <- set_notest.df
    e_set_notest.df$test_type <- "enrichment"
    
    d_set_notest.df$pvalue <- 1
    d_set_notest.df$test_type <- "depletion"
    
    set.df <- rbind(set_test.df, e_set_notest.df, d_set_notest.df)
  } else {
    set.df <- set_test.df
  }
  
  stopifnot(nrow(set.df) == 2 * nrow(set1.df))
  set.df <- transform(set.df, enrichment = (s1_W/(s1_W+s1_WO)) / (s2_W/(s2_W+s2_WO)) )
  set.df <- transform(set.df, enrichment = ifelse(test_type == "enrichment", enrichment, -1 / enrichment))
  set.df
}


counts.control <- motif_counts(control.gr, fimo.gr)
counts.sample <- motif_counts(sample.gr, fimo.gr)

results_test.df <- motif_count_comparison(counts.sample,counts.control)

if(BH_correction == TRUE){
results_test.df$padj <- p.adjust(results_test.df$pvalue, method="BH")


results_test.df <- arrange(results_test.df, motif, padj)
results_test.df <- results_test.df[!duplicated(results_test.df$motif), ]

sig_motifs_test.df <- subset(results_test.df, padj < cutoff)
sig_motifs_test.df <- arrange(sig_motifs_test.df, padj)
sig_motifs_test.df
	} else {
results_test.df <- arrange(results_test.df, motif, pvalue)
results_test.df <- results_test.df[!duplicated(results_test.df$motif), ]

sig_motifs_test.df <- subset(results_test.df, pvalue < cutoff)
sig_motifs_test.df <- arrange(sig_motifs_test.df, pvalue)
sig_motifs_test.df
}
}