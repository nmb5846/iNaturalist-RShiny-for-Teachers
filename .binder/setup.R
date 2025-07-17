# .binder/setup.R

dir.create("data", showWarnings = FALSE)

zip_path <- "data/cdl_data.zip"
tif_path <- "data/2024_30m_cdls.tif"

if (!file.exists(tif_path)) {
  download.file(
    url = "https://www.nass.usda.gov/Research_and_Science/Cropland/Release/datasets/2024_30m_cdls.zip",
    destfile = zip_path,
    mode = "wb"
  )
  unzip(zip_path, exdir = "data")
}
