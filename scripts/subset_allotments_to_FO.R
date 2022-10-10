# Subset allotments to Field Office

library(here)

library(tidyverse)
library(sf)

# set_here('/home/sagesteppe/plot_post_stratification')

allotments <- read_sf(paste0(here(), '/data/raw/BLM_National_Grazing_Allotments/gra.gdb')) %>% 
  mutate(ADMIN_ST = as.character(ADMIN_ST)) %>% 
  filter(ADMIN_ST == 'CO') %>% 
  select(ALLOT_NO:ACTIVE_DT, -ADMIN_ST) %>% 
  st_make_valid()

# now subset spatially to the Field Office. 

UFO_office_boundaries <- st_read(
  paste0(here(), '/data/raw/BLM_CO_Administrative_Units/', 'admu_ofc_poly.shp'),
  quiet = T) %>% 
  filter(ADMU_NAME == 'UNCOMPAHGRE FIELD OFFICE') %>% 
  dplyr::select(-1:-15) %>% 
  st_transform(4269) %>% 
  st_make_valid()

allotments <- st_intersection(UFO_office_boundaries,  allotments) 

ggplot(allotments) +
  geom_sf() +
  theme_bw()

ifelse(!dir.exists(
  file.path(here(),'/data/processed/UFO_Allotments')), 
       dir.create(
         file.path(here(), '/data/processed/UFO_Allotments')), FALSE)
st_write(allotments, 
         file.path(here(), '/data/processed/UFO_Allotments/UFO_Allotments.shp'))

rm(allotments, UFO_office_boundaries)
