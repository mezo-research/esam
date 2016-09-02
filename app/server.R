
# This is the server logic for a Shiny web application:
# Snappa: Snap Assessment Demonstration Application
# http://flow.mezoresearch.com/snappa

# Load required packages:
library(shiny)
library(dygraphs)
library(ggplot2)
library(dplyr)
library(leaflet)

# Get required data:
catch_data <- read.table("nemo_catch.txt", header=TRUE)
cpue_data <- read.table("nemo_cpue.txt", header=TRUE)
spatial_data <- read.csv("nemo_spatial.csv", header = TRUE)
lf_raw <- read.csv("esam_ages.csv", header=TRUE)

# # Modify length frequency data:
# lf_raw <- mutate(lf_raw, Date = as.Date(Date))
# lf_raw <- mutate(lf_raw, Year = factor(format(Date, format="%Y")))

# Define server logic required to draw a histogram:
shinyServer(
  function(input, output) {
    
    # Draw faceted histogram of length composition by year, and species:
    output$plot_lf_comp_byr <- renderPlot({
      if (input$Stocks == "Nemo_E") {
        stocks_lf <- "Eastern"
        StocksColorScale <- c("#ff6666")
      }
      else if (input$Stocks == "Nemo_W") {
        stocks_lf <- "Western"
        StocksColorScale <- c("#009999")
      }
      else if (input$Stocks == "Nemo_all") {
        stocks_lf <- c("Eastern", "Western")
        StocksColorScale <- c("#ff6666", "#009999")
      }
      years <- input$Years[1]:input$Years[2]
      lf_data <- filter(lf_raw, Year %in% years)
      lf_data <- filter(lf_data, Division %in% stocks_lf)
      p <- ggplot(lf_data, aes(x=Total_Years, y=..density.., fill=Division)) +
        geom_histogram(binwidth=1.0, colour="white") +
        scale_fill_manual(values=StocksColorScale) + 
        facet_wrap(~ Year) +
        labs(x="Total Years in Service", y="Proportion") +
        ggtitle("Annual Years in service / Frequency") + 
        theme(panel.grid.minor = element_blank(), 
              plot.title = element_text(size = 18, face="bold", color = "darkslategrey"))
      p
    })
    
    output$summaryText_byr <- renderUI({
      if (input$Years[1] == input$Years[2]) {
        strText <- paste0("Plot for selected divisions for the year ", input$Years[1], ".", "<br/>")
      }
      else {
        strText <- paste0("Yearly plots for selected divisions for the years ",
                          input$Years[1], " to ", input$Years[2], ".", "<br/>")
      }
      strExtra <- paste0("This text can be customized to fit user requirements. The content can dynamically update ",
                         "in reponse to user input, such as interesting features of the data.")
      HTML(paste(strText, strExtra, sep = "<br/>"))
    })
    
    # Draw faceted histogram of length composition by year, and species:
    output$plot_lf_comp_ag <- renderPlot({
      if (input$Stocks == "Nemo_E") {
        stocks_lf <- "Eastern"
        StocksColorScale <- c("#ff6666")
      }
      else if (input$Stocks == "Nemo_W") {
        stocks_lf <- "Western"
        StocksColorScale <- c("#009999")
      }
      else if (input$Stocks == "Nemo_all") {
        stocks_lf <- c("Eastern", "Western")
        StocksColorScale <- c("#ff6666", "#009999")
      }
      years <- input$Years[1]:input$Years[2]
      lf_data <- filter(lf_raw, Year %in% years)
      lf_data <- filter(lf_data, Division %in% stocks_lf)
      p <- ggplot(lf_data, aes(x=Total_Years, y=..density.., fill=Division)) +
        geom_histogram(binwidth=1.0, colour="white") +
        scale_fill_manual(values=StocksColorScale) + 
        labs(x="Total Years in Service", y="Proportion") +
        ggtitle("Aggregated Years in service / Frequency") + 
        theme(panel.grid.minor = element_blank(), 
              plot.title = element_text(size = 18, face="bold", color = "darkslategrey"))
      p
    })

    output$summaryText_ag <- renderUI({
      # LF_yearSampled <-  2012
      # LF_totalSamples <- 2487
      # LF_medianForkLength <- 38.7
      # LF_medianLength <- 42.3
      if (input$Years[1] == input$Years[2]) {
        strText <- paste0("Plot for selected divisions for the year ", input$Years[1], ".", "<br/>")
      }
      else {
        strText <- paste0("Aggregated plots for selected divisions for the years ",
                          input$Years[1], " to ", input$Years[2], ".", "<br/>")
      }
      strExtra <- paste0("This text can be customized to fit user requirements, and the content can dynamically update ",
                         "in reponse to user input. Examples might include reporting on median years in service of the ",
                         "divisions in the aggregated data, the total number of people sampled, or the proportion of sampled individuals ", 
                         "that are above a critical time in service.")
      HTML(paste(strText, strExtra, sep = "<br/>"))
    })
    
    output$catchPlot <- renderDygraph({
      dygraph(catch_data, main = "Capacity of service personnel") %>%
        dySeries(c("lwr", "catch", "upr"), label = "Capacity") %>%
        dyOptions(drawGrid = input$showgrid) %>%
        dyAxis("y", label = "Capacity") %>%
        dyRangeSelector()
    })
    
    output$summaryText_catch <- renderUI({
      strText <- paste0("Capacity of service personnel history for all departments.", " The solid line represents ",
                        "the median estimate, shaded areas represent 95 percent confidence intervals.", "<br/>")
      strExtra <- paste0("This text can be customized to fit user requirements, and the content can dynamically update ",
                         "in reponse to user input. For example, the text might highlight the highest or lowest observed ",
                         "points in the time series, the average capacity, or list years in which capacity was below a certain threshold.")
      HTML(paste(strText, strExtra, sep = "<br/>"))
    })
    
    
    output$cpuePlot <- renderDygraph({
      dygraph(cpue_data, main = "Demand for service personnel") %>%
        dySeries(c("lwr", "cpue", "upr"), label = "Demand") %>%
        dyOptions(drawGrid = input$showgrid) %>%
        dyAxis("y", label = "Demand") %>%
        dyRangeSelector()
    })
    
    output$summaryText_cpue<- renderUI({
      strText <- paste0("Demand for service personnel.", " The solid line represents ", 
                        "the median estimate, shaded areas represent 95 percent confidence intervals", "<br/>")
      strExtra <- paste0("This text can be customized to fit user requirements, and the content can dynamically update ",
                         "in reponse to user input. For example, the text might highlight years in which demand increased ",
                         "above a critical reference point.")
      HTML(paste(strText, strExtra, sep = "<br/>"))
    })
    
    output$map <- renderLeaflet({
      # Use leaflet() here, and only include aspects of the map that
      # won't need to change dynamically (at least, not unless the
      # entire map is being torn down and recreated).
      leaflet(spatial_data) %>% addTiles() %>%
        fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
        # addMarkers("Latitude", "Longtitude")
        addCircleMarkers(
          lng=~Longitude, # Longitude coordinates
          lat=~Latitude, # Latitude coordinates
          clusterOptions = markerClusterOptions()
          # # radius=~(Total*0.1), # Total count
          # stroke=FALSE, # Circle stroke
          # fillOpacity=0.5, # Circle Fill Opacity
          # # Popup content
          # popup=~paste(
          #   "<b>", Total, "</b>"
          #   )
        )
    })
    
    output$summaryText_map <- renderUI({
      strText <- paste0("Map of detections for all events in the data. The map will dynamically rescale the data points ",
                        "at different zoom levels.", "<br/>")
      strBounds <- paste0("Initial map bounds are between latitude ", min(spatial_data$Latitude), " and ",
                         max(spatial_data$Latitude), ", longitude ", min(spatial_data$Longitude), " and ", 
                         max(spatial_data$Longitude), "<br/>")
      strExtra <- paste0("This text can be customized to fit user requirements, and the content can dynamically update ",
                         "in reponse to user input. For example, the text might indicate the total observations in the ",
                         "data set plotted above, or list locations with a particularly high proportion of observations.")
      HTML(paste(strText, strBounds, strExtra, sep = "<br/>"))
    })
    
    # Expression that generates a histogram. The expression is
    # wrapped in a call to renderPlot to indicate that:
    #
    #  1) It is "reactive" and therefore should re-execute automatically
    #     when inputs change
    #  2) Its output type is a plot
    
  })

