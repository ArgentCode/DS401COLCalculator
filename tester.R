library("ggplot2")
library("tidyverse")
library("dplyr")
library(shadowtext)
library(gt)
library(glue)
library("reactable")
library(magrittr)
library(knitr)
library(formattable)
library(mapview)
library(RColorBrewer)

university_data <- read_csv("universities.csv")

if(TRUE){
  budget_pie <- university_data %>%  
    filter(University == "Iowa State University") %>% 
    select(appartment_mean_cost, Monthly_food, Car_Maintenance, gas_per_month)%>% 
    pivot_longer(everything()) %>% 
    filter(!grepl("^(Total|Remaining)", name))
  
  ggplot(data = budget_pie, aes(x = "", y = value, fill = name)) +
    geom_col() +
    coord_polar("y", start = 0) +
    geom_text(aes(label = value),
              position = position_stack(vjust = 0.7)) +
    theme_void() +
    guides(fill = guide_legend(title = "Expenses")) +
    scale_fill_manual(labels = c("Apartment", "Car Maintenance", "Gas", "Food"), values=c("#F16A70", "#B1C977", "#8CDCDA", "#B4B4B4")) 
}else{
  budget_pie <- university_data %>%  
    filter(University == "Iowa State University") %>% 
    select(appartment_mean_cost, Monthly_food)%>% 
    pivot_longer(everything()) %>% 
    filter(!grepl("^(Total|Remaining)", name))
  
  ggplot(data = budget_pie, aes(x = "", y = value, fill = name)) +
    geom_col() +
    coord_polar("y", start = 0) +
    geom_text(aes(label = value),
              position = position_stack(vjust = 0.7)) +
    theme_void() +
    guides(fill = guide_legend(title = "Expenses")) +
    scale_fill_manual(labels = c("Apartment", "Food"),values=c("#B4B4B4","#8CDCDA")) 
}


foodPrice <- university_data %>%  
  filter(University == "Iowa State University")

foodieValue <- foodPrice$Monthly_food

ggplot(university_data, aes(x = Monthly_food)) +
  geom_histogram( fill= "#A1D0EA") +
  geom_vline(xintercept=foodieValue, color="red") +
  theme_classic() 
  
# default values
which_university <- "Iowa State University"
miles_driven <- 15000
mpg <- 25

budget_pie <- university_data %>%  
  filter(University == which_university) %>% 
  mutate(total_Gas = Gas * miles_driven / 25/12) %>% 
  select(appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)%>% 
  pivot_longer(everything()) %>% 
  filter(!grepl("^(Total|Remaining)", name))

ggplot(data = budget_pie, aes(x = name, y = value, fill = name)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=value), vjust=1.6, color="black",
            position = position_dodge(0.9), size=3.5) +
  labs(x = "Expenses",
       y = "Cost per Month (in dollars)",
       title = which_university) +
  scale_x_discrete(labels=c("Apartment", "Car Maintenance", "Food", "Gas")) + 
  scale_fill_manual(labels = c("Apartment", "Car Maintenance", "Food", "Gas"), values=c("#1884bf", "#d55e00", "#e79f00", "#f0e441")) +
  theme_minimal() 



# Chart
total_cost <- sum(budget_pie$value)
covered <- min(total_cost , 1000)
leftover <- total_cost - covered

df <- data_frame(value = c(leftover, covered),
                 name = c("after grant", "covered"),
                 something = c("", ""))

ggplot(data=df, aes(fill=name, y=value, x=something)) +
  geom_bar( position="stack", stat="identity", width=0.5) +
  labs(x = "Coverage",
       y = "Amount in Dollars",
       title = "Amount Covered") +
  scale_fill_manual(labels = c( "Covered", "Left Over"), values=c("#c96565", "#A1D0EA")) +
  theme_minimal() +
  geom_text(aes(label = value), size = 3, hjust = 2, vjust = 3, position = "stack")+
  coord_flip()



# Relevant Inputs for Table
which_university <- "Iowa State University"
miles_driven <- 15000
mpg <- 25
carOwner <- TRUE

#Create the table
Uni_data <- university_data %>%  
  filter(University == which_university) %>% 
  mutate(total_Gas = Gas * miles_driven / mpg/12) %>% 
  select(3, 11, 14, appartment_mean_cost, 19, 20, Monthly_food, Car_Maintenance, total_Gas)

if(carOwner){
  average <- round(Uni_data$appartment_mean_cost+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
  min <- round(Uni_data$`Appartment Min`+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
  max <- round(Uni_data$`Appartment Max`+Uni_data$Monthly_food + Uni_data$total_Gas + 66)
  range = glue("{min} - {max}") 
  gasCost <- round(Uni_data$total_Gas)
  maintenanceCost <- 66
}else{
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

tab <- kable(Presentable_data, caption = which_university)
tab

tab_header(tab, title = which_university, subtitle = glue("{Uni_data$`pretty name`} {Uni_data$zip}"))


total_data <- university_data %>%  mutate(total_cost =  appartment_mean_cost + Monthly_food)

total_data <- university_data %>%  mutate(avg_cost = Gas * miles_driven / mpg/12 + 66+ appartment_mean_cost + Monthly_food)
mapviewOptions(legend.pos= "bottomright")

mapview(total_data, xcol = "uni_long", ycol = "uni_lat", crs = 4269, grid = FALSE, zcol= "avg_cost", alpha = 0.5, label = "University") 




which_university <-"Iowa State University"
miles_driven <- 15000
mpg <- 25

data <- university_data %>%  
  mutate(total_Gas = round(Gas * miles_driven / mpg/12), 2) %>% 
  select(University, appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)

data

budget_pie <- data %>%  
  filter(University == which_university)  %>%  select(appartment_mean_cost, Monthly_food, Car_Maintenance, total_Gas)%>% 
  pivot_longer(everything()) %>% 
  filter(!grepl("^(Total|Remaining)", name))
