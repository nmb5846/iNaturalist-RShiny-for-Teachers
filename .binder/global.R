# global.R

library(raster)
library(tools)

# Create data directory if it doesn't exist
dir.create("data", showWarnings = FALSE)

# File paths
tif_path <- "data/2024_30m_cdls.tif"
zip_path <- "data/cdl_data.zip"
zip_url  <- "https://www.nass.usda.gov/Research_and_Science/Cropland/Release/datasets/2024_30m_cdls.zip"

# Only download if the raster file doesn't exist
if (!file.exists(tif_path)) {
  message("Downloading CDL ZIP (~1.6 GB)...")
  download.file(zip_url, destfile = zip_path, mode = "wb")
  unzip(zip_path, exdir = "data")
}

# Load the raster
r <- raster(tif_path)
