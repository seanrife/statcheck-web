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
      
      column(6,
      
      br(),
             
      radioButtons("outtype", "Show:",
                   list("Summary table" = "tab",
                        "Detailed" = "detail")
      ),

      downloadLink('downloadData', 'Download full report (csv)') ,
      
      br()
      )
  
    ),
  
  # Plot in main:
  mainPanel(
    htmlOutput("window")
  )
))
