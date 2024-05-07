library(readr)
library(tidyverse)
library(dplyr)

#university_data <- read_csv("universities.csv", show_col_types = FALSE) %>% 
university_data <- read_csv("https://raw.githubusercontent.com/ArgentCode/DS401COLCalculator/main/universities.csv", show_col_types = FALSE) %>% 
  select(pretty_name, 
         zip, 
         appartment_mean_cost, 
         Appartment_Min, 
         Appartment_Max, 
         Monthly_food, 
         Car_Maintenance, 
         Gas, 
         uni_lat,
         uni_long,
         University,
         undergrad_pop, 
         city_pop,
         Car_Maintenance, 
         Total_Cost)

rental_prices <- read_excel("rentals.xlsx")


