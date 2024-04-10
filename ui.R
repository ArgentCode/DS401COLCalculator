#
# DS 401 Team 6: College Town Cost of Living Calculator
# 
# Sponsor: Dr. Ulrike Genschel
# Instructor: Adisak Sukul
# 
# Team Members: Stephen Cooper, Vanessa Whitehead, Craig Orman, Gabriel Love
#
#

# Define UI for application

library("shinycustomloader")
library("leaflet")
library(shiny)
library(shinythemes)
library(shinydashboard)
library(shinyWidgets)

navbarPage(
  "University Cost of Living Calculator",
  theme = shinytheme("flatly"),
  
  # Page 1: University Cost
  tabPanel("Costs",
           fluidPage( 
             
             # Input: Owns A Car?
             div(
               materialSwitch(inputId = "car_Owner",
                              label = "Car Owner",
                              value = TRUE,
                              status = "info",
                              inline = FALSE,
                              width = NULL),
               style = "position:relative;z-index:10000;"
             ),
             
             # Input: Miles Driven
             div(
               sliderInput("miles",
                           "Miles Driven:",
                           min = 0, max = 20000,
                           value = 15000),
               style = "position:relative;z-index:10000;"
             ),
             
             # Input: Miles Per Gallon
             div(
               sliderInput("mpg",
                           "Miles Per Gallon:",
                           min =10, max = 60,
                           value = 25),
               style = "position:relative;z-index:10000;"
             ),
             
             # Input: Grant
             div(
               sliderInput("grant",
                           "Grant",
                           min = 0, max = 20000,
                           value = 0),
               style = "position:relative;z-index:10000;"
             ),
             
             
             # Input: select university
             div(
               selectInput(
                 "selected_univerity", 
                 "Select a University",
                 unique(university_data$University), 
                 selected = "Iowa State University"
               ),style = "position:relative;z-index:10000;"
             ),
             
             # Output Charts
              plotOutput("pi_chart"),
              plotOutput("apartment_chart"),
              plotOutput("food_chart"), 
              plotOutput("gas_prices")
             
             )
  ),
  
  # Page 2: Comparing Universities 
  tabPanel("Comparing",
           fluidPage( 
             # Input: select university 1
             div(
               selectInput(
                 "selected_univerity1", 
                 "University 1",
                 unique(university_data$University), 
                 selected = "Iowa State University"
               ),
               style = "position:relative;z-index:10000;"
             ), 
             
             # Input: select university 2
             div(
               selectInput(
                 "selected_univerity2", 
                 "University 2",
                 unique(university_data$University), 
                 selected = "Iowa State University"
               )
             ),
             
             # Output Charts
             plotOutput("compare1"), 
             plotOutput("compare2")
           )
  ),
  
  
  # Page 3: Charts
  tabPanel("More Analysis")
  
)
