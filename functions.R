readQZAFolder <- function(path = "") {
physeq <-  qza_to_phyloseq(features = paste0(path, "/feat_tab.qza"),
                  taxonomy = paste0(path, "/taxonomy.qza"))
  
tax_1 <- read_qza(paste0(path, "/taxonomy.qza"))

tax_table(physeq) <- as.character(tax_1$data$Taxon) |>
    strsplit(";") |>
    do.call(what = qpcR:::rbind.na) |>
    set_colnames(c("Kingdom", "Phylum", "Class", "Order", "Family", 
                   "Genus", "Species")) |>
    data.frame() |>
    lapply(str_replace_all, ".*_", "") |> 
    as.data.frame()  |>
    set_rownames(tax_1$data$Feature.ID) |>
    as.matrix()

physeq  
}
