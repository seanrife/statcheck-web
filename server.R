library("shiny")
library("statcheck")
library("DT")
library("tidyverse")

options(shiny.sanitize.errors = FALSE)
options(shiny.maxRequestSize = 100 * 1024 ^ 2)

# Create a temporary directory to hold uploaded files
# Make sure it doesn"t already exist (because paranoia)
# NOTE: replace with something more useful on deployment
createTempDir <- function() {
  repeat {
    randomDir <-
      paste(sample(c(0:9, letters), 32, replace = TRUE), collapse = "")
    retDir <- paste("~/statcheck-web/uploads", randomDir, sep = "/")
    if (!file.exists(retDir)) {
      break
    }
  }
  dir.create(retDir)
  return(retDir)
}

shinyServer(function(input, output) {
  Results <- reactive({
    Dir <- createTempDir()
    
    # Copy to the directory:
    needCopy <- !file.exists(paste0(Dir, "/", input$files$name))
    file.copy(input$files$datapath[needCopy],
              paste0(Dir, "/", input$files$name[needCopy]))
    
    # Read in statcheck:
    res <- checkdir(Dir, OneTailedTxt = input$oneTail)
    output$message <- renderText({
      resCap
    })
    
    unlink(Dir, recursive = TRUE)
    return(res)
    
  })
  
  output$downloadData <- downloadHandler(
    filename = "statcheckReport.csv",
    content = function(con) {
      if (is.null(input$files)) {
        # User has not uploaded a file yet
        return(NULL)
      }
      
      write.csv(Results(), con, row.names = FALSE)
    }
  )
  
  # Detailed:
  output$results <- DT::renderDataTable({
    req(input$files)
    
    tabResults <- Results() %>%
      mutate(Consistency =
               ifelse(
                 Error == FALSE,
                 "Consistent",
                 ifelse(
                   DecisionError == TRUE,
                   "Decision Inconsistency",
                   "Inconsistency"
                 )
               )) %>%
      select(Source, Raw, Computed, Consistency)
    
    # More consise names:
    names(tabResults) <-
      c("Source",
        "Statistical Reference",
        "Computed p Value",
        "Consistency")
    
    tabResults[, 3] <- sprintf("%.05f", tabResults[, 3])
    
    tabResults$Source <- as.character(tabResults$Source)
    tabResults$Source[nchar(tabResults$Source) > 35] <-
      gsub("(?<=^.{30}).*", " (...)",  tabResults$Source[nchar(tabResults$Source) > 35], perl = TRUE)
    
    print(head(tabResults))
    
    return(tabResults)
  })
  
  # Download data:
  output$downloadData <- downloadHandler(
    filename = function() {
      "statcheck.csv"
    },
    content = function(file) {
      write.csv(Results(), file, row.names = FALSE)
    }
  )
  
  output$window <- renderUI({
    div(DT::dataTableOutput("results"))
  })
})