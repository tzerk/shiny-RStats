library(shiny)

shinyUI(navbarPage(title = "R.Lum Statistics", inverse = TRUE, 
                   collapsible = TRUE, windowTitle = "R.Stats",
                   
                   tabPanel("Plot",
                            htmlOutput("plot_timeline"),
                            
                            selectInput("geo_package", "Select package", 
                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                            htmlOutput("plot_map"),
                            
                            selectInput("pie_vars", "Select variable", selected = "r_arch",
                                        choices = c("R version"="r_version",
                                                    "Architecture"="r_arch",
                                                    "OS"="r_os",
                                                    "Country"="country")),
                            htmlOutput("plot_pie"),
                            
                            selectInput("hist_vars", "Select variable", selected = "r_version",
                                        choices = c("R version"="r_version",
                                                    "Architecture"="r_arch",
                                                    "OS"="r_os",
                                                    "Country"="country")),
                            htmlOutput("plot_hist")
                            
                            ),
                   
                   tabPanel("Table",
                            selectInput("dt_package",label = "Select package", 
                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                            dataTableOutput("dt_rawdata")
                            ),
                   
  tags$head(includeCSS("./www/style.css"))
))