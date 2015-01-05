# load libraries
library(Luminescence)
library(googleVis)
library(plyr)
library(data.table)
library(shiny)
library(zoo)

shinyServer(function(input, output, session) {
  
  val<- reactiveValues(height="100%", width="100%")
  
  observeEvent(input$dim, {
    
    if(val$height=="100%" || val$width=="100%") {
      val$height<- val$width<- 0
    }
    if(abs(val$height-input$dim[2]) > 100) {
      val$height<- input$dim[2]
    }
    if(abs(val$width-input$dim[1]) > 100) {
      val$width<- input$dim[1]-100
    }
  })
  
  output$info_timeline<- renderText({
    paste("<center>Observation period:",stats_Luminescence$date[1],"to",stats_Luminescence$date[length(stats_Luminescence$date)],"<br>",
          "Total downloads: 'Luminescence' =", nrow(stats_Luminescence), "| 'numOSL' =", nrow(stats_numOSL))
  })
  
  output$plot_timeline<- renderGvis({
    df_Lum<- as.data.frame(table(stats_Luminescence$date))
    df_numOSL<- as.data.frame(table(stats_numOSL$date))
    
    if(input$tl_rmean==TRUE) {
      df_Lum<- zoo(df_Lum$Freq, df_Lum$Var1)
      df_numOSL<- zoo(df_numOSL$Freq, df_numOSL$Var1)
      df_Lum<- as.data.frame(rollmean(df_Lum, input$tl_rmean_val))
      df_numOSL<- as.data.frame(rollmean(df_numOSL, input$tl_rmean_val))
      df_Lum<- data.frame(Date=row.names(df_Lum), Value=df_Lum[,1])
      df_numOSL<- data.frame(Date=row.names(df_numOSL), Value=df_numOSL[,1])
    }
    df<- rbind(transform(df_Lum, package="Luminescence"), transform(df_numOSL, package="numOSL"))
    df<- transform(df, Title=NA, Annotation=NA)
    colnames(df)<- c("Date", "Value", "Package", "Title", "Annotation")
    
    gvisAnnotationChart(df, datevar="Date",
                        numvar="Value", idvar="Package",
                        titlevar="Title", annotationvar="Annotation",
                        options=list(displayAnnotations=TRUE,
                                     colors="['blue', 'red']",
                                     legendPosition='newRow',
                                     width=val$width, height=ifelse(val$width=="100%","200%",val$width/2)))
  })
  
  output$plot_map<- renderGvis({
    df<- as.data.frame(table(get(paste0("stats_",input$geo_package))$country))
    gvisGeoChart(df, locationvar="Var1", colorvar="Freq",
                 options=list(projection="kavrayskiy-vii",
                              width=val$width, height=val$height))
  })
  
  output$plot_pie<- renderGvis({
    df<- arrange(as.data.frame(table(subset(get(paste0("stats_",input$geo_package)), select = input$pie_vars))), Freq, Var1)
    df<- setorder(as.data.table(df), -Freq)
    gvisPieChart(df,
                 options=list(width=val$width, height=val$height))
    
  })
  
  output$plot_hist<- renderGvis({
    df<- arrange(as.data.frame(table(subset(get(paste0("stats_",input$geo_package)), select = input$hist_vars))), Var1, Freq)
    df<- setorder(as.data.table(df), -Freq)
    gvisColumnChart(df, options=list(width=val$width, height=ifelse(val$width=="100%","200%",val$width/2)))
  })
  
  output$dt_rawdata<- renderDataTable({
    setorder(get(paste0("stats_", input$dt_package)), -date)
  })
})