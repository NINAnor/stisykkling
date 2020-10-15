add.single.LUT<-function(D1,L1,Var){
  DL<-length(D1)
  Out<-rep(NA,DL)
  L<-length(L1)
  for (i in 1:L)
  {
    tf<-D1==L1[i]; tf[is.na(tf)]<-FALSE
    Out[tf]<-Var[i]
  }
  return(Out)
}
