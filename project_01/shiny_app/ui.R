library(shiny)

shinyUI( 
  fluidPage(
    titlePanel("Life Expectancy Explorer"),
    sidebarLayout(
      sidebarPanel(
        helpText("Create gender life expectancy graphs 
               with information from The World Bank's DataBank."),
        selectInput("var", 
                  label = "Choose gender(s) to display",
                  choices = c("Female", "Male"),
                  selected = "Female",
                  multiple = TRUE),
      sliderInput("range",
                  label = "Range of interest:",
                  min=0, max=100,value=c(0,100))
    ),
    mainPanel(plotOutput("map"))
    )
))