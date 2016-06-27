library('shiny')
library('statcheck')

shinyServer(function(input, output) {
  
  Dir <- tempdir()
  
  Results <- reactive({ 
    
    # Copy to the directory:
    needCopy <- !file.exists(paste0(Dir,'/',input$files$name))
    file.copy(input$files$datapath[needCopy],paste0(Dir,'/',input$files$name[needCopy]))
    
    # Read in statcheck:
    res <- checkdir(Dir)
    
    return(res)
  })
  
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
  
  ## Plotting window:
  output$plot <- renderPlot({
    if (is.null(input$files) || is.null(Results)) {
      # User has not uploaded a file yet
      return(NULL)
    }      
    
    par(mar=c(7,2,1,2))
    plot(Results())
    
  }, width = 'auto', height = 'auto')
  
  
  
  # Download data:
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
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
    tab <- summary(Results())
    
    tab$Source <- as.character(tab$Source)
    tab$Source[nchar(tab$Source) > 35] <- gsub('(?<=^.{30}).*',' (...)',  tab$Source[nchar(tab$Source) > 35], perl = TRUE)
    
    return(tab)
  })
  
  # Paper selection:
  output$selectpaper <- renderUI({ 
    
    if (input$outtype !=  "detail") return(NULL)
    
    tab <- summary(Results())
    
    tab$Source <- as.character(tab$Source)

    selectInput("detPaper", 'See details of:', tab$Source)
  })

  
  # Detailed:
  output$detailed <- renderTable({
    if (is.null(input$files)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
    tab <- Results()
    tab$Source <- as.character(tab$Source)
    tab <- tab[tab$Source == input$detPaper,]
    
    tab <- tab[,!names(tab)%in%c("Source","Raw")]
    
    # Confert TRUE to x:
    for (i in seq_along(tab)) if (is.logical(tab[[i]])) tab[[i]] <- ifelse(tab[[i]],'x','')
    # More consise names:
    names(tab) <- c('Stat','df1','df2','tc','rv','rc','rp','cp','err','dErr','1Tail','Copy')
    
    return(tab)
  })
  
  
  output$legendText <- renderUI({
    if (input$outtype !=  'detail') return(NULL)
    
      p("Legend:")  
  })
  output$legendField <- renderUI({
    if (input$outtype !=  'detail') return(NULL)
    
    tableOutput("legend") 
  })
  
  
 
    
  # Detailed:
  output$legend <- renderTable({
   leg <- data.frame(
     c('Stat','df1','df2','tc','rv','rc','rp','cp','err','dErr','1Tail','Copy'),
     c("Statistic", "df1", "df2", "Test Comparison", "Reported Value", "Reported Comparison", 
       "Reported p-value", "Computed p-value", "Error", "Decision Error", "One-Tail", 
       "Copy-Paste"))
    
   names(leg) <- NULL
    return(leg)
  })
  
  
  # Reactive output window (plot or table)
  output$window <- renderUI({
    if (input$outtype ==  "plot")
    {
      plotOutput("plot",'100%','600px')
    } else if (input$outtype ==  'detail')
    {
      tableOutput("detailed")
    } else 
    {
      tableOutput("summary")
    }
    
    
    
  })
})

