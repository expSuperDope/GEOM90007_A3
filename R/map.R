# map.R
library(leaflet)

#' Render Melbourne Map
#' @return A leaflet map object
map_renderer <- function() {
  # Mapbox map API
  mapbox_url <- paste0(
    "https://api.mapbox.com/styles/v1/expsuperdope/cm2jyrd2q008p01plhzqsek71/tiles/",
    "{z}/{x}/{y}?access_token=",
    "pk.eyJ1IjoiZXhwc3VwZXJkb3BlIiwiYSI6ImNtMmp5bGo5NTBhMGoycW92b2k4bjJ4N3EifQ.EkaXg8v7lN6iaJyJfxtptw"
  )
  
  # Create a leaflet map object
  leaflet() %>%
    addTiles(
      urlTemplate = mapbox_url, 
      options = tileOptions(minZoom = 1, maxZoom = 20)
    ) %>%
    setView(lng = 144.9631, lat = -37.8136, zoom = 12)  # Set the center point to Melbourne with a zoom level of 12
}

