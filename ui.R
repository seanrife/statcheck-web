library('shiny')

shinyUI(
  fluidPage(

  # Input in sidepanel:
    fluidRow(
      column(6,
      
      br(),
             
      # Input:
      fileInput("files", "Upload files (pdf or html):", multiple = TRUE, accept= c('pdf/html')),

      br()
      
      ),
      
      
       conditionalPanel(condition='output.results',
       br(),
       br(),
       downloadButton('downloadData', 'Download Results (csv)'),

      br()
       )
      
  
    ),
  
  # Plot in main:
  mainPanel(
    tags$style(type="text/css", "data table { font-size: 11pt;}"),
    htmlOutput("window"),
    br(),
    br(),
    br()
  )
))
