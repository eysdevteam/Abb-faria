
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
dat<-scale(dat)+1.63

#Cargar librería forecasting
library(fpp)
library(fpp2)


l<-dim(dat)[1]



    
fit1<-ets(dat, model="ANN")
  
fit2<-ets(dat, model="MNN")
  
fit3<-ets(dat, model="AAN")

fit4<-ets(dat, model="MAN")
    
   