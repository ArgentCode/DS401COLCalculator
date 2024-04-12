library("tidyverse")
library("WDI")
library("leaflet")
library("sf")
library("rnaturalearthdata")
library("gt")
library("glue")


source("data-processing.R", local = TRUE)

function(input, output, session){
  
  #Data 
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
      select(`pretty name`, zip, appartment_mean_cost, `Appartment Min`, `Appartment Max`, Monthly_food, Car_Maintenance, total_Gas)
    
    if(carOwner){
      average <- round(Uni_data$appartment_mean_cost+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
      min <- round(Uni_data$`Appartment Min`+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
      max <- round(Uni_data$`Appartment Max`+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
      range = glue("{min} - {max}") 
      gasCost <- round(Uni_data$total_Gas)
      maintenanceCost <- 66
    }
    else{
      average <- round(Uni_data$appartment_mean_cost+Uni_data$Monthly_food)
      min <- round(Uni_data$`Appartment Min`+Uni_data$Monthly_food)
      max <- round(Uni_data$`Appartment Max`+Uni_data$Monthly_food)
      range = glue("{min} - {max}") 
      gasCost  = 0
      maintenanceCost = 0
    }
    
    data <- c("Range","Average Cost", "Breakdown: ", "Rent", "Food", "Gas", "Car Maintenance")
    values <- c(range, average, " ", round(Uni_data$appartment_mean_cost), round(Uni_data$Monthly_food), gasCost, maintenanceCost)
    Presentable_data <- data.frame(data, values)
    
    tab <- gt(data = Presentable_data)
    tab_header(tab, title = which_university, subtitle = glue("{Uni_data$`pretty name`} {Uni_data$zip}"))
    
  })
  
  
  # pi chart - overall cost of living
  output$pi_chart <- renderPlot({
    which_university <- input$selected_univerity
    carOwner <- input$car_Owner
    
    # Filtered Data
    miles_driven <- input$miles
    mpg <- input$mpg
    
    # Include Gas and Car Maintenance
    if(carOwner){ 
      budget_pie <- university_data %>%  
        filter(University == which_university) %>% 
        mutate(total_Gas = round(Gas * miles_driven / mpg/12), 2) %>% 
        select(appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))
      
      ggplot(data = budget_pie, aes(x = "", y = value, fill = name)) +
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
      budget_pie <- university_data %>%  
        filter(University == which_university) %>% 
        select(appartment_mean_cost, Monthly_food)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))
      
      ggplot(data = budget_pie, aes(x = "", y = value, fill = name)) +
        geom_col() +
        coord_polar("y", start = 0) +
        geom_text(aes(label = value),
                  position = position_stack(vjust = 0.7)) +
        theme_void() +
        guides(fill = guide_legend(title = "Monthly Expenses")) +
        labs(x = "Monthly Expenses",
             y = "Cost (in dollars)", #title = "Pi Chart of Cost of Living"
        ) +
        scale_fill_manual(labels = c("Rent", "Food"),values=c("#1884bf","#e79f00")) 
    }
    
    
  })
  
  # Apartments
  output$apartment_chart <- renderPlot({
    which_university <- input$selected_univerity
    Price <- university_data %>%  
      filter(University == which_university)
    
    Value <- Price$appartment_mean_cost
    
    ggplot(university_data, aes(x = appartment_mean_cost)) +
      geom_histogram( fill= "#A1D0EA") +
      geom_vline(xintercept=Value, color="red") +
      theme_classic() +
      labs(x = "Monthly Rent",
           y = "count", 
           subtitle = "The red line marks where the selected \n university falls on the distribution \n for all universities.")
  })
  
  # Food
  output$food_chart <- renderPlot({
    which_university <- input$selected_univerity
    foodPrice <- university_data %>%  
      filter(University == which_university)
    
    Value <- foodPrice$Monthly_food
    
    ggplot(university_data, aes(x = Monthly_food)) +
      geom_histogram( fill= "#FFF157") +
      geom_vline(xintercept=Value, color="red") +
      theme_classic() +
      labs(x = "Monthly Food Cost",
           y = "count", 
           subtitle = "The red line marks where the selected \n university falls on the distribution \n for all universities.")
  })
  
  
  # Gas
  output$gas_prices <- renderPlot({
    which_university <- input$selected_univerity
    Price <- university_data %>%  
      filter(University == which_university)
    
    Value <- Price$Gas
    
    ggplot(university_data, aes(x = Gas)) +
      geom_histogram( fill= "#f5c77e") +
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
      budget_pie <- university_data %>%  
        filter(University == which_university) %>% 
        mutate(total_Gas = round(Gas * miles_driven / mpg/12), 2) %>% 
        select(appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))
      
      # Chart
      total_cost <- sum(budget_pie$value)
      covered <- min(total_cost , grant)
      leftover <- total_cost - covered
      
      df <- data_frame(value = c(leftover, covered),
                       name = c("after grant", "covered"),
                       something = c("", ""))
      
      ggplot(data=df, aes(fill=name, y=value, x=something)) +
        geom_bar( position="stack", stat="identity") +
        labs(x = "Coverage",
             y = "Amount in Dollars", #title = "Amount Covered"
        ) +
        scale_fill_manual(labels = c( "Left Over", "Covered"), values=c("#ed624a", "#A1D0EA")) +
        theme_minimal() +
        geom_text(aes(label = value), size = 3, hjust = 2, vjust = 3, position = "stack")+
        coord_flip()
      
    }
    
    # Exclude Gas and Car Maintenance
    else{
      # Data
      budget_pie <- university_data %>%  
        filter(University == which_university) %>% 
        select(appartment_mean_cost, Monthly_food)%>% 
        pivot_longer(everything()) %>% 
        filter(!grepl("^(Total|Remaining)", name))
      
      # Charts
      total_cost <- sum(budget_pie$value)
      covered <- min(total_cost , grant)
      leftover <- total_cost - covered
      
      df <- data_frame(value = c(leftover, covered),
                       name = c("after grant", "covered"),
                       something = c("", ""))
      
      ggplot(data=df, aes(fill=name, y=value, x=something)) +
        geom_bar( position="stack", stat="identity") +
        labs(x = "Coverage",
             y = "Amount in Dollars", #title = "Amount Covered"
        ) +
        scale_fill_manual(labels = c( "Left Over", "Covered"), values=c("#ed624a", "#A1D0EA")) +
        theme_minimal() +
        geom_text(aes(label = value), size = 3, hjust = 2, vjust = 3, position = "stack")+
        coord_flip()
    }
    
    
  })
  
  
  # Compare 1
  output$compare1 <-renderPlot({
    which_university <- input$selected_univerity1
    which_university2 <- input$selected_univerity2
    
    # Filtered Data
    miles_driven <- 15000
    
    budget_pie <- university_data %>%  
      filter(University == which_university) %>% 
      mutate(total_Gas = Gas * miles_driven / 25/12) %>% 
      select(appartment_mean_cost, Monthly_food, total_Gas)%>% 
      pivot_longer(everything()) %>% 
      filter(!grepl("^(Total|Remaining)", name))
    
    # Prices for University 1
    Price1 <- university_data %>%  
      filter(University == which_university)
    
    # Prices for University 2
    Price2 <- university_data %>%  
      filter(University == which_university2)
    
    # limit the height of the chart
    Max <- max(Price1$appartment_mean_cost, Price2$appartment_mean_cost) + 20
    
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
      coord_cartesian(ylim = c(0,Max)) + 
      theme_minimal() 
  })
  
  # Compare 2
  output$compare2 <-renderPlot({
    which_university <- input$selected_univerity2
    which_university2 <- input$selected_univerity1
    
    miles_driven <- 15000
    
    budget_pie <- university_data %>%  
      filter(University == which_university) %>% 
      mutate(total_Gas = Gas * miles_driven / 25/12) %>% 
      select(appartment_mean_cost, Monthly_food, total_Gas)%>% 
      pivot_longer(everything()) %>% 
      filter(!grepl("^(Total|Remaining)", name))
    
    # Prices for University 2
    Price1 <- university_data %>%  
      filter(University == which_university)
    
    # Prices for University 1
    Price2 <- university_data %>%  
      filter(University == which_university2)
    
    # limit the height of the chart
    Max <- max(Price1$appartment_mean_cost, Price2$appartment_mean_cost) + 20
    
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
      coord_cartesian(ylim = c(0,Max)) + 
      theme_minimal() 
  })
  
}
