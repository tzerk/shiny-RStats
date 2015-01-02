# load libraries
library(Luminescence)
library(googleVis)
library(plyr)
library(data.table)
library(shiny)

shinyServer(function(input, output, session) {
  
  output$plot_timeline<- renderGvis({
    df_Lum<- as.data.frame(table(stats_Luminescence$date))
    df_numOSL<- as.data.frame(table(stats_numOSL$date))
    
    df<- rbind(transform(df_Lum, package="Luminescence"), transform(df_numOSL, package="numOSL"))
    df<- transform(df, Title=NA, Annotation=NA)
    colnames(df)<- c("Date", "Value", "Package", "Title", "Annotation")
    
    gvisAnnotationChart(df, datevar="Date",
                        numvar="Value", idvar="Package",
                        titlevar="Title", annotationvar="Annotation",
                        options=list(displayAnnotations=TRUE,
                                     legendPosition='newRow',
                                     width=600, height=350))
  })
  
  output$plot_map<- renderGvis({
    df<- as.data.frame(table(get(paste0("stats_",input$geo_package))$country))
    gvisGeoChart(df, locationvar="Var1", colorvar="Freq",
                        options=list(projection="kavrayskiy-vii",
                                     width=600, height=350))
  })
  
  output$plot_pie<- renderGvis({
    df<- arrange(as.data.frame(table(subset(get(paste0("stats_",input$geo_package)), select = input$pie_vars))), Freq, Var1)
    gvisPieChart(df,
                 options=list(width=600, height=350))
    
  })
  
  output$plot_hist<- renderGvis({
    df<- arrange(as.data.frame(table(subset(get(paste0("stats_",input$geo_package)), select = input$hist_vars))), Var1, Freq)
    gvisColumnChart(df, option=list())
  })
  
  output$dt_rawdata<- renderDataTable({
    get(paste0("stats_",input$dt_package))
  })
})