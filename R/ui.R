library(shiny)
library(leaflet)

# UI part: Create a simple page to display the map
ui <- fluidPage(
  titlePanel("Mapbox API Map"),
  leafletOutput("map")
)
