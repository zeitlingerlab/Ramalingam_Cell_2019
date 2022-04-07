library(GOstats)
library(org.Dm.eg.db)

flybase_to_eg <- function(fb_ids) {
  idmap <- readRDS("flybase/fbidmap.rds")
  fb_ids <- subset(idmap, prev_id %in% fb_ids)$fb_gene_id
  fb_ids <- unique(c(fb_ids, subset(idmap, fb_gene_id %in% fb_ids)$prev_id))

  na.omit(unlist(mget(as.character(fb_ids), org.Dm.egFLYBASE2EG, ifnotfound=NA)))
}

get_gene_names_for_bpid <- function(bpid, go_results) {
  matching <- geneIdsByCategory(go_results, bpid)[[1]]
  paste(sort(unlist(na.omit(mget(matching, org.Dm.egSYMBOL, ifnotfound=NA)))), collapse=", ")
}

run_go <- function(fb_ids, universe_fb_ids) {
  test_ids     <- unique(flybase_to_eg(fb_ids))
  universe_ids <- unique(flybase_to_eg(universe_fb_ids))
  
  go.params <- new("GOHyperGParams", 
                   geneIds=test_ids,
                   universeGeneIds=universe_ids,
                   annotation="org.Dm.eg.db",
                   ontology="BP",
                   pvalueCutoff=0.01,
                   conditional=TRUE,
                   testDirection="over")
  go.results <- hyperGTest(go.params)

  results.df <- summary(go.results)
  results.df$Gene_Names <- sapply(results.df$GOBPID, get_gene_names_for_bpid, go.results)  
  results.df
}
