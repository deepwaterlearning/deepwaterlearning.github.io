library(shiny)

currentTabPanel = "graph"

shinyUI( 
  fluidPage(
    titlePanel("Life Expectancy Explorer"),
    sidebarLayout(
      sidebarPanel(
        conditionalPanel(
          condition = 'input.tab_views == "main_plot"',
          helpText("Create gender life expectancy graphs 
               with information from The World Bank's DataBank."),
          checkboxGroupInput("gender_group",label = "Choose gender(s) to display",
                             choices = list("Female" = 1, "Male" = 2),
                             selected = 1
            
          ),
          h5("Number of countries selected for box plot: "),
          h5("Number of countries selected for linear plot: "),
          radioButtons("radio", label = "Choose min/max values to display",
                       choices = list("Min" = 1, "Max" = 2),
                       selected = 1
          )
        ),
        conditionalPanel(
          condition = 'input.tab_views == "box_config"',
          helpText("Select countries to display in the box plot.")
        ),
        conditionalPanel(
          condition = 'input.tab_views == "linear_config"',
          helpText("Select countries to display in the linear plot.")
        )
        
    ),
    mainPanel(
      tabsetPanel(
        id = 'tab_views',
        selected = NULL,
        tabPanel('Plot', helpText("Plots go here."), value = 'main_plot'),
        tabPanel('Countries for Boxplot', helpText("Countries configuration for boxplot goes here."), value = 'box_config'),
        tabPanel('Countries for Linear', helpText("Countries configuration for linear goes here."), value = 'linear_config')         
      )
      
#      plotOutput("map")
    ) # mainPanel
    ) # sidebarLayout
))