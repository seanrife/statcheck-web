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

     
      
      br()
      )
  
    ),
  
  # Plot in main:
  mainPanel(
    tags$style(type="text/css", "data table { font-size: 11pt;}"),
    htmlOutput("window"),
    br()
    #downloadLink('downloadData', 'Download full report (csv)')
  )
))
