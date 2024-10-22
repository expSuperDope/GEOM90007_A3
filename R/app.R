# 安装并加载必要的包
if (!require(shiny)) install.packages("shiny")
if (!require(leaflet)) install.packages("leaflet")

library(shiny)
library(leaflet)

# UI 部分：构建一个简单的页面来显示地图
ui <- fluidPage(
  titlePanel("Mapbox API Map"),
  leafletOutput("map")
)

# 服务器部分：创建地图并加载Mapbox瓦片
server <- function(input, output, session) {
  
  # 使用 leaflet 生成地图
  output$map <- renderLeaflet({
    
    # Mapbox 瓦片的 URL 模板，使用你提供的 API
    mapbox_url <- "https://api.mapbox.com/styles/v1/expsuperdope/cm2jyrd2q008p01plhzqsek71/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZXhwc3VwZXJkb3BlIiwiYSI6ImNtMmp5bGo5NTBhMGoycW92b2k4bjJ4N3EifQ.EkaXg8v7lN6iaJyJfxtptw"
    
    # 创建 leaflet 地图对象
    leaflet() %>%
      addTiles(urlTemplate = mapbox_url, 
               options = tileOptions(minZoom = 1, maxZoom = 20)) %>%
      setView(lng = 144.9631, lat = -37.8136, zoom = 12)  # 设置中心点为墨尔本，缩放等级为12
  })
}

# 启动 Shiny App
shinyApp(ui, server)
