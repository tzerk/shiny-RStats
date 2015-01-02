shinyUI(navbarPage(title = "R.Lum Statistics", inverse = TRUE, 
                   collapsible = TRUE, windowTitle = "R.Stats",
                   
                   tabPanel("Plot",
                            textOutput(outputId = "text")
                            ),
                   
                   tabPanel("Summary"
                            
                            ),
                   
                   
                   tabPanel("Table" 
                            
                            ),
                   
  includeCSS("./www/style.css")
))