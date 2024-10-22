server <- function(input, output, session) {
  output$map <- renderLeaflet({
    map_renderer()  
  })
}