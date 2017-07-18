#Limpiar variables
rm(list=ls())

##Leer datos desde excel
require(readxl)
##Nombre del archivo a leer
metrica <- read_excel("open_tables.xlsx")

##Generar series de tiempo
l<-dim(metrica)[1]-1
#dat <- data.frame(metrica)
dat <- data.frame(metrica,
                  Date = seq(as.Date("2017-01-17"), as.Date("2017-01-17") + l, by = 1))

require(xts)
#dat.ts <- xts(dat$Valor)

dat <- xts(dat$open_tables, order.by=as.Date(dat$Date))
dat<-scale(dat)+1.13

#Cargar librería forecasting
library(fpp)
library(fpp2)

#Definir variables iniciales
bestrmse5<-10000000000000
bestrmse4<-10000000000000



bestmse5<-0
bestmse4<-0




bestmae5<-0
bestmae4<-0


bestmape5<-0
bestmape4<-0

beste4<-0
beste5<-0



bestalpha4<-0
bestbeta4<-0
bestphi4<-0


bestalpha5<-0
bestbeta5<-0
bestphi5<-0

l<-dim(dat)[1]

for (a in seq(0.9,0.01,-0.2))
{
  for(b in seq(0.9,0.01,-0.12))
  {
    for(pi in seq(0.8,0.98,0.02))
    {
      
      
      e4 <- tsCV(dat, holt, h=1,damped=TRUE,alpha=a,beta=b,phi=pi)
      e5 <- tsCV(dat, holt, h=1,exponential=TRUE,damped=TRUE,alpha=a,beta=b,phi=pi)
      
      
     
      rmse4<-sqrt(mean(e4^2, na.rm=TRUE))
      rmse5<-sqrt(mean(e5^2, na.rm=TRUE))
      
      if(rmse4<=bestrmse4)
      {
        bestrmse4<-rmse4
        bestalpha3<-a
        bestbeta3<-b
        bestmse4<-mean(e4^2, na.rm=TRUE)
        bestmae4<-mean(abs(e4),na.rm=TRUE)
        beste4<-e4
      }
      
      
      
      if(rmse5<=bestrmse5)
      {
        bestrmse5<-rmse5
        bestalpha5<-a
        bestbeta5<-b
        bestphi5<-pi
        bestmse5<-mean(e5^2, na.rm=TRUE)
        bestmae5<-mean(abs(e5),na.rm=TRUE)
        beste5<-e5
        
      }
    }
  }
}

