rm(list=ls())

##Leer datos desde excel
require(readxl)
RamLibre <- read_excel("queries.xlsx")

##Generar series de tiempo
l<-dim(RamLibre)[1]-1
#dat <- data.frame(RamLibre)
dat <- data.frame(RamLibre,
                  Date = seq(as.Date("2017-01-17"), as.Date("2017-01-17") + l, by = 1))

dat.ts<-ts(dat$queries,frequency = 4)

##Aplicar modelo
library(fpp)
fit2 <- hw(dat.ts,seasonal="multiplicative")
l<-length(dat.ts)



error2<-0
for (j in 1:l)
{
  error2[j] <- sqrt(((dat.ts[i] - fit2$fitted[i])^2)/l)
}
sse2<-sum(error2)



  
  plot(fit2,ylab="International visitor night in Australia (millions)",
       plot.conf=FALSE, type="o", fcol="white", xlab="Year")
  lines(fitted(fit2), col="green", lty=2)
  lines(fit2$mean, type="o", col="green")
  legend("topleft",lty=1, pch=1, col=1:3, 
  c("data","Holt Winters' Multiplicative"))

