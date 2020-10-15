
add.TWI.LUT<-function(TWI,TWI.LUT){
  TWIL<-length(TWI)
  Klasse<-rep(NA,TWIL)
  for(i in 1:3)
  {
    tf<-TWI>=TWI.LUT$Min[i] & TWI<=TWI.LUT$Max[i]
    Klasse[tf]<-as.character(TWI.LUT$Klasse[i])
  }
  return(Klasse)
}