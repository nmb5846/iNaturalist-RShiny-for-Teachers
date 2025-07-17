#Load packages

library("devtools")
library("raster")
library("terra")
library("dplyr")
library("ggplot2")
library("sf")
library("tidyterra")
library("lubridate")
library("shiny")
library("bs4Dash")
library("readr")
library("plotly")
library("leaflet")
library("DT")
library("fresh")
library("tigris")
library("CropScapeR")
library("rinat")

#Import Data

Species1 <- read_csv("Rattlesnakes_PA.csv")

cdl_colormap <- read_csv("cdl_colormap.csv")

#Now that we have our data, we need to extract some information from it

#--SPECIES1--

Sp1year <-lubridate::year(Species1$observed_on) #if observations were pulled from different years
Sp1month <-lubridate::month (Species1$observed_on)

Sp1num_sightings <- nrow(Species1) #the total no. of sightings;this value is reported on the RShiny page
Sp1over_years <- names(which.max(table(Sp1year))) #this one too (as an info box); if you are working with only 1 year of data you may choose to customize this info box differently

Sp1number_counties <- ((length(unique(Species1$place_county_name)))/67)*100 #(I manually put in 67, since PA has 67 counties. If you are working with a different state this value will need to be updated)
#Sp1number_states <- (length(unique(Species1$place_state_name))) #Run this line instead if data is nationwide and not statewide

#Now we will use link USDA landuse data (CDL) to the coordinates of our observations

#Load the CDL file

data <- rast("2024_30m_cdls.tif") #load the CDL file (incl all USA)

#make sure both datasets use the same projection

Sp1Obs <- st_as_sf(Species1, coords = c("longitude", "latitude"), crs = 4326)
crs(data) <- "EPSG:5070"
Sp1Obs_proj <- st_transform(Sp1Obs, crs(data))
Sp1_vect <- vect(Sp1Obs_proj)
cdl_info <- extract(data, Sp1_vect)
Species1$cdl_value <- cdl_info[,2]

#Now when you view the 'Species1' tab you'll see an extra column on the end that includes the cropland data layer for each observation

plot_colour <- "#B5DB93" #customizing themes is secondary to reading in data - expt with this on your own time

theme <- create_theme(
  bs4dash_color(
    yellow = "#eddb68", #Customize color themes using Color Picker
    orange = "#e39e14",
    green = "#B5DB93"
  ),
  bs4dash_status(
    primary = "#f0eac7",
    info = "#E4E4E4"
  )
)

