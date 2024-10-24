library(geosphere)  # For distance calculations
source("./data.R")
source("./map.R")

server <- function(input, output, session) {
  
  # Load the processed bus stop, tram, and landmark data
  bus_data <- load_bus_data()
  tram_data <- load_city_circle_data()
  landmark_data <- load_landmarks_data()
  
  # Store user location and selected landmark
  user_location <- reactiveVal(NULL)
  selected_landmark <- reactiveVal(NULL)
  
  # Update the Theme and Sub Theme choices dynamically in the dropdown
  updateSelectInput(session, "theme_filter", 
                    choices = c("All", unique(landmark_data$Theme)),
                    selected = "All")
  
  updateSelectInput(session, "subtheme_filter", 
                    choices = c("All", unique(landmark_data$Sub.Theme)),
                    selected = "All")
  
  # Reactive function to filter landmarks based on selected Theme and Sub Theme
  filtered_landmarks <- reactive({
    filtered_data <- landmark_data
    if (input$theme_filter != "All") {
      filtered_data <- filtered_data %>%
        filter(Theme == input$theme_filter)
    }
    if (input$subtheme_filter != "All") {
      filtered_data <- filtered_data %>%
        filter(Sub.Theme == input$subtheme_filter)
    }
    return(filtered_data)
  })
  
  # Render the initial map using the custom map_combined function
  output$map <- renderLeaflet({
    map_combined(bus_data, tram_data, filtered_landmarks())  # Initial render of the map
  })
  
  # Observe changes in layer selection and update the map using leafletProxy
  observe({
    proxy <- leafletProxy("map")  # Use leafletProxy to modify the existing map
    
    # Show or hide "Bus Stops" layer
    if ("Bus Stops" %in% input$layers) {
      proxy %>% showGroup("Bus Stops")
    } else {
      proxy %>% hideGroup("Bus Stops")
    }
    
    # Show or hide "City Circle Tram Stops" layer
    if ("City Circle Tram Stops" %in% input$layers) {
      proxy %>% showGroup("City Circle Tram Stops")
    } else {
      proxy %>% hideGroup("City Circle Tram Stops")
    }
    
    # Show or hide "Landmarks" layer
    if ("Landmarks" %in% input$layers) {
      proxy %>% showGroup("Landmarks")
    } else {
      proxy %>% hideGroup("Landmarks")
    }
  })
  
  # Observe map click event to set the user location
  observeEvent(input$map_click, {
    
    clicked_lng <- input$map_click$lng
    clicked_lat <- input$map_click$lat
    
    if (!is.null(clicked_lng) && !is.null(clicked_lat)) {
      
      # Round the longitude and latitude
      rounded_lng <- round(clicked_lng, 4)
      rounded_lat <- round(clicked_lat, 4)
      
      # Store user location
      user_location(c(rounded_lng, rounded_lat))
      
      # Update info box 1 and 2 with the user location
      output$info1 <- renderText({
        paste(rounded_lng)
      })
      
      output$info2 <- renderText({
        paste(rounded_lat)
      })
      
      # Add or update user location marker
      leafletProxy("map") %>%
        clearGroup("user_location") %>%
        addMarkers(lng = rounded_lng, lat = rounded_lat, popup = "User Location", group = "user_location")
    }
  })
  
  # Capture landmark marker click event to set the selected landmark
  observeEvent(input$map_marker_click, {
    
    marker_lat <- input$map_marker_click$lat
    marker_lng <- input$map_marker_click$lng
    
    # Find if the clicked marker is in the landmarks data
    clicked_landmark <- landmark_data %>%
      filter(lng == marker_lng & lat == marker_lat) %>%
      pull(Feature.Name)
    
    if (!is.null(clicked_landmark)) {
      # Store selected landmark location
      selected_landmark(c(marker_lng, marker_lat))
      
      # Update info box 3 with the selected landmark
      output$info3 <- renderText({
        paste(clicked_landmark)
      })
      
      # Add or update selected landmark marker
      leafletProxy("map") %>%
        clearGroup("selected_landmark") %>%
        addMarkers(lng = marker_lng, lat = marker_lat, popup = "Selected Landmark", group = "selected_landmark")
    }
  })
  
  # Function to find the closest station (bus or tram)
  find_closest_station <- function(location, stations_data) {
    distances <- distHaversine(location, cbind(stations_data$lng, stations_data$lat))
    closest_index <- which.min(distances)
    return(stations_data[closest_index, ])
  }
  
  # Store the route calculation state
  route_calculated <- reactiveVal(FALSE)
  
  # Calculate the closest bus/tram stops when the button is clicked
  observeEvent(input$route_btn, {
    if (is.null(user_location()) || is.null(selected_landmark())) {
      showNotification("Please select both a user location and a landmark.")
      return()
    }
    
    if (!route_calculated()) {
      # Find the closest bus and tram stops to the user location
      closest_bus_user <- find_closest_station(user_location(), bus_data)
      closest_tram_user <- find_closest_station(user_location(), tram_data)
      
      # Find the closest bus and tram stops to the selected landmark
      closest_bus_landmark <- find_closest_station(selected_landmark(), bus_data)
      closest_tram_landmark <- find_closest_station(selected_landmark(), tram_data)
      
      # Define custom icons for bus, tram, and landmarks
      landmarkIcon <- icons(
        iconUrl = "../www/landmark.png",
        iconWidth = 40, iconHeight = 40,
        iconAnchorX = 20, iconAnchorY = 40
      )
      
      busStopIcon <- icons(
        iconUrl = "../www/bus.png",
        iconWidth = 30, iconHeight = 30,
        iconAnchorX = 15, iconAnchorY = 30
      )
      
      tramStopIcon <- icons(
        iconUrl = "../www/tram.png",
        iconWidth = 30, iconHeight = 30,
        iconAnchorX = 15, iconAnchorY = 30
      )
      
      # Update the map using leafletProxy
      leafletProxy("map") %>%
        clearMarkers() %>%
        addMarkers(lng = user_location()[1], lat = user_location()[2], popup = "User Location") %>%
        addMarkers(lng = selected_landmark()[1], lat = selected_landmark()[2], popup = "Selected Landmark", icon = landmarkIcon) %>%
        addMarkers(lng = closest_bus_user$lng, lat = closest_bus_user$lat, popup = "Closest Bus Stop (User)", icon = busStopIcon) %>%
        addMarkers(lng = closest_tram_user$lng, lat = closest_tram_user$lat, popup = "Closest Tram Stop (User)", icon = tramStopIcon) %>%
        addMarkers(lng = closest_bus_landmark$lng, lat = closest_bus_landmark$lat, popup = "Closest Bus Stop (Landmark)", icon = busStopIcon) %>%
        addMarkers(lng = closest_tram_landmark$lng, lat = closest_tram_landmark$lat, popup = "Closest Tram Stop (Landmark)", icon = tramStopIcon)
      
      # Update the route calculation state and button text
      route_calculated(TRUE)
      updateActionButton(session, "route_btn", label = "Cancel")
      
    } else {
      # Restore the map to the initial state by re-rendering it
      output$map <- renderLeaflet({
        map_combined(bus_data, tram_data, filtered_landmarks())  # Re-render the map with all data
      })
      
      # Reset the user location and landmark
      user_location(NULL)
      selected_landmark(NULL)
      
      # Clear the info boxes
      output$info1 <- renderText({
        "Click map to input your current position!"
      })
      
      output$info2 <- renderText({
        "Click map to input your current position!"
      })
      
      output$info3 <- renderText({
        "Choose the landmark that you want to visit!"
      })
      
      # Reset the route calculation state and button text
      route_calculated(FALSE)
      updateActionButton(session, "route_btn", label = "Calculation Route")
    }
  })
}

