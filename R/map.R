library(leaflet)

# Combined map with different markers for bus stops, tram stops, and landmarks
map_combined <- function(bus_data, tram_data, landmark_data) {
  
  # Mapbox map API
  mapbox_url <- paste0(
    "https://api.mapbox.com/styles/v1/expsuperdope/cm2jyrd2q008p01plhzqsek71/tiles/",
    "{z}/{x}/{y}?access_token=",
    "pk.eyJ1IjoiZXhwc3VwZXJkb3BlIiwiYSI6ImNtMmp5bGo5NTBhMGoycW92b2k4bjJ4N3EifQ.EkaXg8v7lN6iaJyJfxtptw"
  )
  
  # Create custom icons for bus stops, tram stops, and landmarks
  bus_icon <- makeIcon(
    iconUrl = "../www/bus.png",  # Custom bus stop icon
    iconWidth = 35, iconHeight = 35,  # Set the size smaller
    iconAnchorX = 10, iconAnchorY = 30,  # Anchor point
    popupAnchorX = 0, popupAnchorY = -30
  )
  
  tram_icon <- makeIcon(
    iconUrl = "../www/tram.png",  # Custom tram stop icon
    iconWidth = 35, iconHeight = 35,  # Set the size smaller
    iconAnchorX = 10, iconAnchorY = 30,  # Anchor point
    popupAnchorX = 0, popupAnchorY = -30
  )
  
  landmark_icon <- makeIcon(
    iconUrl = "../www/landmark.png",  # Custom landmark icon
    iconWidth = 35, iconHeight = 30,  # Set the size smaller
    iconAnchorX = 10, iconAnchorY = 30,  # Anchor point
    popupAnchorX = 0, popupAnchorY = -30
  )
  
  # Create the base map
  base_map <- leaflet() %>%
    addTiles(
      urlTemplate = mapbox_url, 
      options = tileOptions(minZoom = 1, maxZoom = 20)
    ) %>%
    setView(lng = 144.9631, lat = -37.8136, zoom = 13.5)
  
  # Add bus stops layer
  base_map <- base_map %>%
    addMarkers(
      lng = bus_data$lng, lat = bus_data$lat,
      group = "Bus Stops",
      popup = bus_data$Name,
      icon = bus_icon  # Apply bus stop icon
    )
  
  # Add tram stops layer
  base_map <- base_map %>%
    addMarkers(
      lng = tram_data$lng, lat = tram_data$lat,
      group = "City Circle Tram Stops",
      popup = tram_data$name,
      icon = tram_icon  # Apply tram stop icon
    )
  
  base_map <- base_map %>%
    addMarkers(
      lng = landmark_data$lng, lat = landmark_data$lat,
      group = "Landmarks",
      popup = paste0("Name: ", landmark_data$Feature.Name, "<br>",
                     "Theme: ", landmark_data$Theme, "<br>",
                     "Sub Theme: ", landmark_data$Sub.Theme),
      label = paste0("Name: ", landmark_data$Feature.Name, "\n",
                     "Theme: ", landmark_data$Theme, "\n",
                     "Sub Theme: ", landmark_data$Sub.Theme),
      icon = landmark_icon,  # Apply landmark icon
      labelOptions = labelOptions(
        style = list(
          "white-space" = "pre-line",   # Enable \n for line breaks
          "max-width" = "200px",        # Set the max width of the label
          "width" = "200px",            # Set fixed width if needed
          "text-align" = "left"         # Align text to the left
        )
      )
    )
  
  
  # Add layer control for switching between layers
  base_map %>%
    addLayersControl(
      overlayGroups = c("Bus Stops", "City Circle Tram Stops", "Landmarks"),
      options = layersControlOptions(collapsed = FALSE)
    )
}

