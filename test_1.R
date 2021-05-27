
library(shiny)
library(leaflet)
library(tmap)
library(jsonlite)
library(sf)


station_stat_url <- fromJSON("https://gbfs.biketownpdx.com/gbfs/en/station_status.json",flatten = T)
station_info_url <- fromJSON("https://gbfs.biketownpdx.com/gbfs/en/station_information.json",flatten = T)

station_stat <- station_stat_url$data$stations

station_info <- station_info_url$data$stations %>% 
  st_as_sf(coords = c("lon","lat"),crs=4326) %>% 
  dplyr::left_join(station_stat, by = "station_id") %>%
  dplyr::select(name,station_id,address,num_docks_available,num_bikes_available,num_ebikes_available,station_type)

google_url <- station_info_url$data$stations %>% dplyr::mutate(url = paste0("https://www.google.com/maps/@",station_info_url$data$stations$lat,",",station_info_url$data$stations$lon,",22z/data=!3m1!1e3" ))



free_bike_url <- fromJSON("https://gbfs.biketownpdx.com/gbfs/en/free_bike_status.json",flatten = T)
bike <- free_bike_url$data$bikes %>% st_as_sf(coords = c("lon","lat"),crs=4326)



map <- leaflet(bike, options = leafletOptions(minZoom = 12, maxZoom = 18)) %>% setView(lng = -122.623, lat = 45.53, zoom = 13)

map %>% 
  addTiles("https://api.mapbox.com/styles/v1/philpdx/ckp3dtoya0ax417jxpjzhja5r/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicGhpbHBkeCIsImEiOiJja29rd2pyOHcwM29kMm9wNXUzNGJreGU4In0.xZ-YGe1yW3QZ6eU_voc29Q") %>%
  addCircleMarkers(data = station_info, fillOpacity = 0.5, color = "white", stroke = FALSE, radius = 7) %>%
  addCircleMarkers(data = bike, stroke = FALSE, fillOpacity = 1, color = "#59eb1e", radius = 2.5)
