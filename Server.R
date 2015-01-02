# load libraries
library(Luminescence)
library(rCharts)
library(plyr)
library(data.table)
library(shiny)

shinyServer(function(input, output, session) {
  
  output$plot_timeline<- renderChart({
    df_Lum<- as.data.frame(table(stats_Luminescence$date))
    df_numOSL<- as.data.frame(table(stats_numOSL$date))
    
    df<- merge(df_Lum, df_numOSL, by = "Var1", all = TRUE)
      
    colnames(df)<- c("Date","Luminescence", "numOSL")
    
    m1<- mPlot(x = "Date", y = c("Luminescence", "numOSL"), type = "Line", data = df)
    m1$set(pointSize = 0, lineWidth = 1)
    m1$addParams(dom = 'plot_timeline')
    return(m1)
  })
  
  output$dt_rawdata<- renderDataTable({
    get(paste0("stats_",input$dt_package))
  })
})