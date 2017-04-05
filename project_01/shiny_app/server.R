# server

library(maps)
library(dplyr)
library(shiny)
library(DT)
library(ggplot2)
library(ggthemes)
library(data.table)


source("helpers.R")


# common 
columns_to_use = c(rep(NA, 2), rep("NULL", 2),rep(NA, 58))

# female data
female_lexp = read.csv('../data/API_SP.DYN.LE00.FE.IN_DS2_en_csv_v2.csv', 
                       header = TRUE, skip = 4, stringsAsFactors = FALSE, colClasses = columns_to_use)
female_lexp[58:60] <- NULL                                    # get rid of empty last 3 columns
female_lexp = female_lexp[order(female_lexp$Country.Name),]   # alpha-order by country name
rownames(female_lexp) = female_lexp$Country.Code              # temporarily make country code row names
country_names = female_lexp[,1:2]                             # create DF of countryname/code
rownames(country_names) = country_names$Country.Code          # temporarily make country code row names
female_lexp[1:2] <- NULL                                      # drop character columns

  # find empty rows
empty_DF <- female_lexp[rowSums(is.na(female_lexp)) == ncol(female_lexp),]  
  # get rid of countries w/ no data
country_names = country_names[!(rownames(country_names) %in% rownames(empty_DF)),,drop=FALSE] 
  # drop empty data rows
female_lexp = female_lexp[rowSums(is.na(female_lexp)) != ncol(female_lexp),]


# male data
male_lexp = read.csv('../data/API_SP.DYN.LE00.MA.IN_DS2_en_csv_v2.csv', 
                     header = TRUE, skip = 4, stringsAsFactors = FALSE, colClasses = columns_to_use)
male_lexp[58:60] <- NULL # get rid of empty last 3 columns
male_lexp = male_lexp[order(male_lexp$Country.Name),]
rownames(male_lexp) = male_lexp$Country.Code
male_lexp[1:2] <- NULL
male_lexp = male_lexp[rowSums(is.na(male_lexp)) != ncol(male_lexp),]

# put female/male rownames back as column
setDT(female_lexp, keep.rownames = TRUE)[]
setnames(female_lexp, 1, "Country.Code")
setDT(male_lexp, keep.rownames = TRUE)[]
setnames(male_lexp, 1, "Country.Code")
rownames(country_names) <- NULL # causes numeric re-ordering


# centre = function(x,type){
#   switch(type,
#          mean=mean(x),
#          median=median(x))
# }
# x = rnorm(10)
# centre(x,"mean")
# centre(x, "median")

shinyServer(function(input, output) {
  
  gender_requested = "Female"
  box_countries_requested = country_names
  linear_countries_requested = country_names
  female_dataset = female_lexp
  male_dataset = male_lexp
  
  all_matrix = matrix(1L,nrow=nrow(country_names) ,ncol=2 )
  
  filtered_main_plot <- reactive({
    female_dataset %>% select(-Country.Code)
  })
  
  filtered_countries_linear <- reactive({
    
  })
  
  filtered_countries_box <- reactive({
    # bcl %>%
    #   filter(Price >= input$priceInput[1],
    #          Price <= input$priceInput[2],
    #          Type == input$typeInput,
    #          Country == input$countryInput
    #   )
  })
  
  output$box_table = DT::renderDataTable(country_names, server = FALSE,
                                         selection = list(target = 'row+column')
                                         )
  
  output$linear_table = DT::renderDataTable(country_names, server = FALSE,
                                            selection = list(target = 'row+column')
                                            )
  
  
  proxy_box_table = dataTableProxy('box_table')
  proxy_linear_table = dataTableProxy('linear_table')
  
  # Bloxplot Config Table
  observeEvent(input$selectAll_box, {
    proxy_box_table %>% selectRows(all_matrix)
  })
  
  observeEvent(input$clearAll_box, {
    proxy_box_table %>% selectRows(NULL)
  })
  
  # LinearPlot Config Table
  observeEvent(input$selectAll_linear, {
    proxy_linear_table %>% selectRows(all_matrix)
  })
  
  observeEvent(input$clearAll_linear, {
    proxy_linear_table %>% selectRows(NULL)
  })
  
  observeEvent(input$update_button, {
    print("Button activated")
  })
  
  output$main_plot <- renderPlot({
    if (is.null(filtered_main_plot())) {
      return()
    }
    
    
    if(gender_requested=='Female'){
      print("Female datset requested")
    } else if(gender_requested=='Male'){
      print("Male datset requested")
    } else if(gender_requested=='Both'){
      print("Both datsets requested")
    }else {
      print("Default Female datset requested")
    }
    
    
    
    plt = ggplot(stack(filtered_main_plot()), aes(x = ind, y = values)) + 
      geom_boxplot() + theme_minimal() + ggtitle("Female Life Expectancy In 256 Countries") +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) + 
      scale_y_continuous(name="Age", breaks=seq(0,90,10)) +
      scale_x_discrete(label=year_label_formatter, name="Year")
    
    return(plt)
  })
  
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

  observe({ print(input$selectAll_box) })
  observe({ print(input$clearAll_box) })
  
  
  
})