library(shiny)

shinyUI(fluidPage(
    verticalLayout(
        fluidRow(
            column(width=10, titlePanel("NCBI Gene Database")),
            column(width=2, a("Help", href="./help.html"))
        ),
        htmlOutput("selectUI"),
        mainPanel(
            tableOutput('table')
        )
    )
))

