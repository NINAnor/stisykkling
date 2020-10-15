
rm(list=ls())

library(rgdal)

DISK.DIR<-"P:/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/"
setwd(DISK.DIR)

#TRAILNAME<-"LangsuaValidation"
TRAILNAME<-"SjunkhattenValidation"


if(TRAILNAME=="LangsuaValidation") {
ValidationData.dir<-"Slitasje og Egnethet.GISdata/LangsuaValidationData/"
ValidationData.name<-"Langsua.ValTrail.csv"
Trail.dir<-"Slitasje og Egnethet.GISdata/LangsuaValidationData/"
TrailObs.name<-"Langsua_Validation_trailObs_EGNET"
TrailOut.name<-"Langsua_FieldGIS"
}

if(TRAILNAME=="SjunkhattenValidation") {
ValidationData.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenValidationData/"
ValidationData.name<-"Sjunkhatten.ValTrail.csv"
Trail.dir<-"Slitasje og Egnethet.GISdata/SjunkhattenValidationData/"
TrailObs.name<-"Sjunkhatten_Validation_trailObs_EGNET"
TrailOut.name<-"Sjunkhatten_FieldGIS"
}

#######

D<-read.csv(file=paste0(ValidationData.dir,ValidationData.name),stringsAsFactors=FALSE)

setwd(Trail.dir)
Trail<-readOGR(dsn=".", layer=TrailObs.name)
Trail$NewID<-seq(1,nrow(Trail))


###########

options(warn=1)
D$NewID<-NA
DL<-nrow(D)
for (i in 1:DL)
{
  print(i)
    Dist<-sqrt( (Trail$x-D$x[i])^2+(Trail$y-D$y[i])^2 )
      tf<-Dist==min(Dist); D$NewID[i]<-Trail$NewID[tf]
}

D$Slope.GIS<-Trail$SlopePer[match(D$NewID,Trail$NewID)]
D$TWI.GIS<-Trail$TWI[match(D$NewID,Trail$NewID)]
D$LMklasse.GIS<-Trail$LMklasse[match(D$NewID,Trail$NewID)]
D$Vegklasse.GIS<-Trail$Vegklasse[match(D$NewID,Trail$NewID)]
D$VEG_SENS.GIS<-Trail$VEG_SENS[match(D$NewID,Trail$NewID)]

D$ERO_UT.Slo.GIS<-Trail$ERO_UT_Slo[match(D$NewID,Trail$NewID)]
D$ERO_UT.LM.GIS<-Trail$ERO_UT_LM[match(D$NewID,Trail$NewID)]
D$NAT_EGNE_A<-Trail$NAT_EGNE_A[match(D$NewID,Trail$NewID)]
D$NAT_EGNE_B<-Trail$NAT_EGNE_B[match(D$NewID,Trail$NewID)]
D$NAT_EGNE_C<-Trail$NAT_EGNE_C[match(D$NewID,Trail$NewID)]
D$NAT_EGNE_D<-Trail$NAT_EGNE_D[match(D$NewID,Trail$NewID)]
D$NAT_EGNE_E<-Trail$NAT_EGNE_E[match(D$NewID,Trail$NewID)]
D$NAT_EGN_Es<-Trail$NAT_EGN_Es[match(D$NewID,Trail$NewID)]


boxplot(D$Slope.GIS~D$Slope.surv)
boxplot(D$TWI.GIS~D$Fuk.surv)
table(D$LMklasse.GIS,D$LMklasse.surv)
table(D$VEG_SENS.GIS,D$VEG_SENS.SURV)


write.csv(file=paste0(TrailOut.name,".csv"),D)


############



