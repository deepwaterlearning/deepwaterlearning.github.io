# server

library(maps)
library(dplyr)
library(shiny)
library(DT)


# common 
columns_to_use = c(rep(NA, 2), rep("NULL", 2),rep(NA, 58))

# female data
female_lexp = read.csv('../data/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2.csv', 
                       header = TRUE, skip = 4, stringsAsFactors = FALSE, colClasses = columns_to_use)
female_lexp[58:60] <- NULL # get rid of empty last 3 columns
female_lexp = female_lexp[order(female_lexp$Country.Name),]
rownames(female_lexp) = female_lexp$Country.Code
country_names = female_lexp[,1:2]
rownames(country_names) = country_names$Country.Code
female_lexp[1:2] <- NULL
country_names[2] <- NULL
empty_DF <- female_lexp[rowSums(is.na(female_lexp)) == ncol(female_lexp),]
country_names = country_names[!(rownames(country_names) %in% rownames(empty_DF)),,drop=FALSE]
female_lexp = female_lexp[rowSums(is.na(female_lexp)) != ncol(female_lexp),]


# male data
male_lexp = read.csv('../data/API_SP.DYN.LE00.MA.IN_DS2_en_csv_v2.csv', 
                     header = TRUE, skip = 4, stringsAsFactors = FALSE, colClasses = columns_to_use)
male_lexp[58:60] <- NULL # get rid of empty last 3 columns
male_lexp = male_lexp[order(male_lexp$Country.Name),]
rownames(male_lexp) = male_lexp$Country.Code
male_lexp[1:2] <- NULL
male_lexp = male_lexp[rowSums(is.na(male_lexp)) != ncol(male_lexp),]


#source("/Users/intothelight/nycdatascience/R_work/shiny_apps/counties_app/helpers.R")

# centre = function(x,type){
#   switch(type,
#          mean=mean(x),
#          median=median(x))
# }
# x = rnorm(10)
# centre(x,"mean")
# centre(x, "median")

shinyServer(function(input, output) {
  
  output$box_table = DT::renderDataTable(country_names)
  
  output$linear_table = DT::renderDataTable(country_names)
  
#female_lexp = read.csv('../data/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2.csv', header = FALSE, skip = 4,stringsAsFactors = FALSE)  
#   output$map = renderPlot( {
# 
# args = switch(input$var,
#               "Percent White" = list(counties$white, "darkgreen", "% White"),
#               "Percent Black" = list(counties$black, "black", "% Black"),
#               "Percent Hispanic" = list(counties$hispanic, "darkorange", "% Hispanic"),
#               "Percent Asian" = list(counties$asian, "darkviolet", "% Asian"))
# 
# args$min = input$range[1]
# args$max = input$range[2]
# 
# do.call(percent_map, args)
#   })

  
})