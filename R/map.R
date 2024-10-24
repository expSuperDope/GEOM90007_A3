# map.R
library(leaflet)

# Render Melbourne bus stops map
map_bus <- function(bus_data) {
  
  # Mapbox map API
  mapbox_url <- paste0(
    "https://api.mapbox.com/styles/v1/expsuperdope/cm2jyrd2q008p01plhzqsek71/tiles/",
    "{z}/{x}/{y}?access_token=",
    "pk.eyJ1IjoiZXhwc3VwZXJkb3BlIiwiYSI6ImNtMmp5bGo5NTBhMGoycW92b2k4bjJ4N3EifQ.EkaXg8v7lN6iaJyJfxtptw"
  )
  
  # Create the bus stops map
  leaflet() %>%
    addTiles(
      urlTemplate = mapbox_url, 
      options = tileOptions(minZoom = 1, maxZoom = 20)
    ) %>%
    setView(lng = 144.9631, lat = -37.8136, zoom = 13) %>%
    addMarkers(
      lng = bus_data$lng, lat = bus_data$lat,
      popup = bus_data$Name
    )
}

# Render Melbourne tram tracks map
map_tram <- function(tram_data) {
  
  # Mapbox map API
  mapbox_url <- paste0(
    "https://api.mapbox.com/styles/v1/expsuperdope/cm2jyrd2q008p01plhzqsek71/tiles/",
    "{z}/{x}/{y}?access_token=",
    "pk.eyJ1IjoiZXhwc3VwZXJkb3BlIiwiYSI6ImNtMmp5bGo5NTBhMGoycW92b2k4bjJ4N3EifQ.EkaXg8v7lN6iaJyJfxtptw"
  )
  
  # Create the tram tracks map
  leaflet() %>%
    addTiles(
      urlTemplate = mapbox_url, 
      options = tileOptions(minZoom = 1, maxZoom = 20)
    ) %>%
    setView(lng = 144.9631, lat = -37.8136, zoom = 12) %>%
    addPolylines(
      lng = tram_data$lng, lat = tram_data$lat,
      color = "blue", weight = 2
    )
}



