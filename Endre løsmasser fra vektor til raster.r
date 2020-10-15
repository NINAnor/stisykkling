
rm(list=ls())

library(raster)
library(rgdal)


### DIRECTORIES AND NAMES

DISK.DIR<-"P:/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/"


Vec.dir<-"Slitasje og Egnethet.GISdata/LangsuaVectors/"
Vec.name<-"LMF_25833"

Rast.dir<-"Slitasje og Egnethet.GISdata/LangsuaRasters/"
Rast.name<-"Langsua_DTM1m_filled_merged.tif"


### READ DATA

# READ VECTOR OF LØSMASSE

setwd(paste0(DISK.DIR,Vec.dir))
LM <- readOGR(dsn=".", layer=Vec.name, use_iconv = TRUE, encoding = "UTF-8")
LM$jordart<-as.numeric(as.character(LM$jordart))

# READ RASTER TO DEFINE GEOGRAPHICAL RANGE OVER THIS LØSMASSE WILL BE RASTERIZED

setwd(paste0(DISK.DIR,Rast.dir))
DEM <- raster(Rast.name)

plot(DEM)
plot(LM,add=TRUE)

### RASTERIZE VECTOR

LM.file<-raster()
extent(LM.file)<-extent(DEM)
res(LM.file)<-10
LM.r <- rasterize(LM, LM.file,field="jordart")

CRS("+init=epsg:25833")
crs(LM.r) <- "+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

plot(LM.r)

### WRITE DATA

writeRaster(LM.r, filename=file.path(paste0(DISK.DIR,Rast.dir), "Langsua_Løsmasse_25833.tif"), format="GTiff", overwrite=TRUE)

