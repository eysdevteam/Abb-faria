#Limpiar variables
rm(list=ls())

##Leer datos desde excel
require(readxl)
queries <- read_excel("queries.xlsx")

##Generar series de tiempo
l<-dim(queries)[1]-1
#dat <- data.frame(queries)
dat <- data.frame(queries,
                  Date = seq(as.Date("2017-01-17"), as.Date("2017-01-17") + l, by = 1))

require(xts)
#dat.ts <- xts(dat$Valor)

dat <- xts(dat$queries, order.by=as.Date(dat$Date))

#Cargar librería forecasting
library(fpp)
library(fpp2)


#Definir variables iniciales
error<-0
bestmse<-10000000000000
bestalpha<-0
bestbeta<-0
fit1<-0
l<-dim(dat)[1]
dat<-scale(dat)
for (a in seq(0.9,0,-0.2))
{
 for(b in seq(0.9,0.01,-0.12))
{
 for(pi in seq(0.8,0.98,0.02))
{
    
    for (i in 1:l)
    {
      dat.cv<-dat[i]
      dat.ts<-dat[-i]
      fit1 <- holt(dat.ts, alpha=a, beta=b,phi=pi, h=1,damped = TRUE) 
      error[i]<-(fit1$mean-dat.cv)
    }
    
    mse<-sum(error^2)/l
    #Determinar si es el menor error
    if(mse<=bestmse)
     
    {
      bestmse<-mse
      bestalpha<-a
      bestfit1<-fit1
      bestrmse<-sqrt(bestmse)
      bestmae<-sum(abs(error))/l
      bestmape<-(sum(abs(error)/queries)/l)*100
    }
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

