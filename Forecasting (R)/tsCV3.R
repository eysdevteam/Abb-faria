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
dat<-ts(dat,frequency = 4)

#Cargar librería forecasting
library(fpp)
library(fpp2)

#Definir variables iniciales

bestrmse8<-10000000000000
bestrmse7<-10000000000000
bestrmse6<-10000000000000

bestmse8<-0
bestmse7<-0
bestmse6<-0

bestmae8<-0
bestmae7<-0
bestmae6<-0


bestmape8<-0
bestmape7<-0
bestmape6<-0

bestalpha6<-0
bestbeta6<-0
bestgamma6<-0

bestalpha7<-0
bestbeta7<-0
bestgamma7<-0

bestalpha8<-0
bestbeta8<-0
bestgamma8<-0

beste6<-0
beste7<-0
beste8<-0

l<-dim(dat)[1]

for (a in seq(0.9,0.01,-0.2))
{
  for(b in seq(0.9,0.01,-0.2))
  {
    for(g in seq(0.9,0.01,-0.2))
    {
      
      e6 <- tsCV(dat, hw, h=1,  seasonal="additive" )
      e7 <- tsCV(dat, hw, h=1,  seasonal="multiplicative" )
      e8 <- tsCV(dat, hw, h=1,  seasonal="multiplicative",damped=TRUE)
      
      
      rmse6<-sqrt(mean(e6^2, na.rm=TRUE))
      rmse7<-sqrt(mean(e7^2, na.rm=TRUE))
      rmse8<-sqrt(mean(e8^2, na.rm=TRUE))
      
      
      if(rmse6<=bestrmse6)
      { 
        bestrmse6<-rmse6
        bestalpha6<-a
        bestbeta6<-b
        bestmse6<-mean(e6^2, na.rm=TRUE)
        bestmae6<-mean(abs(e6),na.rm=TRUE)
        bestgamma6<-g
        beste6<-e6
        
      }
      
      if(rmse7<=bestrmse7)
      { 
        bestrmse7<-rmse7
        bestalpha7<-a
        bestbeta7<-b
        bestmse7<-mean(e7^2, na.rm=TRUE)
        bestmae7<-mean(abs(e7),na.rm=TRUE)
        bestgamma7<-g
        beste7<-e7
        
      }
      
      if(rmse8<=bestrmse8)
      {
        bestrmse8<-rmse8
        bestalpha8<-a
        bestbeta8<-b
        bestmse8<-mean(e8^2, na.rm=TRUE)
        bestmae8<-mean(abs(e8),na.rm=TRUE)
        bestgamma8<-g
        beste8<-e8
        
      }
      
    }
  }
}

#Graficar resultados
plot(bestfit1,  ylab="Bits", xlab="Día", 
     fcol="white", plot.conf=FALSE)
lines(fitted(bestfit1), col="blue") 
lines(bestfit1$mean, col="blue", type="l") 
legend("topleft", lty=1, col=c("black","blue"), 
       c("Datos","Modelo predictivo"))


##Exportar a JSON
library(RJSONIO)
#Guardar cada variable en una fila
a<-matrix(c(t(dat)),nrow = l, ncol = 1, byrow = FALSE)
c<-matrix(c(t(bestfit1$fitted)),nrow = l, ncol = 1, byrow = FALSE)
d<-matrix(c(t(bestfit1$mean)),nrow = 1, ncol = 1, byrow = FALSE)

#Dejar filas del mismo tamaño
y<-matrix(c(rep(NaN,1)),nrow = l, ncol = 1)
z<- matrix(c(rep(NaN,1)),nrow = 1, ncol = 1)
g<-matrix(c(seq(NaN,1)),nrow=1,ncol=1)

a<-rbind(a,z)
b<-rbind(b,z)
c<-rbind(c,z)
d<-rbind(y,d)

#Concatenar en una matriz
list1<-cbind(a,c,d)

#Generar archivo
exportJson <- toJSON(list1)
write(exportJson, "RamLibre.json")

