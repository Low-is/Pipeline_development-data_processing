Pipeline Development - Data Processing

This repository contains an interactive Shiny application designed to streamline the initial data processing and gene ID mapping stage of a transcriptomic data analysis pipeline. The functionality enables users to convert gene identifiers across species using Ensembl BioMart. All mappings are curated and stored locally in an SQLite database for efficient and reproducible downstream analyses.

Features:
Upload expression matrix: Accepts user-supplied CSV or TSV files.
Species selection: Choose from any species available in Ensembl.
Automatic gene ID type detection: Identifies the best-matching gene ID type (e.g., HGNC symbol, Entrez ID).
ID mapping: Maps user gene IDs to Ensembl gene IDs using species-specific BioMart annotations.
SQLite integration: Stores gene annotations in a local convertIDs.db file for persistent use.
Preview mapped data: Outputs a cleaned expression matrix with standardized Ensembl gene identifiers.

Key Components:
1. Connects to Ensembl BioMart and fetches gene attributes such as:
   - ensembl_gene_id
   - external_gene_name
   - entrezgene_id
   - hgnc_symbol
   - hgnc_id
   - description
2. Shiny App Workflow
   - fileInput(): allows users to upload expression matrices.
   - selectInput(): lets users pick a species from available Ensembl datasets.
   - actionButton(): triggers mapping using pre-stored annotation data.
   - detect_best_id_column(): auto-detects the matching ID type used in th expression matrix.

Citations:

1. Ge, Son & Yao, iDEP: an integrated web application for differential expression and pathway analysis of RNA-Seq data, BMC Bioinformatics 19:1-24, 2018. [Ge-Lab.org/iDEP](http://ge-lab.org/idep/)
2. Howe KL, Achuthan P, Allen J, Alvarez-Jarreta J, et al. Ensembl 2024. Nucleic Acids Res. 2024 Jan;52(D1):D977-D9893.doi:10.1093/nar/gkad1029 [D977-D9893.doi:10.1093/nar/gkad1029](https://doi.org/10.1093/nar/gkad1049)
