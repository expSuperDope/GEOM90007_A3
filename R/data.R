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

load_city_circle_data <- function() {
  # Load the CSV file
  tram_data <- read.csv("../dataset/city-circle-tram-stops.csv")
  
  # Function to parse Geo Shape and extract coordinates
  parse_geo_shape <- function(geo_shape) {
    json_data <- fromJSON(geo_shape)
    
    # Extract the coordinates from Geo Shape
    coordinates <- json_data$coordinates
    return(data.frame(lng = coordinates[1], lat = coordinates[2]))
  }
  
  # Parse the Geo Shape field to extract longitude and latitude
  parsed_tram_data <- tram_data %>%
    rowwise() %>%
    mutate(
      geo_coordinates = list(parse_geo_shape(Geo.Shape)),
      lng = geo_coordinates$lng,
      lat = geo_coordinates$lat
    ) %>%
    select(name, lng, lat, stop_no)  # Select relevant fields: name, lng, lat, and stop number
  
  return(parsed_tram_data)
}

load_landmarks_data <- function() {
  # Load the CSV file
  landmarks_data <- read.csv("../dataset/landmarks-and-places-of-interest-including-schools-theatres-health-services-spor.csv")
  
  # Split the "Co-ordinates" column to extract latitude and longitude
  landmarks_data <- landmarks_data %>%
    mutate(
      lat = as.numeric(sub(",.*", "", Co.ordinates)),  # Extract latitude
      lng = as.numeric(sub(".*, ", "", Co.ordinates))  # Extract longitude
    ) %>%
    # Select relevant columns
    select(Theme, Sub.Theme, Feature.Name, lat, lng) %>%
    # Filter landmarks within the specified bounding box (lat/lng)
    filter(lat >= -37.834256, lat <= -37.799947, lng >= 144.935655, lng <= 144.987276)
  
  return(landmarks_data)
}
