library(shiny)
library(threejs)
library(RLumShiny)

shinyUI(navbarPage(title = "R.Lum Statistics", inverse = TRUE, 
                   collapsible = TRUE, windowTitle = "R.Stats",
                   
                   tabPanel("Plot",
                            sidebarLayout(
                              sidebarPanel(width = 3,
                                           radioButtons("toggle_plot","Graph",
                                                        c("Timeline"="plot_timeline",
                                                          "Worldmap"="plot_map",
                                                          "Pie Chart"="plot_pie",
                                                          "Histogram"="plot_hist",
                                                          "Globe"="plot_globe")),
                                           hr(),
                                           conditionalPanel("input.toggle_plot=='plot_timeline'",
                                                            selectInput("tl_package", "Select package(s)", multiple = TRUE, selected = "Luminescence",
                                                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                                                            checkboxInput("tl_rmean","Rolling mean",FALSE),
                                                            conditionalPanel("input.tl_rmean==true",
                                                                             sliderInput("tl_rmean_val","Width of rolling window (days)",
                                                                                         min = 3, max = 31, value = 7)
                                                            )
                                           ),
                                           conditionalPanel("input.toggle_plot=='plot_map'",
                                                            selectInput("geo_package", "Select package", 
                                                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata"))))
                                           ),
                                           conditionalPanel("input.toggle_plot=='plot_pie'",
                                                            selectInput("pie_package", "Select package(s)", multiple = FALSE, selected = "Luminescence",
                                                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                                                            selectInput("pie_vars", "Select variable", selected = "r_arch",
                                                                        choices = c("Package version"="version",
                                                                                    "R version"="r_version",
                                                                                    "Architecture"="r_arch",
                                                                                    "OS"="r_os",
                                                                                    "Country"="country"))
                                           ),
                                           conditionalPanel("input.toggle_plot=='plot_hist'",
                                                            selectInput("hist_package", "Select package(s)", multiple = FALSE, selected = "Luminescence",
                                                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata")))),
                                                            selectInput("hist_vars", "Select variable", selected = "version",
                                                                        choices = c("Package version"="version",
                                                                                    "R version"="r_version",
                                                                                    "Architecture"="r_arch",
                                                                                    "OS"="r_os",
                                                                                    "Country"="country"))
                                           ),
                                           conditionalPanel("input.toggle_plot=='plot_globe'",
                                                            div(id = "globe_slider", 
                                                              sliderInput("globe_scale", "Data scaling (%)", 0, 200, 100, 1)
                                                            ),
                                                            tooltip(refId = "globe_slider", "For finer adjustment of the slider you can use the left and right arrow key on your keyboard!"),
                                                            selectInput("globe_package", "Select package", 
                                                                        choices = gsub("stats_","", gsub(".Rdata","",list.files("./data/", pattern = "*.Rdata"))))
                                           ),
                                           actionButton("ab_plot","  Redraw plot", class = "btn-primary")
                              ),
                              mainPanel(
                                tags$div(id="plot_wrapper", align="center",
                                         conditionalPanel("input.toggle_plot=='plot_timeline'",
                                                          # PLOT 1
                                                          helpText(HTML("<center><h4><b>R</b> package downloads by date</h4>")),
                                                          htmlOutput("plot_timeline")
                                         ),
                                         conditionalPanel("input.toggle_plot=='plot_map'",
                                                          # PLOT 2
                                                          helpText(HTML("<center><h4>World map of <b>R</b> package downloads</h4>")),
                                                          htmlOutput("plot_map")
                                         ),
                                         conditionalPanel("input.toggle_plot=='plot_pie'",
                                                          # PLOT 3
                                                          helpText(HTML("<center><h4>Pie chart <b>R</b> package download statistics</h4>")),
                                                          htmlOutput("plot_pie")
                                         ),
                                         conditionalPanel("input.toggle_plot=='plot_hist'",
                                                          # PLOT 4
                                                          helpText(HTML("<center><h4>Histogram <b>R</b> package download statistics</h4>")),
                                                          htmlOutput("plot_hist")
                                         ),
                                         conditionalPanel("input.toggle_plot=='plot_globe'",
                                                          # PLOT 5
                                                          helpText(HTML("<center><h4>WebGL Globe <b>R</b> package download statistics</h4>")),
                                                          globeOutput("plot_globe")
                                                          ),
                                         htmlOutput("info_timeline")
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

