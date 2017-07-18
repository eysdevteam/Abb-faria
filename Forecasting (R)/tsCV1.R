##Lectura datos a trata
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

dat <- xts(dat$open_valor, order.by=as.Date(dat$Date))
dat<-scale(dat)+1.13


##Inicio algoritmo
#Cargar librería forecasting
library(fpp)
library(fpp2)

#Definir variables iniciales

bestrmse3<-10000000000000
bestrmse2<-10000000000000
bestrmse1<-10000000000000

bestmse3<-0
bestmse2<-0
bestmse1<-0


bestmae3<-0
bestmae2<-0
bestmae1<-0


bestmape3<-0
bestmape2<-0
bestmape1<-0

bestalpha1<-0
bestbeta1<-0

bestalpha2<-0
bestbeta2<-0

bestalpha3<-0
bestbeta3<-0

beste1<-0
beste2<-0
beste3<-0

l<-dim(dat)[1]

for (a in seq(0.9,0.01,-0.2))
{
  for(b in seq(0.9,0.01,-0.2))
  {
  
      
      e1 <- tsCV(dat, ses, h=1,alpha=a)
      e2 <- tsCV(dat, holt, h=1,alpha=a,beta=b)
      e3 <- tsCV(dat, holt, h=1,exponential=TRUE,alpha=a,beta=b)
      

      
      rmse1<-sqrt(mean(e1^2, na.rm=TRUE))
      rmse2<-sqrt(mean(e2^2, na.rm=TRUE))
      rmse3<-sqrt(mean(e3^2, na.rm=TRUE))


      if(rmse1<=bestrmse1)
      { 
        bestrmse1<-rmse1
        bestalpha1<-a
        bestbeta1<-b
        bestmse1<-mean(e1^2, na.rm=TRUE)
        bestmae1<-mean(abs(e1),na.rm=TRUE)
        beste1<-e1
      }
      
      if(rmse2<=bestrmse2)
      { 
        bestrmse2<-rmse2
        bestalpha2<-a
        bestbeta2<-b
        bestmse2<-mean(e2^2, na.rm=TRUE)
        bestmae2<-mean(abs(e2),na.rm=TRUE)
        beste2<-e2
      }
      
      
        
      if(rmse3<=bestrmse3)
      {
        bestrmse3<-rmse3
        bestalpha3<-a
        bestbeta3<-b
        bestmse3<-mean(e3^2, na.rm=TRUE)
        bestmae3<-mean(abs(e3),na.rm=TRUE)
        beste3<-e3
      }
    
  }
}

 #Graficar resultados
plot(bestfit1,  ylab="Bits", xlab="Día", 
     fcol="white", plot.conf=FALSE)
lines(fitted(bestfit1), col="blue") 
lines(bestfit1$mean, col="blue", type="o") 
legend("topleft", lty=1, col=c("black","blue"), 
       c("Datos","Modelo predictivo"))


##Exportar a JSON
library(RJSONIO)
#Guardar cada variable en una fila
a<-matrix(c(t(dat.ts)),nrow = l, ncol = 1, byrow = FALSE)
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

