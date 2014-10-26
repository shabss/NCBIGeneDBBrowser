library(shiny)

source("gene.R")
genedbs <- load.gene.subset()

shinyServer(function(input, output) {
    
    output$selectUI <- renderUI({
        selectInput("dataset", "Choose a dataset:", as.character(genedbs$db), width='100%' )
    })
    
    datasetInput <- reactive({
        genedb <- genedbs[genedbs$db == input$dataset,]
        if (!is.null(genedb)) {
            genedata <- genedb$genedata[[1]]    
        } else {
            genedata <- data.frame()
        }
        genedata
    })
    
    output$table <- renderTable({
        datasetInput()
    })
})
