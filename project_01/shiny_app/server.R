# server

library(maps)
library(dplyr)
library(mapproj)


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

# don't include indicator name/symbol, and drop 2015,2016 which are just empty
#columns_to_use = c(rep("NA", 2), rep("NULL", 2),rep(NA, 57), rep("NULL", 3))
#  [0,1] + range(4, 59) 

# read and skip non-essential data
#female_lexp = read.csv('../data/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2.csv', header = TRUE, skip = 4,stringsAsFactors = FALSE) 
#pd.read_csv('data/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2.csv', skiprows=2, header=1, usecols=columns_to_use)
#male_lexp = pd.read_csv('data/API_SP.DYN.LE00.MA.IN_DS2_en_csv_v2.csv', skiprows=2, header=1, usecols=columns_to_use)

#counties = readRDS("/Users/intothelight/nycdatascience/R_work/shiny_apps/counties_app/data/counties.rds")
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
  
female_lexp = read.csv('../data/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2.csv', header = FALSE, skip = 4,stringsAsFactors = FALSE)  
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