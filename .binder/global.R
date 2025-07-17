# app.R
library(shiny)
library(raster)
library(tools)

dir.create("data", showWarnings = FALSE)

# Path to .tif file
tif_path <- "data/2024_30m_cdls.tif"
zip_url <- "https://www.nass.usda.gov/Research_and_Science/Cropland/Release/datasets/2024_30m_cdls.zip"
zip_path <- "data/cdl_data.zip"

# Only download and unzip if needed
if (!file.exists(tif_path)) {
  download.file(zip_url, destfile = zip_path, mode = "wb")
  unzip(zip_path, exdir = "data")
}

# Now read the file
r <- raster(tif_path)

ui <- fluidPage(
  titlePanel("Shiny App with CDL Raster"),
  plotOutput("rPlot")
)
server <- function(input, output, session) {
  output$rPlot <- renderPlot({ plot(r) })
}
shinyApp(ui, server)
