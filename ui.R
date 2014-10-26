library(shiny)

shinyUI(fluidPage(
    verticalLayout(
        fluidRow(
            column(width=10, titlePanel("NCBI Gene Database")),
            column(width=1, a("Help", href="ftp://ftp.ncbi.nlm.nih.gov/gene/README")),
            column(width=1, a("Pitch", href="http://shabss.github.io/NCBIGeneDBBrowserPitch/index.html"))
        ),
        htmlOutput("selectUI"),
        mainPanel(
            tableOutput('table')
        )
    )
))

#end
