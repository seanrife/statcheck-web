library("shiny")

shinyUI(fluidPage(
  
  # Input in sidepanel:
  # fluidRow(column(6, br(),
  
  fluidRow(
    column(6,
           
           br(),
           
    fileInput(
        "files",
        "Upload files (pdf, html, or docx):",
        multiple = TRUE,
        accept = c('pdf/html/docx')
      ),
    
    
    # Input:
    checkboxInput(
      "oneTail",
      "Try to identify and correct for one-tailed tests?",
      value = FALSE,
      width = NULL
    ),

      br()
      
    ),
    
    
    conditionalPanel(
      condition = 'output.results',
      br(),
      br(),
      downloadButton('downloadData', 'Download Results (csv)'),
      
      br()
    )
  ),
  
  # Plot in main:
  mainPanel(shiny::uiOutput("window"),
            br(),
            br(),
            br())
))
