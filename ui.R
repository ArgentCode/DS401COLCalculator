library(shinycustomloader)
library(leaflet)
library(shiny)
library(shinythemes)
library(shinydashboard)
library(shinyWidgets)
library(bslib)
library(knitr)
library(tidyverse)
library(plotly)
library(readxl)
library(mapview)
library(ggplot2)
library(sp)
library(gstat)
library(RMySQL)
library(plainview)

navbarPage(
  "University Cost of Living Calculator",
  
  # Page 1: University Cost
  tabPanel("Costs",
           #theme = shinytheme("lumen"),
           
           fluidPage(
             theme = shinytheme("sandstone"), # possible dashboard themes: paper, simplex, sandstone, yeti,
             chooseSliderSkin("Flat", color = "#1884bf"), #slider theme
             
             
             sidebarPanel(
               # Input: select university
               selectInput(
                 "selected_univerity", 
                 "Select a University",
                 unique(university_data$University), 
                 selected = "Iowa State University"
               ), 
               
               # Input: Owns A Car?
               materialSwitch(inputId = "car_Owner",
                              label = "Car Owner",
                              value = TRUE,
                              status = "info",
                              inline = FALSE,
                              width = NULL),
               
               # Input: Miles Driven
               sliderInput("miles",
                           "Expected Yearly Milage",
                           min = 0, max = 20000,
                           value = 15000),
               
               # Input: Miles Per Gallon
               sliderInput("mpg",
                           "Miles Per Gallon:",
                           min =10, max = 60,
                           value = 30),
              
               tableOutput("table"),
               
               # Input: Grant
               sliderInput("grant",
                           "Monthly Stipend",
                           min = 0, max = 4800,
                           value = 0)
             ),
             
             mainPanel(
               #Selected University
               
               #Map
               card(max_height = 350, plotlyOutput("distPlot")),
               
               #Pi chart
               card(max_height = 250, card_header("Overall Costs"), plotOutput("pi_chart")),
               
               #Histograms
               layout_columns(
                 card(max_height = 300, card_header("Rent"), plotOutput("apartment_chart")),
                 card(max_height = 300, card_header("Food"), plotOutput("food_chart")),
                 card(max_height = 300, card_header("Gas"), plotOutput("gas_prices"))
              ),
               
              #Stipend
               card(max_height = 200, card_header("Stipend Coverage"), plotOutput("grantCovered"))
             ))),
  
  # Page 2: Comparing Universities 
  tabPanel("Comparing",
           fluidPage( 
             sidebarPanel(
               # Input: select university 1
               selectInput(
                 "selected_univerity1", 
                 "University 1",
                 unique(university_data$University), 
                 selected = "Iowa State University"
               ),
               
               # Input: select university 2
               selectInput(
                 "selected_univerity2", 
                 "University 2",
                 unique(university_data$University), 
                 selected = "Iowa State University"
               )),
             
             mainPanel(
               # Output Charts
               layout_columns(
                 card(card_header(plotOutput("compare1"))),
                 card(card_header(plotOutput("compare2")))
               ),
               
               card(card_header(max_width = 300, plotOutput("compare3")))
             )
           )),
  
  
  # Page 3: Charts
  tabPanel("More Analysis", fluidPage( 
    mainPanel( 
      card(card_header(leafletOutput("mapplot"))),
      #includeMarkdown("moreAnalysis.Rmd") # Was messing up the formatting
      includeHTML("moreAnalysis.html")
    )
  )),
  
  tabPanel("Works Cited",  fluidPage( 
    mainPanel( 
      includeMarkdown("WorksCited.Rmd")
      
      )
    )
    )
)
