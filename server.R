#
# DS 401 Team 6: College Town Cost of Living Calculator
# 
# Sponsor: Dr. Ulrike Genschel
# Instructor: Adisak Sukul
# 
# Team Members: Stephen Cooper, Vanessa Whitehead, Craig Orman, Gabriel Love
#
#

library(shiny)
library(shinydashboard)

# Define server logic required to draw a histogram
function(input, output, session) {

  
    #full dataset output for the "dataset" page
    output$datatab <- renderDataTable(costData)
    
    
    
}
