
#########
# PRODUCES TWO FILES:
# 1) Tr: Trail properties every 10 m along the trails
# 2) Trail: Trail suitability (STI_EGNETHET) per trail
#########


rm(list=ls())

library(raster)
library(rgdal)
library(spatialEco)
library(dplyr)


DISK.DIR<-"P:/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/"
setwd(DISK.DIR)

source("Slitasje og Egnethet.Scripts/Scripts/add.TWI.LUT.r")
source("Slitasje og Egnethet.Scripts/Scripts/add.slope.LUT.r")
source("Slitasje og Egnethet.Scripts/Scripts/add.single.LUT.r")
source("Slitasje og Egnethet.Scripts/Scripts/add.joint.LUT.r")

#### READ LOOKUP TABLES

LUT.dir<-"Slitasje og Egnethet.LookUpTables/"

VegDur.LUT<-read.csv(file=paste0(LUT.dir,"Vegetation.LUT.csv"),stringsAsFactors=FALSE)
Slope.LUT<-read.csv(file=paste0(LUT.dir,"Slope.LUT.csv"),stringsAsFactors=FALSE)

V.sens.LUT<-read.csv(file=paste0(LUT.dir,"Vegetation.sensitivity.LUT.csv"),stringsAsFactors=FALSE)
E.sens.slopebased.LUT<-read.csv(file=paste0(LUT.dir,"Erosion.sensitivity(slope-based).LUT.csv"),stringsAsFactors=FALSE)
N.egne.LUT<-read.csv(file=paste0(LUT.dir,"Naturens.egnethet.LUT.csv"),stringsAsFactors=FALSE)

### (NB: CHANGE THE VARIABLE TRAILNAME TO CONTROL WHICH PARK IS PROCESSED)

#### DIRECTORIES AND NAMES

TRAILNAME<-"Langsua"
#TRAILNAME<-"Sjunkhatten"


if (TRAILNAME=="Langsua") {

  INTER<-10
    
#### DIRECTORIES AND NAMES - LANGSUA

  Trail.dir<-"Slitasje og Egnethet.GISdata/LangsuaVectors/"
  Trail.name<-"Langsua_NP_network_trails_cleaned"
  TrailObs.outname<-"Langsua_trailObs_EGNET.v2"
  Trail.outname<-"Langsua_trails_EGNET.v2"

  DEM.dir<-"Slitasje og Egnethet.GISdata/LangsuaRasters/"
  DEM.name<-"Langsua_DTM1m_filled_merged.tif"

  TWI.dir<-"Slitasje og Egnethet.GISdata/LangsuaRasters/"
  TWI.name<-"Langsua_TWI_1m_25833.tif"
  
  TWI.LUT.name<-"Langsua.TWI.1m.LUT.csv"
  
  Veg.dir<-"Slitasje og Egnethet.GISdata/LangsuaRasters/"
  Veg.name<-"Langsua_Vegetasjon_25833.tif"
  
}



if(TRAILNAME=="Sjunkhatten") {

  INTER<-10
  
  
#### DIRECTORIES AND NAMES - SJUNKHATTEN

  Trail.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenVectors/"
  Trail.name<-"Sjunk_NP_network_trails"
  TrailObs.outname<-"Sjunkhatten_trailObs_EGNET.v2"
  Trail.outname<-"Sjunkhatten_trails_EGNET.v2"

  DEM.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenRasters/"
  DEM.name<-"Sjunkhatten_DEM1m_filled.tif"
  
  TWI.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenRasters/"
  TWI.name<-"Sjunkhatten_TWI_10m_25833.tif"
  
  TWI.LUT.name<-"Sjunkhatten.TWI.10m.LUT.csv"
  
  Veg.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenRasters/"
  Veg.name<-"Sjunkhatten_vegetasjon_25833.tif"
  
}

## READ DATA

setwd(paste0(DISK.DIR,Trail.dir))
Trail<-readOGR(dsn=".", layer=Trail.name)

setwd(paste0(DISK.DIR,DEM.dir))
DEM <- raster(DEM.name)

setwd(paste0(DISK.DIR,TWI.dir))
TWI <- raster(TWI.name)

setwd(paste0(DISK.DIR,LUT.dir))
TWI.LUT<-read.csv(TWI.LUT.name,stringsAsFactors=FALSE)
  
setwd(paste0(DISK.DIR,Veg.dir))
Veg<-raster(Veg.name)



plot(DEM); plot(Trail,add=TRUE)
plot(TWI); plot(Trail,add=TRUE)
plot(Veg); plot(Trail,add=TRUE)


##########

# 1) Calculation of slope

Trail$path_id<-as.character(Trail$path_id)
IDU<-unique(Trail$path_id)
IDUL<-length(IDU)

