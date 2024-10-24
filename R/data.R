# data.R
library(dplyr)
library(jsonlite)

# Load bus stop data
load_bus_data <- function() {
  bus_data <- read.csv("../dataset/bus-stops-for-melbourne-visitor-shuttle.csv")
  
  # Split the "Co-ordinates" column to extract latitude and longitude
  bus_data <- bus_data %>%
    mutate(
      lat = as.numeric(sub(",.*", "", Co.ordinates)),
      lng = as.numeric(sub(".*, ", "", Co.ordinates))
    )
  
  return(bus_data)  # Return the processed bus stop data
}

# Load and parse tram track data
load_tram_data <- function() {
  tram_data <- read.csv("../dataset/tram-tracks.csv")
  
  # Function to parse the Geo Shape field and handle nested JSON data
  parse_geo_shape <- function(geo_shape) {
    json_data <- fromJSON(geo_shape)
    
    # Check if the "coordinates" field exists
    if ("coordinates" %in% names(json_data)) {
      coordinates <- json_data$coordinates
      
      # Handle MultiPolygon nested structure
      all_coords <- lapply(coordinates, function(polygon) {
        lapply(polygon, function(ring) {
          # Extract the coordinates from each polygon ring
          coords <- data.frame(lng = sapply(ring, function(pt) pt[1]),
                               lat = sapply(ring, function(pt) pt[2]))
          
          # Filter out invalid coordinate points (latitude/longitude should not be NA and must be within valid ranges)
          valid_coords <- coords %>%
            filter(!is.na(lng) & !is.na(lat) & lat >= -90 & lat <= 90 & lng >= -180 & lng <= 180)
          
          return(valid_coords)
        })
      })
      
      # Combine coordinates from all polygons
      return(bind_rows(unlist(all_coords, recursive = FALSE)))
    } else {
      stop("No 'coordinates' field found in Geo Shape data")
    }
  }
  
  # Parse Geo Shape for the entire dataset
  parsed_tram_data <- lapply(tram_data$Geo.Shape, parse_geo_shape)
  
  # Combine all parsed data into a data frame
  parsed_tram_data_df <- bind_rows(parsed_tram_data, .id = "track_id")
  
  return(parsed_tram_data_df)  # Return the parsed tram track data
}

