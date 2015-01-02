library(shiny)
library(rCharts)

shinyUI(navbarPage(title = "R.Lum Statistics", inverse = TRUE, 
                   collapsible = TRUE, windowTitle = "R.Stats",
                   
                   tabPanel("Plot",
                            showOutput("plot_timeline", "morris")
                            ),
                   
                   tabPanel("Summary"
                            
                            ),
                   
                   
                   tabPanel("Table",
                            selectInput("dt_package",label = "Select package", 
                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                            dataTableOutput("dt_rawdata")
                            ),
                   
  includeCSS("./www/style.css")
))