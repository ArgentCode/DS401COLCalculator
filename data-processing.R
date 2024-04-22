library(readr)
library(tidyverse)
library(dplyr)

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
         Car_Maintenance)

rental_prices <-read_csv("https://raw.githubusercontent.com/ArgentCode/DS401COLCalculator/main/rentals.csv", show_col_types = FALSE)
rental_prices = rental_prices[-1, ]
