library('shiny')
library('statcheck')

shinyUI(pageWithSidebar(
  
  # Header:
  headerPanel("statcheck web interface"),
  
  # Input in sidepanel:
  sidebarPanel(
      
    # Input:
    fileInput("files", "Upload files (pdf or html):", multiple = TRUE, accept= c('pdf/html')),
    
    br(),
    
    radioButtons("outtype", "Show:",
                 list("Summary table" = "tab",
                      "Detailed" = "detail")
    ),
    
    htmlOutput("selectpaper"),
    
    br(),
    
    downloadLink('downloadData', 'Download full report (csv)') ,
    
    br(),
    
    htmlOutput("legendText"),
    
    htmlOutput("legendField")
    
  ),
  
  # Plot in main:
  mainPanel(
    htmlOutput("window")
  )
))