C.ls<-list()  
for (j in 1:IDUL)
{
print(paste("Trail",j,"of",IDUL))
  tf<-Trail$path_id==IDU[j]
  Sub<-Trail[tf,]

    g<-sample.line(Sub, d = 1, offset=0,type = "regular",longlat=FALSE)

    C<-data.frame(coordinates(g))
    colnames(C)<-c("x","y")
    xy<-data.frame(C$x,C$y); colnames(xy)<-c("x","y")
    plot(xy,type="l")

    CL<-nrow(C)
    if(CL>=11)
    {
      C$DEM<-extract(DEM, xy)
    C$Vert<-NA
    C$Vert[seq(INTER,CL,INTER)]<-"Y"

    C$DEM.min5<-c(rep(NA,5),C$DEM[1:(CL-5)])
    C$DEM.plus5<-c(C$DEM[6:CL],rep(NA,5))
    C$DEMchange<-c(C$DEM.plus5-C$DEM.min5)
    C$SlopePer<-abs(C$DEMchange*100/10)
    tf<-!is.na(C$Vert); C<-C[tf,]
    if(sum(!is.na(C$SlopePer))>0)
      {
      C$Vert<-C$DEM.min5<-C$DEM.plus5<-C$DEMchange<-NULL
      C$path_ID<-IDU[j]
      CL<-nrow(C)
      C$point_ID<-seq(1,CL)
      C.ls[[j]]<-C
      }
    }
  }

Tr<-bind_rows(C.ls) 

# STIENS_HELNINGSGRAD

Tr$StiHelnKla<-add.slope.LUT(Tr$SlopePer,Slope.LUT)

#### EXTRACT VARIABLES AND CLASSIFI USING LUTs

Tr.c<-Tr[,1:2]

# 2) TWI and jordfuktighet (TWIklasse)

Tr$TWI<-extract(TWI, Tr.c)
Tr$TWIklasse<-add.TWI.LUT(Tr$TWI,TWI.LUT)

# 3) Vegetasjonsklasse

Tr$Vegkode<-extract(Veg, Tr.c)
Tr$Vegetasjon<-VegDur.LUT$Vegetasjonsklasse[match(Tr$Vegkode,VegDur.LUT$Kode)]
Tr$Vegklasse<-VegDur.LUT$Klasse[match(Tr$Vegkode,VegDur.LUT$Kode)]


# 5) Vegetasjons sensitivitet

Tr$VEG_SENS<-add.joint.LUT(Tr$Vegklasse, Tr$TWIklasse, V.sens.LUT$Vegklasse, V.sens.LUT$TWIklasse, V.sens.LUT$V.sens)

# 6) Erosjons utsatt

Tr$ERO_UT.Slo<-add.single.LUT(Tr$StiHelnKla, E.sens.slopebased.LUT$Helnklasse, E.sens.slopebased.LUT$E.sens)
          
# 7) Naturens egnethet

Tr$NAT_EGN.Es<-add.joint.LUT(Tr$VEG_SENS, Tr$ERO_UT.Slo, N.egne.LUT$V.sens, N.egne.LUT$E.sens, N.egne.LUT$Val.E)
Tr$NAT_EGN.Es<-factor(Tr$NAT_EGN.Es,levels=c("Lite egnet","Middels egnet","Potensielt godt egnet"))

#8) Trail naturens egnethet

x<-table(Tr$path_ID,Tr$NAT_EGN.Es)
xsum<-apply(x,1,sum)
for (i in 1:3)
{
  x[,i]<-x[,i]*100/xsum
}

STI_EGNE<-rep(NA,length(xsum))
tf<-x[,1]>50; STI_EGNE[tf]<-"Lite egnet"
tf<-x[,3]>50; STI_EGNE[tf]<-"Potensielt godt egnet"
tf<-x[,1]<=50 & x[,3]<=50; STI_EGNE[tf]<-"Middels egnet"

xID<-rownames(x)
STI_EGNE<-STI_EGNE[match(IDU,xID)]


Trail$STI_EGNE<-STI_EGNE
Tr$STI_EGNE<-STI_EGNE[match(Tr$path_ID,IDU)]

#####
# WRITE DATA
#####

CRS<-"+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
setwd(paste0(DISK.DIR,Trail.dir))

#9) WRITE TRAIL OBSERVATIONS

write.csv(file=paste0(TrailObs.outname,".csv"),Tr,row.names=FALSE)
Tr.coords<-Tr[,1:2]
Tr.spdf <- SpatialPointsDataFrame(Tr.coords, Tr)
crs(Tr.spdf)<-CRS
writeOGR(Tr.spdf, ".", TrailObs.outname, driver="ESRI Shapefile",overwrite_layer=TRUE)

### WRITE SUITABILITY PER TRAIL

crs(Trail) <- CRS
writeOGR(Trail, ".", Trail.outname, driver="ESRI Shapefile",overwrite_layer=TRUE)


