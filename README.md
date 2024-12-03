The calculate_avg_expression_nested function performs a comprehensize analysis pipeline
designed for weighted gene co-expression network analysis (WGCNA), followed by 
Gene Ontology (GO) enrichment analysis, and the calculation of pathway-level expression
averages. This function is particularly useful for identifying biologically relevant pathways
and their associated gene expression patterns across different sample groups or conditions.
Key steps involved in this analysis include:
1. WGCNA Analysis: This function utilizes the blockwiseModules function from the WGCNA package
   to construct a gene co-expression network, identify gene modules, and assign cluster labels
   based on co-expression patterns. This step ensures the identification of biologically
   meaningful clusters of genes that exhibit similar expression trends. 