ui <- dashboardPage(
  title = "iNat Observations",
  
  freshTheme = theme,
  dark = NULL,
  help = NULL,
  fullscreen = TRUE,
  scrollToTop = TRUE,
  
  # Header ----
  
  header = dashboardHeader(
    status = "yellow",
    title = dashboardBrand(
      title = "iNat Observations",
      color = "orange",
      image = "https://images.unsplash.com/photo-1672532324606-896877df8065?q=80&w=1404&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    )
  ),
  # Sidebar ----
  sidebar = dashboardSidebar(
    sidebarMenu(
      id = "sidebarMenuid",
      menuItem(
        "Home",
        tabName = "Home",
        icon = icon("home")
      ),
      menuItem(
        "Species1",
        tabName = "Species1",
        icon = icon("bar-chart")
      )
    )
  ),
  
  # Control bar ----
  controlbar = dashboardControlbar(),
  
  # Footer ----
  footer = dashboardFooter(
    left = "Natalie Boyle", #insert your name in here!!
    right = "RShiny Demo 2025"
  ),
  
  # Body ----
  body = dashboardBody(
    tabItems(
      
      # Home tab ----
      tabItem(
        tabName = "Home",
        
        jumbotron(
          title = "Welcome!",
          status = "info",
          lead = "Visualizing iNaturalist Observations Using an RShiny Framework",
          href = "https://www.inaturalist.org/",
          "Data freely available from iNaturalist.org"
        ),
        
        fluidRow(
          
          userBox(
            collapsible = FALSE,
            title = userDescription(
              title = "INSECT NET RShiny Workshop",
              subtitle = "July 1, 2025",
              image = "https://inaturalist-open-data.s3.amazonaws.com/photos/456249/medium.jpg",
              type = 1
            ),
            status = "orange",
            "Visit our website: insectnet.psu.edu"
          ),
          
          box(
            title = "Think about these questions as you customize your dashboard:",
            width = 6,
            collapsible = FALSE,
            blockQuote("When and where might I be mostly likely to encounter my species of interest? Where might there be biases in my data? What is a new figure I'd like to generate, informed by the data contained herein?", color = "purple")
          )
          
        )
        
      ),
      
      # Sp 1 tab ----
      tabItem(
        tabName = "Species1",
        
        ## Info boxes for sp 1 ----
        fluidRow(
          
          column(
            width = 4,
            infoBox(
              width = 12,
              title = "Total Observations",
              value = Sp1num_sightings,
              icon = icon("list"),
              color = "primary"
            )
          ),
          
          column(
            width = 4,
            infoBox(
              width = 12,
              value = Sp1over_years,
              title = "Year with most observations",
              icon = icon("bug"),
              color = "primary"
            )
          ),
          
          column(
            width = 4,
            infoBox(
              width = 12,
             value = format(round(Sp1number_counties, 0), nsmall = 0), #if obs are state specific
             #value = format(round(Sp1number_states, 0), nsmall = 0), #if obs are in many states
              title = "%age of PA counties with obs",
             #title = "no. states with obs", #if obs are in multiple states
              icon = icon("location-dot"),
              color = "primary"
            )
          )
          
        ),
        
        ## Sortable boxes for Sp1----
        fluidRow(
          sortable(
            width = 6,
            
            box(
              title = "Observations by Landscape (2024 CDL Data)", 
              width = 12, 
              status = "orange",
              collapsible = FALSE, 
              
              plotlyOutput("Sp1plot_CDL")
            ),
            
            
            tabBox(
              id = "tabcard",
              title = "Observations Over Time",
              width = 12,
              status = "orange",
              solidHeader = TRUE,
              type = "tabs",
              tabPanel(
                title = "By Month",
                width = 12,
                status = "orange",
                
                plotOutput("Sp1monthlyobs")
              ),
              tabPanel(
                title = "By Year",
                width = 12,
                status = "orange",
                
                plotOutput("Sp1annualobs")
              )
            )
            
          ),
          
          sortable(
            width = 6,
            
            box(
              title = "Observations by Location",
              width = 12,  
              status = "orange",
              collapsible = FALSE,
              maximizable = TRUE,
              
              leafletOutput("Sp1plot_sightings_by_location")
              
            ),
            
            box(
              title = "Rattlesnakes", ##Customize for your chosen Species1 of interest
              width = 12,
              collapsible = FALSE,
              blockQuote("Rattlesnakes are scary and I don't want to be bit by one", color = "orange") ##Customize for your taxa of interest
            )
          )
        )
      )
    )
  )
)
server <- function(input, output) {
  
  #------- Getting all data in a readable format for RShiny-------------# 
  #Number of Moths observations in each CDL landscape type bar chart
  
  output$Sp1plot_CDL <- renderPlotly({
    
    Species1 %>% 
      ggplot(aes(x = cdl_value)) + 
      geom_bar(fill = "purple") + 
      labs(
        x = ""
      ) + 
      theme_bw() + 
      coord_flip()
  })
  
  
  output$Sp1monthlyobs <- renderPlot({hist(Sp1month)}) #Observations by month
  
  output$Sp1annualobs <- renderPlot({hist(Sp1year)}) #Observations by year
  
  
  
  #Interactive map of observations
  output$Sp1plot_sightings_by_location <- renderLeaflet({
    
    
    leaflet(data = Species1) %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addCircleMarkers(
        ~longitude,
        ~latitude,
        radius = 3,
        color = plot_colour,
        fillOpacity = 1,
        popup = ~paste0("Observed on ", observed_on," in ", Species1$cdl_value)
      )
  })
  
  
}

shinyApp(ui, server)

