source("./data.R")

server <- function(input, output, session) {
  
  # Load the processed bus stop data
  
  bus_data <- load_bus_data()
  
  print(bus_data)
  
  tram_data <- load_city_circle_data()
  
  print(tram_data)
  
  output$map <- renderLeaflet({
    # Print the data to check if it's being passed to the map_renderer
    map_combined(bus_data,tram_data)  # Render the map using the processed bus data
  })
}
