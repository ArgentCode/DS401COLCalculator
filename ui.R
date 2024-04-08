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

dashboardPage(
  
    #Dashboard Header
    dashboardHeader(
      title = "College Town Cost of Living Dashboard", titleWidth = 300
        
      
      
    ),
  
  
  
    #Dashboard Sidebar
    dashboardSidebar(
      sidebarMenu(
        
        #sidebar options for the Front Page
        menuItem("Blank Tab", tabName = "blank"),
        
        
        
        menuItem("Dataset", tabName = "dataset")
      )
      
    ),
  
  
  
  
    # Dashboard Body
    dashboardBody(
      
    # All Tab Items
      
        tabItems(
          
          #tab layout of the front page
          tabItem(tabName = "blank",
                  tabBox(width = 15,
                         tabPanel("Blank Test Page", icon = icon("map"),
                                  
                    )
                  
                )
            ),
          
          #tab layout of the second page
          tabItem(tabName = "dataset",
                  tabBox(width = 15,
                    tabPanel("Full Data", dataTableOutput("datatab"), icon = icon("table")) 
                    )
            
            )
          
        )
        
    )
  
)
