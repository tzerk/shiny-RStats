# load libraries
library(Luminescence)
library(googleVis)
library(plyr)
library(data.table)
library(shiny)
library(zoo)
library(threejs)

countryCodeCoords <- read.delim("./data/coordinates.txt")

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
          "Total downloads:",paste0("'",input$tl_package,"'")," =", nrow(get(paste0("stats_",input$tl_package))))
  })
  
  output$plot_timeline<- renderGvis({
    input$ab_plot
    isolate({
    df<- sapply(input$tl_package, function(x){ as.data.frame(table(get(paste0("stats_",x))$date)) }, simplify = F)
    
    if(input$tl_rmean==TRUE) {
      for(i in 1:length(df)) {
        df[[i]]<- as.data.frame(rollmean(zoo(df[[i]]$Freq, df[[i]]$Var1), input$tl_rmean_val))
        df[[i]]<- data.frame(Date=row.names(df[[i]]), Value=df[[i]][,1])
      }
    }
    
    df2<- data.frame()
    for(i in 1:length(df)) {
      df2<- rbind(df2, transform(df[[i]], package=input$tl_package[i]))
    }
    
    df2<- transform(df2, Title=NA, Annotation=NA)
    colnames(df2)<- c("Date", "Value", "Package", "Title", "Annotation")
    
    gvisAnnotationChart(df2, datevar="Date",
                        numvar="Value", idvar="Package",
                        titlevar="Title", annotationvar="Annotation",
                        options=list(displayAnnotations=TRUE,
                                     legendPosition='newRow',
                                     width=val$width, height=ifelse(val$width=="100%","200%",val$width/2)))
    })
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
  
  output$plot_globe<- renderGlobe({
    earth_dark<- system.file("images/world.jpg",package="threejs")
    col <- list(img=earth_dark,bodycolor="#0000ff",emissive="#0000ff",lightcolor="#9999ff")
    val <- arrange(as.data.frame(table(subset(get(paste0("stats_",input$globe_package)), select = "country"))), Var1, Freq)
    colnames(val) <- c("code", "Freq")
    val2 <- join(val, countryCodeCoords, by = "code")
    args <- c(col, list(lat = val2$lat, long = val2$lon, value = val2$Freq, atmosphere = TRUE))
    do.call("globejs", args = args)
  })
  
  output$dt_rawdata<- renderDataTable({
    setorder(get(paste0("stats_", input$dt_package)), -date)
  })
})