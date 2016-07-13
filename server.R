library('shiny')
library('statcheck')

# Create a temporary directory to hold uploaded files
# Make sure it doesn't already exist (because paranoia)
# NOTE: replace with something more useful on deployment
createTempDir <- function() {
  repeat {
    randomDir <- paste(sample(c(0:9, letters),32, replace=TRUE), collapse="")
    retDir <- paste(tempdir(),randomDir,sep="\\")
    if (!file.exists(retDir)) {
      break
    }
  }
  dir.create(retDir)
  return(retDir)
}

shinyServer(function(input, output) {

  # File table:
  output$filetable <- renderTable({
    if (is.null(input$files)) return(NULL)
    
    tab <- input$files[,'name',drop=FALSE]
    tab$name[nchar(tab$name) > 23] <- gsub('(?<=^.{20}).*(?=\\.)','(...)',  tab$name[nchar(tab$name) > 23], perl = TRUE)
    
    return(tab)
  })

  Results <- reactive({ 
    
    Dir <- createTempDir()
    
    # Copy to the directory:
    needCopy <- !file.exists(paste0(Dir,'\\',input$files$name))
    file.copy(input$files$datapath[needCopy],paste0(Dir,'\\',input$files$name[needCopy]))

    # Read in statcheck:
    res <- checkdir(Dir)
    output$message <- renderText({resCap})
    
    unlink(Dir, recursive=TRUE)
    return(res)
    
  })
  
  output$downloadData <- downloadHandler(
    filename = 'statcheckReport.csv',
    content = function(con) {
      if (is.null(input$files)) {
        # User has not uploaded a file yet
        return(NULL)
      }
      
      write.csv(Results(), con)
    })

  # Summary table:
  output$summary <- renderTable({
    if (is.null(input$files)) return(NULL)
    
    tabSummary <- summary(Results())
    
 
    return(tabSummary)
    
  })
  
  # Detailed:
  output$results <- renderTable({
    if (is.null(input$files)) return(NULL)
    
    tabResults <- Results()
    
    # More consise names:
    names(tabResults) <- c('Source','Stat','df1','df2','Test Comparison','Reported Value','Reported Comparison','Reported p Value','Computed p Value','Statistical Reference','Error?','Decision error?','One-sided testing?','1-tail in text','Copy & Paste Error?','APA Factor')
    
    tabResults$Source <- as.character(tabResults$Source)
    tabResults$Source[nchar(tabResults$Source) > 35] <- gsub('(?<=^.{30}).*',' (...)',  tabResults$Source[nchar(tabResults$Source) > 35], perl = TRUE)
    
    return(tabResults)
  })

  output$window <- renderUI({
      tableOutput("summary")
      div(tableOutput("results"), style="font-size:80%; font-family: Helvetica Neue,Helvetica,Arial,sans-serif")
  })
})

