library(shiny)


shinyUI(navbarPage(title = "R.Lum Statistics", inverse = TRUE, 
                   collapsible = TRUE, windowTitle = "R.Stats",
                   
                   tabPanel("Plot",
                            sidebarLayout(
                              sidebarPanel(width = 3,
                                           radioButtons("toggle_plot","Graph",
                                                        c("Timeline"="plot_timeline",
                                                          "Worldmap"="plot_map",
                                                          "Pie Chart"="plot_pie",
                                                          "Histogram"="plot_hist")),
                                           hr(),
                                           conditionalPanel("input.toggle_plot=='plot_map'",
                                                            selectInput("geo_package", "Select package", 
                                                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata"))))
                                           ),
                                           conditionalPanel("input.toggle_plot=='plot_pie'",
                                                            selectInput("pie_vars", "Select variable", selected = "r_arch",
                                                                        choices = c("R version"="r_version",
                                                                                    "Architecture"="r_arch",
                                                                                    "OS"="r_os",
                                                                                    "Country"="country"))
                                           ),
                                           conditionalPanel("input.toggle_plot=='plot_hist'",
                                                            selectInput("hist_vars", "Select variable", selected = "r_version",
                                                                        choices = c("R version"="r_version",
                                                                                    "Architecture"="r_arch",
                                                                                    "OS"="r_os",
                                                                                    "Country"="country"))
                                           )
                              ),
                              mainPanel(
                                conditionalPanel("input.toggle_plot=='plot_timeline'",
                                                 # PLOT 1
                                                 textOutput("js"),
                                                 htmlOutput("plot_timeline")
                                ),
                                conditionalPanel("input.toggle_plot=='plot_map'",
                                                 # PLOT 2
                                                 htmlOutput("plot_map")
                                ),
                                conditionalPanel("input.toggle_plot=='plot_pie'",
                                                 # PLOT 3
                                                 htmlOutput("plot_pie")
                                ),
                                conditionalPanel("input.toggle_plot=='plot_hist'",
                                                 # PLOT 4
                                                 htmlOutput("plot_hist")
                                )
                              )
                            )
                   ),
                   
                   tabPanel("Table",
                            selectInput("dt_package",label = "Select package", 
                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                            dataTableOutput("dt_rawdata")
                   ),
                   tags$head(includeScript("./www/plot_resize.js")),
                   tags$head(includeCSS("./www/style.css"))
))

