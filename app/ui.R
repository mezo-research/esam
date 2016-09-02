
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/

library(shiny)
library(dygraphs)
library(ggplot2)
library(dplyr)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  verticalLayout(
    
    img(src = "mezo-logo-round.png", height = 80, width = 80),
    
    titlePanel("Emergency services Allocation Modelling"),
    
    hr(),
    radioButtons("Stocks", "Select Divisions:",
                 c("All Divisions" = "Nemo_all",
                   "Eastern" = "Nemo_E",
                   "Western" = "Nemo_W")),
    tags$br(),
    sliderInput("Years", label = "Select years to plot", min = 2010, 
                max = 2015, value = c(2010, 2015), step = 1, sep = ""),
    tags$br(),
    plotOutput("plot_lf_comp_byr"),
    tags$br(),
    htmlOutput("summaryText_byr"),
    tags$br(),
    plotOutput("plot_lf_comp_ag"),
    tags$br(),
    htmlOutput("summaryText_ag"),
    
    tags$br(),
    hr(),
    dygraphOutput("catchPlot"),
    tags$br(),
    htmlOutput("summaryText_catch"),
    
    tags$br(),
    hr(),
    dygraphOutput("cpuePlot"),
    tags$br(),
    htmlOutput("summaryText_cpue"),
    
    tags$br(),
    hr(),
    leafletOutput("map"),
    tags$br(),
    htmlOutput("summaryText_map"),
    
    # tags$br(),
    # hr(),
    # tags$p(strong("Click the button to register for our pilot program.")),
    # div(),
    # tags$style(),
    # tags$a(strong("Get Mezo Flow"), class="btn btn-default", href="http://mezoresearch.com/getflow/", 
    #        style = "font-weight: 1000; line-height: 2; background-color: #f15a22"),
    # div(),
    tags$br()
    
    # plotOutput("distPlotSAM", width = "100%", height = "400px"),
    # Note: tags$br(), is equivalent to the helper function br()
  )
))
