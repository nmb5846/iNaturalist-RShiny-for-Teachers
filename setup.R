# setup.R

# Create a data directory if it doesn't exist
dir.create("data", showWarnings = FALSE)

# Download the ZIP file from USDA
zip_path <- "data/cdl_data.zip"
if (!file.exists("data/2024_30m_cdls.tif")) {
  download.file(
    url = "https://www.nass.usda.gov/Research_and_Science/Cropland/Release/datasets/2024_30m_cdls.zip",
    destfile = zip_path,
    mode = "wb"
  )
  unzip(zip_path, exdir = "data")
}
