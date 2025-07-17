# global.R

library(raster)
library(tools)

dir.create("data", showWarnings = FALSE)

tif_path <- "data/2024_30m_cdls.tif"
zip_path <- "data/cdl_data.zip"
zip_url  <- "https://www.nass.usda.gov/Research_and_Science/Cropland/Release/datasets/2024_30m_cdls.zip"

# Try downloading and unzipping if the file doesn't exist
if (!file.exists(tif_path)) {
  tryCatch({
    message("Downloading USDA CDL ZIP file...")
    download.file(zip_url, destfile = zip_path, mode = "wb")
    message("Unzipping...")
    unzip(zip_path, exdir = "data")
  }, error = function(e) {
    stop("Failed to download and unzip data: ", e$message)
  })
}

# Try loading the raster
if (file.exists(tif_path)) {
  r <- raster(tif_path)
} else {
  stop("Raster file not found at expected path: ", tif_path)
}
