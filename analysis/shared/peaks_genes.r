library(GenomicRanges)
library(rtracklayer)

peaks_genes<-function(peaks_file_bed_path){
peaks.gr <- import(peaks_file_bed_path)
strand(peaks.gr) <- "*"
peaks.gr
genes <- get(load("/n/projects/vir/gaffactor/flybase/fb.transcripts.r5.47.RData"))

genes.gr <- with(genes, GRanges(ranges     = IRanges(start=start, end=end), 
                                seqnames   = chr, 
                                strand     = ifelse(strand == 1, "+", "-"),
                                fb_gene_id = fb_gene_id,
								fb_tx_id = fb_tx_id,
                                fb_symbol  = fb_symbol))
genes.gr
tss.gr <- resize(genes.gr, width=1, fix="start")
strand(tss.gr) <- "*"

n <- nearest(peaks.gr, tss.gr, ignore.strand=TRUE)

mcols(peaks.gr)$nearest_gene_id     <- mcols(tss.gr)$fb_gene_id[n]
mcols(peaks.gr)$nearest_tx_id     <- mcols(tss.gr)$fb_tx_id[n]

mcols(peaks.gr)$nearest_gene_symbol <- mcols(tss.gr)$fb_symbol[n]
genes_no_strand.gr <- genes.gr
strand(genes_no_strand.gr) <- "*"

overlaps <- subset(as.data.frame(distanceToNearest(peaks.gr, genes_no_strand.gr, ignore.strand=TRUE)), distance == 0)
if(nrow(overlaps) > 0) {
  mcols(peaks.gr)$nearest_gene_id[overlaps$queryHits] <- mcols(genes_no_strand.gr)$fb_gene_id[overlaps$subjectHits]
  mcols(peaks.gr)$nearest_gene_symbol[overlaps$queryHits] <- mcols(genes_no_strand.gr)$fb_symbol[overlaps$subjectHits]
}
return(peaks.gr);
}

