library(Biostrings)
library(BSgenome.Dmelanogaster.UCSC.dm6)
library(ggplot2)

motifs     <- read.delim("promoter_elements.txt", stringsAsFactors=F, header=T)

genes <- readRDS("fb.transcripts.r6.21.rds")
valid.chrs <- c("chr2L", "chr2LHet", "chr2R", "chr2RHet", "chr3L", "chr3LHet", "chr3R", "chr3RHet", "chr4", "chrX", "chrXHet", "chrYHet")
genes <- subset(genes, chr %in% valid.chrs)

piv <- which(genes$strand == 1)
niv <- which(genes$strand == -1)

results.df <- NULL

for(i in 1:nrow(motifs)) {
  message("Motif: ", motifs$name[i])
  
  motif     <- DNAString(motifs$motif[i])
  new_start <- motifs$new_start[i]
  new_end   <- motifs$new_end[i]

  # determine promoter region to scan
  genes$pstart <- NA
  genes$pend   <- NA

  genes[piv, ] <- transform(genes[piv, ], pstart = start + new_start,
                                          pend   = start + new_end)

  genes[niv, ] <- transform(genes[niv, ], pstart = end - new_end,
                                          pend   = end - new_start)

  chr_limits <- seqlengths(Dmelanogaster)

  igenes <- subset(genes, pstart > 0 | pstart <= chr_limits[as.character(chr)] & 
                          pend   > 0 | pend   <= chr_limits[as.character(chr)])


  igenes.p <- subset(igenes, strand ==  1)
  igenes.n <- subset(igenes, strand == -1)
  
  message(" - fetching sequences")
  forward_seq <- getSeq(Dmelanogaster, names=igenes.p$chr, start=igenes.p$pstart, end=igenes.p$pend, strand="+", as.character=FALSE)
  reverse_seq <- reverseComplement(getSeq(Dmelanogaster, names=igenes.n$chr, start=igenes.n$pstart, end=igenes.n$pend, strand="+", as.character=FALSE))

  names(forward_seq) <- igenes.p$fb_tx_id
  names(reverse_seq) <- igenes.n$fb_tx_id
  
  promoter_seqs <- c(forward_seq, reverse_seq)

  message(" - finding motif matches")
  mindex_0mm <- vmatchPattern(motif, promoter_seqs, fixed=FALSE, max.mismatch=0)
  mindex_1mm <- vmatchPattern(motif, promoter_seqs, fixed=FALSE, max.mismatch=1)
  
  df.0mm <- data.frame(mm=0, fb_tx_id=names(mindex_0mm), count=elementNROWS(mindex_0mm))
  df.1mm <- data.frame(mm=1, fb_tx_id=names(mindex_1mm), count=elementNROWS(mindex_1mm))

  motif.df <- rbind(df.0mm, df.1mm)
  motif.df$motif_name <- motifs$name[i]

  results.df <- rbind(results.df, motif.df)
}

to_wide_df <- function(df) {
  wide.df <- reshape(df, idvar="fb_tx_id", v.names="count", timevar="motif_name", direction="wide", drop="mm")
  names(wide.df) <- gsub("count\\.", "", names(wide.df))
  wide.df[, -1] <- as.matrix(wide.df[, -1]) > 0
  wide.df
}

pe.0mm <- to_wide_df(subset(results.df, mm == 0))
pe.1mm <- to_wide_df(subset(results.df, mm == 1))

save(pe.0mm, file="pe.0mm.RData")
save(pe.1mm, file="pe.1mm.RData")


