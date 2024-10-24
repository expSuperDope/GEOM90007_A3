library(shiny)
library(leaflet)

# Define UI for the map with dropdown filters and layer controls
ui <- fluidPage(
  # Set a custom theme for the page
  tags$head(
    tags$style(HTML("
      body {
        font-family: Arial, sans-serif;
        background-color: #f8f9fa;
      }
      .title {
        text-align: center;
        font-size: 2em;
        font-weight: bold;
        margin-bottom: 20px;
        color: #2c3e50;
      }
      .selectize-input {
        font-size: 14px;
      }
      .checkbox input[type='checkbox'] {
        margin-right: 10px;
      }
      .sidebar {
        background-color: #ffffff;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
      }
      .sidebar .form-group {
        margin-bottom: 15px;
      }
      #map {
        height: calc(100vh - 100px);
        margin-top: 20px;
      }
    "))
  ),
  
  # Title Panel
  div(class = "title", "City Map"),
  
  # Sidebar Layout
  sidebarLayout(
    sidebarPanel(
      div(class = "sidebar",  # Custom styling for the sidebar
          
          # Existing elements
          selectInput("theme_filter", "Select Theme:",
                      choices = NULL,  # Choices will be updated dynamically
                      selected = NULL,
                      multiple = FALSE,
                      width = "100%"),  # Full width for better alignment
          
          selectInput("subtheme_filter", "Select Sub Theme:",
                      choices = NULL,  # Choices will be updated dynamically
                      selected = NULL,
                      multiple = FALSE,
                      width = "100%"),  # Full width for better alignment
          
          checkboxGroupInput("layers", "Select Layers to Display:",
                             choices = c("Bus Stops", "City Circle Tram Stops", "Landmarks"),
                             selected = c("Bus Stops", "City Circle Tram Stops", "Landmarks")),  # Default selection
          
          
          h4("Site Calculator"),
          div(style = "margin-bottom: 10px;",
              strong("Longitude: "),  
              textOutput("info1", inline = TRUE) 
          ),
          div(style = "margin-bottom: 10px;",
              strong("Latitude: "), 
              textOutput("info2", inline = TRUE)  
          ),
          div(style = "margin-bottom: 10px;",
              strong("Landmark Name: "),  
              textOutput("info3", inline = TRUE)  
          ),
          
          # Button for calculating route
          actionButton("route_btn", "Calculation Route"), 
          
          width = 2  # Adjust the sidebar width (default is 4)
      )
    ),
    
    # Main panel for the map output
    mainPanel(
      leafletOutput("map", height = "calc(100vh - 100px)")  # Output map with increased height
    )
  )
)


