# load libraries
library(Luminescence)
library(rCharts)
library(dplyr)
library(data.table)
library(shiny)

shinyServer(function(input, output, session) {
  
   output$text<- renderText("HELLO WORLD")
})