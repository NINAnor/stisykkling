
rm(list=ls())

library(raster)
library(rgdal)
library(stringr)


DISK.DIR<-"P:/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/"


### READ 10m DTM
### (10m DTM IS OBTAINED FROM https://hoydedata.no/LaserInnsyn/)

setwd(paste0(DISK.DIR,"Slitasje og Egnethet.GISdata/LangsuaFilledDTMs/DTM_10m/"))
DEM10<-raster("Langsua_DTM10m_25833.tif")

### FIND NAMES OF FILES OF 1m DTMs
### (1m DTMs ARE OBTAINED FROM https://hoydedata.no/LaserInnsyn/)

setwd(paste0(DISK.DIR,"Slitasje og Egnethet.GISdata/LangsuaFilledDTMs/DTM_1m/"))
InNames<-list.files(path = getwd(),pattern="tif")
tf<-str_detect(InNames, ".ovr"); InNames<-InNames[tf==FALSE]
InNamesL<-length(InNames)

### READ 1m DTMS, FILL HOLES WITH DATA FROM 10m DTM AND SAVE FILLED 1m DTMs

for (i in 1:InNamesL)
{
  
  setwd(paste0(DISK.DIR,"Slitasje og Egnethet.GISdata/LangsuaFilledDTMs/DTM_1m/"))
  DEM1<-raster(paste0(InNames[i]))

  res <- resample(DEM10, DEM1, method = "bilinear")
  
  r3 <- merge(DEM1, res)

  setwd(paste0(DISK.DIR,"Slitasje og Egnethet.GISdata/LangsuaFilledDTMs/Filled/"))
  writeRaster(r3, paste0("Filled_",InNames[i]),overwrite=TRUE)
}

### FILLED 1m DTMs CAN BE SUBSEQUENTLY JOINED TOGETHER IN A GIS