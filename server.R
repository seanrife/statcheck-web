library('shiny')
library('statcheck')

# Create a temporary directory to hold uploaded files
# Make sure it doesn't already exist (because paranoia)
# NOTE: replace with something more useful on deployment
createTempDir <- function() {
  repeat {
    randomDir <- paste(sample(c(0:9, letters, LETTERS),32, replace=TRUE), collapse="")
    retDir <- paste(tempdir(),randomDir,sep="\\")
    if (!file.exists(retDir)) {
      break
    }
  }
  dir.create(retDir)
  return(retDir)
}

shinyServer(function(input, output) {

  ## Files table:
  output$filetable <- renderTable({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
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
  

  # Paper selection:
  output$selectpaper <- renderUI({ 
    
    if (input$outtype !=  "detail") return(NULL)
    tab <- summary(Results())
    tab$Source <- as.character(tab$Source)

  })

  # Summary table:
  output$summary <- renderTable({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
    tab <- summary(Results())
    
    tab$Source <- as.character(tab$Source)
    #tab$Source[nchar(tab$Source) > 35] <- gsub('(?<=^.{30}).*',' (...)',  tab$Source[nchar(tab$Source) > 35], perl = TRUE)
    
    return(tab)
    
  })
  
  # Detailed:
  output$detailed <- renderTable({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
    tab <- Results()
    
    # More consise names:
    names(tab) <- c('Source','Stat','df1','df2','tc','rv','rc','rp','cp','raw','err','dErr','1Tail','1-tail in text','Copy & Paste','APA Factor')
    
    return(tab)
  })

  # Reactive output window (plot or table)
  output$window <- renderUI({
    if (input$outtype ==  'detail')
    {
      tableOutput("detailed")
    } else 
    {
      tableOutput("summary")
    }
  })
})

