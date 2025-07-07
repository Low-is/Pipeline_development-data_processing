#### PIPELINE DEVELOPMENT ####
#### Initial data processing ####
library(biomaRt)
library(DBI)
library(httr)
library(jsonlite)
library(shiny)
library(dplyr)
library(RSQLite)


#### Define 'All' species list ####
# ensembl <- useMart("ensembl", dataset = "hsapiens_gene_ensembl") # only for Humans
ensembl <- useMart("ensembl") # All species
datasets <- listDatasets(ensembl)
all_attributes <- listAttributes(ensembl)
filtered_attributes <- all_attributes[grep("id|symbol|accession|name|probe", all_attributes$name), ]
filtered_attributes <- filtered_attributes[filtered_attributes$page == "feature_page", ]
attribute_names <- filtered_attributes$name
attribute_names <- c(
  "ensembl_gene_id",
  "external_gene_name",
  "entrezgene_id",
  "description",
  "hgnc_symbol",
  "hgnc_id"
)
mapping <- getBM(attributes = attribute_names, mart = ensembl)
safe_column_names <- make.names(attribute_names)

column_defs <- paste(sprintf('"%s" TEXT', safe_column_names), collapse = ",")
sql_create <- sprintf("CREATE TABLE IF NOT EXISTS gene_annotations (%s);", column_defs)

#### Creating database ####
DB_PATH <- "convertIDs.db"
db <- dbConnect(RSQLite::SQLite(), DB_PATH)

#### Creating table in database ####
dbExecute(db, sql_create) # creating the table
dbWriteTable(db, "gene_annotations", mapping, append = TRUE, row.names = FALSE) # inserting data into table
dbListTables(db)
dbGetQuery(db, "SELECT * FROM gene_annotations LIMIT 5;")
dbDisconnect(db)


detect_best_id_column <- function(users_ids, mapping_table) {
  id_columns <- colnames(mapping_table)[colnames(mapping_table) != "ensembl_gene_id"]
  match_scores <- sapply(id_columns, function(col) sum(user_ids %in% mapping_table[[col]], na.rm = TRUE))
  best_match <- names(which.max(match_scores))
  return(best_match)
}


#### Creating drop-down menu for gene annotations ####
species_choices <- setNames(datasets$dataset, datasets$description)

ui <- fluidPage(
  titlePanel("Gene ID Mapper"),
  sidebarLayout(
    sidebarPanel(
      fileInput("expr_file", "Upload Expression Matrix (CSV or TSV)"),
      selectInput("species", "Choose species:", choices = species_choices),
      actionButton("map_btn", "Map Gene IDs")
      ),
    mainPanel(
      verbatimTextOutput("id_type_detected"),
      tableOutput("mapped_data")
      )
    )
  )
  
server <- function(input, output, session) {
  user_expr <- reactiveVal()
  db <- dbConnect(SQLite(), DB_PATH)
  
  observeEvent(input$expr_file, {
    req(input$expr_file)
    df <- read.csv(input$expr_file$datapath, row.names = 1, check.names = FALSE)
    user_expr(df)
  })
  
  
  observeEvent(input$map_btn, {
    req(user_expr(), input$species)
    user_ids <- rownames(user_expr())
    mapping_tbl <- dbReadTable(db, input$species)
    
    best_column <- detect_best_id_column(user_ids, mapping_tbl)
    output$id_type_detected <- renderText({
      paste("Detected ID type:", best_column)
    })
    
    
    merged <- merge(
      data.frame(user_id = user_ids, stringsAsFactors = FALSE),
      mapping_tbl,
      by.x = "user_id",
      by.y = best_column,
      all.x = TRUE
    )
    
    merged_final <- merged[!is.na(merged$ensembl_gene_id), ]
    expr_data <- user_expr()
    expr_data <- expr_data[rownames(expr_data) %in% merged$user_id, ]
    
    # Replace rownames with Ensembl IDs
    rownames(expr_data) <- merged_final$ensembl_gene_id
    
    output$mapped_data <- renderTable(head(expr_data))
  })
  
  session$onSessionEnded(function() {
    dbDisconnect(db)
  })
}
shinyApp(ui, server)
