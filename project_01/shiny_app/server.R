# server

library(maps)
library(mapproj)

counties = readRDS("/Users/intothelight/nycdatascience/R_work/shiny_apps/counties_app/data/counties.rds")
source("/Users/intothelight/nycdatascience/R_work/shiny_apps/counties_app/helpers.R")

# centre = function(x,type){
#   switch(type,
#          mean=mean(x),
#          median=median(x))
# }
# x = rnorm(10)
# centre(x,"mean")
# centre(x, "median")

shinyServer(function(input, output) {
  output$map = renderPlot( {

args = switch(input$var,
              "Percent White" = list(counties$white, "darkgreen", "% White"),
              "Percent Black" = list(counties$black, "black", "% Black"),
              "Percent Hispanic" = list(counties$hispanic, "darkorange", "% Hispanic"),
              "Percent Asian" = list(counties$asian, "darkviolet", "% Asian"))

args$min = input$range[1]
args$max = input$range[2]

do.call(percent_map, args)
  })

  
})