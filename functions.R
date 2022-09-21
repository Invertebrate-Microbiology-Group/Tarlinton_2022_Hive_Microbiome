readQIIMEFolder <- function(path = "") {
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
makeObservationsRelative <- function(physeq) {
  physeq <- transform_sample_counts(physeq, function(x) {x/sum(x)})
  return(physeq)
}
makeObservationsBinary <- function(physeq) {
  physeq <- transform_sample_counts(physeq, function(x) {x/x})
  otu_table(physeq) <- transform_sample_counts(physeq, function(x) {
    replace_na(x, 0)})
  return(physeq)
}
removeNonbacterial <- function(physeq) {
  Kingdom <- Order <- Family <- NULL
  subset_taxa(physeq, Kingdom != "Unassigned") %>%
    #Remove Taxa Unassigned at Kingdom Level
    subset_taxa(Order!= "Chloroplast" | is.na(Order)) %>% #Remove Chloroplasts
    subset_taxa(Family!= "Mitochondria" | is.na(Family))} #Remove Mitochondria
makeObservationsRelative <- function(physeq) {
  physeq <- transform_sample_counts(physeq, function(x) {x/sum(x)})
  return(physeq)
}
prevalenceFilter <- function(physeq, threshold) {
  physeq2 <- makeObservationsBinary(physeq)
  physeq2 <- tryCatch(prune_taxa(taxa_sums(
    physeq2) >= (threshold * nsamples(physeq)),
    physeq), error = function(e){
      return(NULL)
    })
  return(physeq2)
}