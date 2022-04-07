library(ggplot2)
library(scales)
library(dplyr)

source("shared/stat_tests.r")

load_promoter_elements <- function(file="promoter_elements/pe.0mm.RData") {
  get(load(file))
}

oob_function<-function(x,range){x}

promoter_element_enrichments <- function(tx_groups, tx_universe=c()) {
  
  txs.df <- flybase_txs()
  
  if(length(tx_universe) == 0) {
    tx_universe <- txs.df$fb_tx_id
  } else {
    txs.df <- subset(txs.df, fb_tx_id %in% tx_universe)
  }
  
  txs.df <- transform(txs.df, tss = ifelse(strand == 1, start, end))
  txs.df <- transform(txs.df, tx_id = paste(chr, tss, strand, sep="_"))[, c("fb_tx_id", "tx_id")]
  
  pe.df <- merge(txs.df, load_promoter_elements())
  pe.df$fb_tx_id <- NULL
  elements <- names(pe.df)[-1]
  
  results.df <- names(tx_groups) %>%
    lapply(function(group_name) {
      group_txs <- tx_groups[[group_name]]
      group_ids <- unique(subset(txs.df, fb_tx_id %in% group_txs)$tx_id)
      
      group.df <- elements %>%
        lapply(function(element) {
          element_ids <- pe.df$tx_id[pe.df[, which(names(pe.df) == element)] == TRUE]
          
          element_ftest <- fisher_test_2x2(group_ids, element_ids, unique(pe.df$tx_id))
          element_ftest$element <- element
          element_ftest
        }) %>%
        bind_rows()
      group.df$group_name <- group_name
      group.df    
    }) %>%
    bind_rows()
  results.df  
}

promoter_element_heatmap <- function(plot.df, 
                                     title,
                                     element.order=c("TATA", "Inr", "DPE", "PB", "MTE", "DRE", "Motif1", "Motif6", "Motif7"),
                                     manual.scale=c(),
                                     star_pvalue=0.05) {
  
  plot.df <- transform(plot.df, enrichment = ifelse(enrichment < 1, -1 / enrichment, enrichment),
                       sig_label = ifelse(pvalue < star_pvalue, "*", ""))
  
  if(length(manual.scale) > 0) {
    e.limit.down <- min(manual.scale)
    e.limit.up   <- max(manual.scale)
  } else {
    e.limit.up <- max(abs(plot.df$enrichment[is.finite(plot.df$enrichment)]))
    e.limit.down <- -1 * e.limit.up
  }
  
  plot.df <- subset(plot.df, element %in% element.order)
  plot.df$element <- factor(plot.df$element, levels=element.order)
  
  plot.df$enrichment[plot.df$enrichment>e.limit.up]<-e.limit.up
  plot.df$enrichment[plot.df$enrichment<e.limit.down]<-e.limit.down
  
   g<-ggplot(plot.df, aes(x=element, y=group_name, fill=enrichment)) + 
    geom_tile() + 
    geom_text(aes(label=sig_label), color="white") +
    theme_bw() +
    scale_x_discrete(expand=c(0, 0)) +
    scale_y_discrete(expand=c(0, 0)) +
    scale_fill_gradientn(name="Enrichment", space="rgb", na.value="yellow",
                         values=c(e.limit.down, -0.5, 0.5, e.limit.up), 
                         colours=c("#000000", "#cccccc", "#cccccc", "#FC8F00"), 
                         rescaler=function(x,...) x, oob=oob_function,
                         limits=c(e.limit.down, e.limit.up), guide=guide_colorbar()) +
    labs(x="", y="", title=title) +
    theme(panel.grid.minor=element_blank(),
          panel.grid.major=element_blank())
}

