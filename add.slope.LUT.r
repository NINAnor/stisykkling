
add.slope.LUT<-function(slope,Slope.LUT){
  slopeL<-length(slope)
  Klasse<-rep(NA,slopeL)
  for(i in 1:3)
  {
    tf<-slope>=Slope.LUT$Min[i] & slope<=Slope.LUT$Max[i]
    Klasse[tf]<-as.character(Slope.LUT$Klasse[i])
  }
  return(Klasse)
}