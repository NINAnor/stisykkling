
rm(list=ls())
library(raster)
library(rgdal)
library(spatialEco)
library(dplyr)

DISK.DIR<-"P:/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/"
setwd(DISK.DIR)


#### DIRECTORIES AND NAMES

### (NB: CHANGE THE VARIABLE PARKNAME TO CONTROL WHICH PARK IS PROCESSED)
PARKNAME<-"Langsua"
#PARKNAME<-"Sjunkhatten"

if (PARKNAME=="Langsua") {

DEM.dir<-"Slitasje og Egnethet.GISdata/LangsuaRasters/"

Trail.dir<-"Slitasje og Egnethet.GISdata/LangsuaVectors/"
TrailGrade.dir<-"Slitasje og Egnethet.GISdata/LangsuaVectors/"
  
DEM.name<-"Langsua_DTM1m_filled_merged.tif"
Trail.name<-"Langsua_NP_network_trails"
TrailGrade.outname<-"Langsua_trails_UserGrade"
TrailObsGrade.outname<-"Langsua_trailObs_UserGrade"

}

if (PARKNAME=="Sjunkhatten") {
  
DEM.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenRasters/"
Trail.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenVectors/"
TrailGrade.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenVectors/"
DEM.name<-"Sjunkhatten_DEM1m_filled.tif"
Trail.name<-"Sjunk_NP_network_trails"
TrailGrade.outname<-"Sjunkhatten_trails_UserGrade"
TrailObsGrade.outname<-"Sjunkhatten_trailObs_UserGrade"

}

### READ DATA

setwd(paste0(DISK.DIR,DEM.dir))
DEM <- raster(DEM.name)
plot(DEM)

setwd(paste0(DISK.DIR,Trail.dir))
Path<-readOGR(dsn=".", layer=Trail.name)
plot(Path,add=TRUE)

Path$path_id<-as.character(Path$path_id)


############

IDU<-Path$path_id
IDUL<-length(IDU)
MaxSecSlope<-MeanSecSlope<-rep(NA,IDUL)
NrVert<-rep(NA,IDUL)

C.ls<-list()  
for (j in 1:IDUL)
{
  print(paste("Trail",j,"of",IDUL))
  
  tf<-Path$path_id==IDU[j]
  Sub<-Path[tf,]
  
  g<-sample.line(Sub, d = 100, offset=0, type = "regular",longlat=FALSE)

  NrVert[j]<-nrow(g)
  if(NrVert[j]>1)
    {
    C<-data.frame(coordinates(g))
    colnames(C)<-c("x","y")
    xy<-data.frame(C$x,C$y); colnames(xy)<-c("x","y")
    CL<-nrow(C)
    C$DEM<-extract(DEM, xy)
    C$SlopePer<-round(c(NA,abs(C$DEM[2:CL]-C$DEM[1:(CL-1)])),2)
    MaxSecSlope[j]<-round(max(C$SlopePer,na.rm=TRUE),2)
    MeanSecSlope[j]<-round(mean(C$SlopePer,na.rm=TRUE),2)
    C$path_ID<-IDU[j]
    C$point_ID<-seq(1,CL)
    C.ls[[j]]<-C

    }
  }

# CALCULATE SUITABILITY PER TRAIL

MaxGrade<-MeanGrade<-rep(NA,IDUL)
tf<-MaxSecSlope<=3; tf[is.na(tf)]<-FALSE;                 MaxGrade[tf]<-"Grønn"
tf<-MaxSecSlope>3 & MaxSecSlope<=5; tf[is.na(tf)]<-FALSE; MaxGrade[tf]<-"Blå"
tf<-MaxSecSlope>5 & MaxSecSlope<=7; tf[is.na(tf)]<-FALSE; MaxGrade[tf]<-"Rød"
tf<-MaxSecSlope>7 & MaxSecSlope<=9; tf[is.na(tf)]<-FALSE; MaxGrade[tf]<-"Svart"
tf<-MaxSecSlope>9; tf[is.na(tf)]<-FALSE;                  MaxGrade[tf]<-"DobbeltSvart"

tf<-MeanSecSlope<=3; tf[is.na(tf)]<-FALSE;                  MeanGrade[tf]<-"Grønn"
tf<-MeanSecSlope>3 & MeanSecSlope<=5; tf[is.na(tf)]<-FALSE; MeanGrade[tf]<-"Blå"
tf<-MeanSecSlope>5 & MeanSecSlope<=7; tf[is.na(tf)]<-FALSE; MeanGrade[tf]<-"Rød"
tf<-MeanSecSlope>7 & MeanSecSlope<=9; tf[is.na(tf)]<-FALSE; MeanGrade[tf]<-"Svart"
tf<-MeanSecSlope>9; tf[is.na(tf)]<-FALSE;                   MeanGrade[tf]<-"DobbeltSvart"

Path$MaxSecSlope<-MaxSecSlope
Path$MaxGrade<-MaxGrade
Path$MeanSecSlope<-MeanSecSlope
Path$MeanGrade<-MeanGrade


### WRITE TRAILS 

CRS<-"+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
crs(Path)<-CRS
setwd(paste0(DISK.DIR,TrailGrade.dir))
writeOGR(Path, ".", TrailGrade.outname, driver="ESRI Shapefile",overwrite_layer=TRUE, layer_options = "ENCODING=UTF-8")

### WRITE TAIL OBSERVATIONS
C.all<-bind_rows(C.ls)
Grade<-rep(NA,nrow(C.all))
tf<-C.all$SlopePer<=3; tf[is.na(tf)]<-FALSE; Grade[tf]<-"Grønn"
tf<-C.all$SlopePer>3 & C.all$SlopePer<=5; tf[is.na(tf)]<-FALSE; Grade[tf]<-"Blå"
tf<-C.all$SlopePer>5 & C.all$SlopePer<=7; tf[is.na(tf)]<-FALSE; Grade[tf]<-"Rød"
tf<-C.all$SlopePer>7 & C.all$SlopePer<=9; tf[is.na(tf)]<-FALSE; Grade[tf]<-"Svart"
tf<-C.all$SlopePer>9; tf[is.na(tf)]<-FALSE; Grade[tf]<-"DobbeltSvart"
C.all$Grade<-Grade

C.all.coords<-C.all[,1:2]
Tr.spdf <- SpatialPointsDataFrame(C.all.coords, C.all)
crs(Tr.spdf)<-CRS
writeOGR(Tr.spdf, ".", TrailObsGrade.outname, driver="ESRI Shapefile",overwrite_layer=TRUE, layer_options = "ENCODING=UTF-8")

