#loading packages
library(plotly)
library(shiny)
library(ggplot2)
library(dplyr)
library(viridis)

#loading data to be visulized
data<-read.csv("clean_data.csv")
#last minute small data cleaning
names(data)[names(data) == "X30.year.Mortgage.rate"] <- "Mortgage.Rate"
data$DATE<-as.Date(data$DATE)

#creating the Shiny Dashboard for visulization
# Define the UI
ui <- fluidPage(
  titlePanel("Housing Indicators Dashboard"),
  
  # Tabs
  tabsetPanel(
    tabPanel("Scatter Plot",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   inputId = "y",
                   label = "Y-Axis:",
                   choices = c("Mortgage.Rate", "Median.Sale.Price", "Inventory", "Average.Sale.To.List", "New.Listings", "Homes.Sold"),
                   selected = "Median.Sale.Price"
                 ),
                 selectInput(
                   inputId = "color",
                   label = "Pick viridis color scale for all plots:",
                   choices = c("magma", "inferno", "plasma", "viridis", "cividis"),
                   selected = "viridis"
                 )
               ),
               mainPanel(
                 plotlyOutput(outputId = "scatterplot")
               )
             )
    ),
    
    tabPanel("Histograms",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   inputId = "variable1",
                   label = "Select variable 1:",
                   choices = c("Mortgage.Rate", "Median.Sale.Price", "Inventory", "Average.Sale.To.List", "New.Listings", "Homes.Sold"),
                   selected = "Mortgage.Rate"
                 ),
                 selectInput(
                   inputId = "variable2",
                   label = "Select variable 2:",
                   choices = c("Mortgage.Rate", "Median.Sale.Price", "Inventory", "Average.Sale.To.List", "New.Listings", "Homes.Sold"),
                   selected = "Median.Sale.Price"
                 )
               ),
               mainPanel(
                 plotlyOutput(outputId = "histogram1"),
                 plotlyOutput(outputId = "histogram2")
               )
             )
    ),
    
    tabPanel("Violin Plots",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   inputId = "variable3",
                   label = "Select variable 1:",
                   choices = c("Mortgage.Rate", "Median.Sale.Price", "Inventory", "Average.Sale.To.List", "New.Listings", "Homes.Sold"),
                   selected = "Mortgage.Rate"
                 ),
                 selectInput(
                   inputId = "variable4",
                   label = "Select variable 2:",
                   choices = c("Mortgage.Rate", "Median.Sale.Price", "Inventory", "Average.Sale.To.List", "New.Listings", "Homes.Sold"),
                   selected = "Median.Sale.Price"
                 )
               ),
               mainPanel(
                 plotlyOutput(outputId = "violinplot1"),
                 plotlyOutput(outputId = "violinplot2")
               )
             )
    )
  )
)

# Define the server
server <- function(input, output) {
  
  # Scatter plot
  output$scatterplot <- renderPlotly({
    plot_ly(data, x = ~DATE, y = ~get(input$y), type = 'scatter', mode = 'lines+markers', color = input$y,
            colors = viridis_pal(option = input$color)(5)) %>%
      layout(title = paste(input$y, "over time"),
             xaxis = list(zeroline = TRUE),
             yaxis = list(title = input$y))
  })
  
  # Histogram 1
  output$histogram1 <- renderPlotly({
    plot_ly(data, x = ~get(input$variable1), type = 'histogram', marker = list(line = list(color = 'black', width = 1)),
            color = I(viridis(100, option = input$color)[50])) %>%
      layout(title = paste("Histogram of", input$variable1),
             xaxis = list(title = input$variable1),
             yaxis = list(title = "Frequency"))
  })
  
  # Histogram 2
  output$histogram2 <- renderPlotly({
    plot_ly(data, x = ~get(input$variable2), type = 'histogram', marker = list(line = list(color = 'black', width = 1)),
            color = I(viridis(100, option = input$color)[70])) %>%
      layout(title = paste("Histogram of", input$variable2),
             xaxis = list(title = input$variable2),
             yaxis = list(title = "Frequency"))
  })
  
  # Violin Plot 1
  output$violinplot1 <- renderPlotly({
    plot_ly(data, y = ~get(input$variable3), type = 'violin', side = 'both', box = list(visible = TRUE),
            color = I(viridis(100, option = input$color)[90])) %>%
      layout(title = paste("Violin Plot of", input$variable3),
             yaxis = list(title = input$variable3))
  })
  
  # Violin Plot 2
  output$violinplot2 <- renderPlotly({
    plot_ly(data, y = ~get(input$variable4), type = 'violin', side = 'both', box = list(visible = TRUE),
            color = I(viridis(100, option = input$color)[10])) %>%
      layout(title = paste("Violin Plot of", input$variable4),
             yaxis = list(title = input$variable4))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
