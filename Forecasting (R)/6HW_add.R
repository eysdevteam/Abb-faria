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
fit1 <- hw(dat.ts,seasonal="additive")
l<-length(dat.ts)
error<-0
for (i in 1:l)
{
  error[i] <- sqrt(((dat.ts[i] - fit1$fitted[i])^2)/l)
}
sse<-sum(error)

error2<-0



plot(fit1,ylab="International visitor night in Australia (millions)",
     plot.conf=FALSE, type="o", fcol="white", xlab="Year")
lines(fitted(fit1), col="red", lty=2)
lines(fit1$mean, type="o", col="red")
legend("topleft",lty=1, pch=1, col=1:3, 
       c("data","Holt Winters' Additive"))




