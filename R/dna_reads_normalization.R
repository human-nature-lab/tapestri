
#' Normalize barcode data
#'
#' @param reads matrix of read counts per amplicon per cell
#' @param advanced advance normalization (dividing read counts by cell median before applying normalization by total sum)
#'
#' @return normalized_barcodes - normalized barcode data
#' @export
normalize_dna_reads <- function(reads, advanced = FALSE) {
  
  normalized_barcodes <- reads
  
  if (advanced == TRUE) {
    df <- as.matrix(normalized_barcodes)
    
    y <- colSums(df)
    z <- y / stats::median(y)
    df <- df[, names(z[z > 0.2])]
    
    ampnorm <- c()
    
    for (col in colnames(df)) {
      ampnorm <- cbind(ampnorm, as.numeric(round(df[, col] / z[col], 3)))
    }
    colnames(ampnorm) <- colnames(df)
    rownames(ampnorm) <- rownames(df)
    
    normalized_barcodes <- ampnorm
  }
  normalized_barcodes <- t(apply(
    normalized_barcodes, 1,
    norm <- function(x) {
      return(x / sum(x))
    }
  ))
  
  return(normalized_barcodes)
}


#' Identify ploidy for samples
#'

#' @param reads dna read counts matrix
#' @param clusters vector with labels for which cluster each cell belongs to
#' @param baseline_cluster one cluster label assumed to be the normal cell population with ploidy 2. 
#'
#' @return normalized read counts centered around ploidy 2. amplicons with low read counts are removed
#' @export
#'
compute_ploidy <- function(reads, clusters, baseline_cluster) {
  
  #reads = experiment$assays$cnv$data_layers$normalized
  
  baseline_cluster_cells = clusters == baseline_cluster
  
  barcodes.med <- apply(reads, 2, stats::median)
  reads <- reads[, barcodes.med > 0.0005]
  reads = as.matrix(reads)
  
  norm.group <- reads[baseline_cluster_cells, ]
  
  norm_group_median = apply(norm.group, 2, stats::median, na.rm = TRUE)

  
  ploidy = t(2 * (t(reads) / norm_group_median))
  

  
  return(ploidy)
}



