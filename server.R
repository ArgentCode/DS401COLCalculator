library(tidyverse)
library(WDI)
library(leaflet)
library(sf)
library(rnaturalearthdata)
library(gt)
library(glue)
library(plotly)
library(readxl)
library(readr)
library(mapview)
library(ggplot2)
library(sp)
library(gstat)
library(RMySQL)
library(plainview)
library(readr)
library(dplyr)
library(readxl)
library(reshape2)

source("data-processing.R", local = TRUE)

function(input, output, session){
  
  # Map
  output$distPlot <- renderPlotly({
    dat <- data.frame(university_data) %>% 
      rename(Latitude = 'uni_lat', Longitude = 'uni_long', FixedName = pretty_name, CityPop = city_pop)
    
    # geo styling
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showland = TRUE,
      landcolor = toRGB("gray96"),
      subunitcolor = toRGB("gray75"),
      countrycolor = toRGB("gray75"),
      countrywidth = 0.5,
      subunitwidth = 0.5
    )
    
    fig <- plot_geo(dat, lat = ~Latitude, lon = ~Longitude)
    fig <- fig %>% add_markers(
      text = ~paste(University, FixedName, paste0("City Population: ", prettyNum(CityPop, big.mark = ",", scientific = FALSE)), sep="\n"),
      symbol = I("circle"), size = I(8), hoverinfo = "text", color="#ed624a", colors="#ed624a"
    )
    fig <- fig %>% layout(
      showlegend = F,
      title = 'US College Towns<br />(Hover for info)', geo = g
    )
    
    ggplotly(fig)
  })
  
  
  #Data Table
  output$table <- renderTable({
    
    # Relevant Inputs
    which_university <- input$selected_univerity
    miles_driven <- input$miles
    mpg <- input$mpg
    carOwner <- input$car_Owner
    
    #Create the table
    Uni_data <- university_data %>%  
      filter(University == which_university) %>% 
      mutate(total_Gas = Gas * miles_driven / mpg/12) %>% 
      select(pretty_name, zip, appartment_mean_cost, Appartment_Min, Appartment_Max, Monthly_food, Car_Maintenance, total_Gas)
    
    if(carOwner){
      average <- round(Uni_data$appartment_mean_cost+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
      min <- round(Uni_data$Appartment_Min +Uni_data$Monthly_food + Uni_data$total_Gas + 66)
      max <- round(Uni_data$Appartment_Max +Uni_data$Monthly_food + Uni_data$total_Gas + 66)
      range = glue("{min} - {max}") 
      gasCost <- round(Uni_data$total_Gas)
      maintenanceCost <- 66
    }
    else{
      average <- round(Uni_data$appartment_mean_cost+Uni_data$Monthly_food)
      min <- round(Uni_data$Appartment_Min +Uni_data$Monthly_food)
      max <- round(Uni_data$Appartment_Max +Uni_data$Monthly_food)
      range = glue("{min} - {max}") 
      gasCost  = 0
      maintenanceCost = 0
    }
    
    data <- c("Range","Average Cost", "Breakdown: ", "Rent", "Food", "Gas", "Car Maintenance")
    values <- c(range, average, " ", round(Uni_data$appartment_mean_cost), round(Uni_data$Monthly_food), gasCost, maintenanceCost)
    Presentable_data <- data.frame(data, values)
    
    tab <- gt(data = Presentable_data)
    tab_header(tab, title = which_university, subtitle = glue("{Uni_data$pretty_name} {Uni_data$zip}"))
    
  })
  
  filterdData <- reactive({
    which_university <- input$selected_univerity
    miles_driven <- input$miles
    mpg <- input$mpg
    
    data <- university_data %>%  
      mutate(total_Gas = round(Gas * miles_driven / mpg/12), 2) %>% 
      select(University, appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)
    data
  })
  
  # Car Owner data
  carOwnerData <- reactive({
    which_university <- input$selected_univerity
    miles_driven <- input$miles
    mpg <- input$mpg
    
    data <- university_data %>%  
      filter(University == which_university) %>% 
      mutate(total_Gas = round(Gas * miles_driven / mpg/12), 2) %>% 
      select(appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)%>% 
      pivot_longer(everything()) %>% 
      filter(!grepl("^(Total|Remaining)", name))
    
    data
  })
  
  # non-Car Owner Data
  notcarOwner  <- reactive({ 
    nonCarData <- university_data %>%  
      filter(University == which_university) %>% 
      select(appartment_mean_cost, Monthly_food)%>% 
      pivot_longer(everything()) %>% 
      filter(!grepl("^(Total|Remaining)", name))
    
    nonCarData
  })
  
  # pi chart: shows overall cost of living
  output$pi_chart <- renderPlot({
    which_university <- input$selected_univerity
    
    # Include Gas and Car Maintenance
    if(input$car_Owner){ 
      miles_driven <- input$miles
      mpg <- input$mpg
      
      pieData <- university_data %>%  
        filter(University == which_university) %>% 
        mutate(total_Gas = round(Gas * miles_driven / mpg/12), 2) %>% 
        select(appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))
      
      ggplot(data = pieData, aes(x = "", y = value, fill = name)) +
        geom_col() +
        coord_polar("y", start = 0) +
        geom_text(aes(label = value),
                  position = position_stack(vjust = 0.7)) +
        theme_void() +
        guides(fill = guide_legend(title = "Monthly Expenses")) +
        labs(x = "Monthly Expenses",
             y = "Cost (in dollars)" #, title = "Cost of Living Pi Chart"
        ) +
        scale_fill_manual(labels = c("Rent", "Car Maintenance", "Food", "Gas"), values=c("#1884bf", "#ed624a", "#e79f00", "#f0e441"))
    }
    
    # Exclude Gas and Car Maintenance
    else{
      
      pieData <- university_data %>%  
        filter(University == which_university) %>% 
        select(appartment_mean_cost, Monthly_food)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))

      ggplot(data = pieData, aes(x = "", y = value, fill = name)) +
        geom_col() +
        coord_polar("y", start = 0) +
        geom_text(aes(label = value),
                  position = position_stack(vjust = 0.7)) +
        theme_void() +
        guides(fill = guide_legend(title = "Monthly Expenses")) +
        labs(x = "Monthly Expenses",
             y = "Cost (in dollars)" #, title = "Pi Chart of Cost of Living"
        ) +
        scale_fill_manual(labels = c("Rent", "Food"),values=c("#1884bf","#e79f00")) 
    }
    
    
  })
  
  
  # Histogram data
  HistogramData <- reactive({
    which_university <- input$selected_univerity
    Price <- university_data %>%  
      filter(University == which_university)
    Price
  })
  
  # Apartments
  output$apartment_chart <- renderPlot({
    Value <- HistogramData()$appartment_mean_cost
    
    ggplot(university_data, aes(x = appartment_mean_cost)) +
      geom_histogram( fill= "#A1D0EA", bins=20) +
      geom_vline(xintercept=Value, color="red") +
      theme_classic() +
      labs(x = "Monthly Rent",
           y = "count", 
           subtitle = "The red line marks where the selected \n university falls on the distribution \n for all universities.")
  })
  
  # Food
  output$food_chart <- renderPlot({
    Value <- HistogramData()$Monthly_food
    
    ggplot(university_data, aes(x = Monthly_food)) +
      geom_histogram( fill= "#FFF157", bins=20) +
      geom_vline(xintercept=Value, color="red") +
      theme_classic() +
      labs(x = "Monthly Food Cost",
           y = "count", 
           subtitle = "The red line marks where the selected \n university falls on the distribution \n for all universities.")
  })
  
  
  # Gas
  output$gas_prices <- renderPlot({
    Value <- HistogramData()$Gas
    
    ggplot(university_data, aes(x = Gas)) +
      geom_histogram( fill= "#f5c77e", bins =20) +
      geom_vline(xintercept=Value, color="red") +
      theme_classic() +
      labs(x = "Cost of Regular Gas (per gallon)",
           y = "count", 
           subtitle = "The red line marks where the selected \n university falls on the distribution \n for all universities.")
  })
  
  
  # Grant Coverage
  output$grantCovered <- renderPlot({
    which_university <- input$selected_univerity
    carOwner <- input$car_Owner
    
    # Filtered Data
    miles_driven <- input$miles
    mpg <- input$mpg
    grant <- input$grant
    
    # Include Gas and Car Maintenance
    if(carOwner){ 
      #Data
      carOwnerData <- carOwnerData()
      
      
      # Chart
      total_cost <- sum(carOwnerData$value)
      covered <- min(total_cost , grant)
      leftover <- total_cost - covered
      
      df <- tibble(value = c(leftover, covered),
                       name = c("after grant", "covered"),
                       something = c("", ""))
      
      ggplot(data=df, aes(fill=name, y=value, x=something), width=0.5) +
        geom_bar( position="stack", stat="identity") +
        labs(x = "Coverage",
             y = "Amount in Dollars" #title = "Amount Covered"
        ) +
        scale_fill_manual(labels = c( "Not Covered By Stipend", "Covered"), values=c("#ed624a", "#A1D0EA")) +
        theme_minimal() +
        geom_text(aes(label = value), size = 3, hjust = 2, vjust = 3, position = "stack")+
        coord_flip()
      
    }
    
    # Exclude Gas and Car Maintenance
    else{
      # Data
      nonCarData <- university_data %>%  
        filter(University == which_university) %>% 
        select(appartment_mean_cost, Monthly_food)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))
      
      # Charts
      total_cost <- sum(nonCarData$value)
      covered <- min(total_cost , grant)
      leftover <- total_cost - covered
      
      df <- tibble(value = c(leftover, covered),
                       name = c("after grant", "covered"),
                       something = c("", ""))
      
      ggplot(data=df, aes(fill=name, y=value, x=something)) +
        geom_bar( position="stack", stat="identity") +
        labs(x = "Coverage", y = "Amount in Dollars") +
        scale_fill_manual(labels = c( "Not Covered By Stipend", "Covered"), values=c("#ed624a", "#A1D0EA")) +
        theme_minimal() +
        geom_text(aes(label = value), size = 3, hjust = 2, vjust = 3, position = "stack")+
        coord_flip()
    }
    
    
  })
  
  
  # Find Max Apartment Cost
  # Compare Helper function 
  MaxAppartmentCost <- reactive({
    which_university <- input$selected_univerity2
    which_university2 <- input$selected_univerity1
    
    # Prices for University 1
    Price1 <- university_data %>%  
      filter(University == which_university)
    
    # Prices for University 2
    Price2 <- university_data %>%  
      filter(University == which_university2)
    
    # limit the height of the chart
    MaxCost <- max(Price1$appartment_mean_cost, Price2$appartment_mean_cost) + 20
    
    MaxCost
  })
  
  # Compare 1
  output$compare1 <-renderPlot({
    which_university <- input$selected_univerity1
    max <- MaxAppartmentCost() #the max between university 1 and univerity 2
    
    budget_pie <- filterdData() %>%  
      filter(University == which_university) %>% 
      select(appartment_mean_cost, Monthly_food, total_Gas)%>% 
      pivot_longer(everything()) %>% 
      filter(!grepl("^(Total|Remaining)", name))
    
    # Bar Chart for University 1
    ggplot(data = budget_pie, aes(x = name, y = value, fill = name)) +
      geom_bar(stat="identity") +
      geom_text(aes(label=value), vjust=1.6, color="black",
                position = position_dodge(0.9), size=3.5) +
      labs(x = "Monthly Expenses",
           y = "Cost (in dollars)",
           title = which_university) +
      scale_x_discrete(labels=c("Rent", "Food", "Gas")) + 
      scale_fill_manual(labels = c("Rent", "Food", "Gas"), values=c("#A1D0EA", "#ed624a", "#f0e441")) +
      coord_cartesian(ylim = c(0,max)) + 
      theme_minimal() 
  })
  

  # Compare 2
  output$compare2 <-renderPlot({
    which_university <- input$selected_univerity2
    max <- MaxAppartmentCost() #the max between university 1 and univerity 2
    
    budget_pie <- filterdData() %>%  
      filter(University == which_university) %>% 
      select(appartment_mean_cost, Monthly_food, total_Gas)%>% 
      pivot_longer(everything()) %>% 
      filter(!grepl("^(Total|Remaining)", name))
  
    # Bar Chart for University 2
    ggplot(data = budget_pie, aes(x = name, y = value, fill = name)) +
      geom_bar(stat="identity") +
      geom_text(aes(label=value), vjust=1.6, color="black",
                position = position_dodge(0.9), size=3.5) +
      labs(x = "Monthly Expenses",
           y = "Cost (in dollars)",
           title = which_university) +
      scale_x_discrete(labels=c("Rent", "Food", "Gas")) + 
      scale_fill_manual(labels = c("Rent", "Food", "Gas"), values=c("#A1D0EA", "#ed624a", "#f0e441")) +
      coord_cartesian(ylim = c(0, max)) + 
      theme_minimal() 
  })
  
  output$compare3 <- renderPlot({
    which_university1 <-  input$selected_univerity1
    which_university2 <-  input$selected_univerity2
    # converting forms 
    value1 = as.numeric(rental_prices[[which_university1]])
    value2 = as.numeric(rental_prices[[which_university2]])
    
    # Create a side-by-side boxplot and removing erroneous terms
    boxplot(value1[value1 > 0], value2[value2 > 0],
            main="Comparison of Rental prices",
            ylab= "Price for studio/1 bed apartment",
            names = c(which_university1, which_university2))
  })
  
  
  #Map View 
  repInput <- reactive({
    if(input$car_Owner){
      miles_driven <- input$miles
      mpg <- input$mpg 
      maintenanceCost = 66
    }
    else{
      miles_driven <- 0
      mpg <- 7
      maintenanceCost = 0
    }
    total_data <- university_data %>%  mutate(avg_cost = Gas * miles_driven / mpg / 12 + maintenanceCost + appartment_mean_cost + Monthly_food)  %>% mutate(info = glue("{University}\n ${avg_cost}"))
    mapviewOptions(legend.pos= "bottomright")
    mapview(total_data, xcol = "uni_long", ycol = "uni_lat", crs = 4269, grid = FALSE, zcol= "avg_cost", alpha = 0.5, label = "info")
  })
  output$mapplot <- renderLeaflet({
    repInput()@map %>% setView(-96, 39.1, zoom = 3)
  })
  
}
