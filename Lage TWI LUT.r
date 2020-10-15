
rm(list=ls())

library(raster)

DISK.DIR<-"P:/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/"

### READ TOPOGRAPHIC WETNESS INDEX FILES

Raster.dir<-paste0(DISK.DIR,"Slitasje og Egnethet.GISdata/LangsuaRasters/")
setwd(Raster.dir)
L.TWI.10m<-raster("Langsua_TWI_10m_InPark_25833.tif")
L.TWI.1m<-raster("Langsua_TWI_1m_InPark_25833.tif")

Raster.dir<-paste0(DISK.DIR,"Slitasje og Egnethet.GISdata/SjunkhattenRasters/")
setwd(Raster.dir)
S.TWI.10m<-raster("Sjunkhatten_TWI_10m_InPark_25833.tif")
S.TWI.1m<-raster("Sjunk_ValTrail_TWI1m_cleaned.tif")

plot(L.TWI.1m)
plot(L.TWI.10m)
plot(S.TWI.1m)
plot(S.TWI.10m)

### ASSIGN NA TO WATER COVERED AREAS IN SJUNKHATTEN
values(S.TWI.10m)[values(S.TWI.10m) >= 9.21 & values(S.TWI.10m) <= 9.215 ] = NA
plot(S.TWI.10m)


### EXTRACT VALUES

L10<-values(L.TWI.10m); L10<-na.omit(L10)
S10<-values(S.TWI.10m); S10<-na.omit(S10)
S1<-values(S.TWI.1m); S1<-na.omit(S1)

# NB: EXTRACTION FROM L.TWI.1m ONLY USES A SUBSET OF DATA BECAUSE FILE IS TOO LARGE TO EXTRACT ALL VALUES
L1.ls<-list()
for (i in seq(1,29645,50))
{
  print(i)
  L1<-values(L.TWI.1m,row=i); L1<-na.omit(L1)
  L1.ls[[i]]<-L1
}
L1<-unlist(L1.ls)

### EXTRACT SUMMARIES

Lq1<-summary(L1)
Lq10<-summary(L10)
Sq1<-summary(S1)
Sq10<-summary(S10)

### CREATE TWI LOOK-UP-TABLES FROM SUMMARIES

Klasse<-c("Tørt","Middels fuktig","Fuktig")
Min<-c(Lq1[c(1,2,5)])
Max<-c(Lq1[c(2,5,6)])
Langsua.TWI.1m.LUT<-data.frame(Min,Max,Klasse)
Langsua.TWI.1m.LUT$Min[1]<-Langsua.TWI.1m.LUT$Min[1]-1
Langsua.TWI.1m.LUT$Max[3]<-Langsua.TWI.1m.LUT$Max[3]+1

Klasse<-c("Tørt","Middels fuktig","Fuktig")
Min<-c(Lq10[c(1,2,5)])
Max<-c(Lq10[c(2,5,6)])
Langsua.TWI.10m.LUT<-data.frame(Min,Max,Klasse)
Langsua.TWI.10m.LUT$Min[1]<-Langsua.TWI.10m.LUT$Min[1]-1
Langsua.TWI.10m.LUT$Max[3]<-Langsua.TWI.10m.LUT$Max[3]+1

Klasse<-c("Tørt","Middels fuktig","Fuktig")
Min<-c(Sq1[c(1,2,5)])
Max<-c(Sq1[c(2,5,6)])
Sjunkhatten.TWI.1m.LUT<-data.frame(Min,Max,Klasse)
Sjunkhatten.TWI.1m.LUT$Min[1]<-Sjunkhatten.TWI.1m.LUT$Min[1]-1
Sjunkhatten.TWI.1m.LUT$Max[3]<-Sjunkhatten.TWI.1m.LUT$Max[3]+1

Klasse<-c("Tørt","Middels fuktig","Fuktig")
Min<-c(Sq10[c(1,2,5)])
Max<-c(Sq10[c(2,5,6)])
Sjunkhatten.TWI.10m.LUT<-data.frame(Min,Max,Klasse)
Sjunkhatten.TWI.10m.LUT$Min[1]<-Sjunkhatten.TWI.10m.LUT$Min[1]-1
Sjunkhatten.TWI.10m.LUT$Max[3]<-Sjunkhatten.TWI.10m.LUT$Max[3]+1

### SAVE LOOK-UP-TABLES

LUT.dir<-paste0(DISK.DIR,"Slitasje og Egnethet.LookUpTables/")
setwd(LUT.dir)

write.csv(file="Langsua.TWI.1m.LUT.csv",Langsua.TWI.1m.LUT)
write.csv(file="Langsua.TWI.10m.LUT.csv",Langsua.TWI.10m.LUT)
write.csv(file="Sjunkhatten.TWI.1m.LUT.csv",Sjunkhatten.TWI.1m.LUT)
write.csv(file="Sjunkhatten.TWI.10m.LUT.csv",Sjunkhatten.TWI.10m.LUT)







