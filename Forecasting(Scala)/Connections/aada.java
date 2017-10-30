//Importar librerías
import scala.collection.mutable.ArrayBuffer
import scala.io.Source
import org.apache.spark._
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{SQLContext,Row}
import org.apache.spark.ml.feature.StringIndexer
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.sql.functions._
import org.apache.spark.mllib.linalg.{DenseVector,Vector}
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.ml.feature.{Normalizer,StandardScaler}
import org.apache.spark.sql.Row
import org.apache.spark.sql.types._


//Leer datos y ajustar para su procesamiento
case class Obs(clas: Int, Time: Double, TrafO: Double, Error: Double, 
	DiskA: Double, TrafI: Double, RamA: Double, label: Double)

def parseObs(line: Array[Double]): Obs = {
    Obs(
      if (line(7) == 1.0) 1 else 0, line(0), line(1), line(2), line(3), 
	  line(4), line(5), line(6) )       }
	
def parseRDD(rdd: RDD[String]): RDD[Array[Double]] = {
    rdd.map(_.split(",")).map(_.drop(0)).map(_.map(_.toDouble))
}

val rdd = sc.textFile("/home/ed/spark-1.6.0-bin-hadoop2.6/examples/src/main/resources/connections.txt")
val obsRDD = parseRDD(rdd).map(parseObs)
val obsDF = obsRDD.toDF().cache()
obsDF.registerTempTable("obs")



val featureCols = Array("Time")
val assembler = new VectorAssembler().setInputCols(featureCols).setOutputCol("features")
val df2 = assembler.transform(obsDF)
val data = df2.select("label").rdd.map{case Row(v: Double) =>v}.toArray


val vectorn = new ArrayBuffer[Double]()
for (i <- 0 to data.length-1){
	vectorn+=math.log(data(i))
}

val df3 = df2.drop(df2.col("label"))

val rdd= sc.parallelize(vectorn.toList)
val rdd_new = df3.rdd.zip(rdd).map(r =>Row.fromSeq(r._1.toSeq++Seq(r._2)))
val df4 = sqlContext.createDataFrame(rdd_new,df3.schema.add("label",DoubleType))
val vector  = vectorn.toArray


//Regresión lineal 10 primeros paraemtros
import org.apache.spark.ml.regression.LinearRegression
val lr = new LinearRegression() .setRegParam(1)  .setElasticNetParam(0.8)
val lrModel = lr.fit(df2.limit(10)) 


//Definir función AAdA
def AAdA(series:Array[Double],alpha:Double,beta:Double,gamma:Double,phi:Double,h:Int,ept:Double)= { 
     
     val result = new ArrayBuffer[Double]()
     val level = new ArrayBuffer[Double]()
     val trend = new ArrayBuffer[Double]()
     val lastlevel = new ArrayBuffer[Double]()
     val lasttrend = new ArrayBuffer[Double]()
     val et        = new ArrayBuffer[Double]()
	 	
  
    //level += 11.9367
    //trend += -0.229 
    level += vector.slice(0,4).sum/4
	trend += ((vector.slice(4,8).sum/4) - level.last)/4
	
	
	val seasonal0  = new ArrayBuffer[Double]()
	val seasonal   = new ArrayBuffer[Double]()
	val lastseasonal  = new ArrayBuffer[Double]()

	val a = vector.slice(0,4)
	seasonal0 +=   a(0) - level.last
	seasonal0 +=   a(1) - level.last
	seasonal0 +=   a(2) - level.last
	seasonal0 +=   a(3) - level.last
	
	//seasonal0 +=   0.002
	//seasonal0 +=  -0.0019
	//seasonal0 +=  -0.0016 
	//seasonal0 +=   0.0016
	val m = 4
		
 for ( n <- 0 until (series.length+h) )
{	

	if (n < series.length)
	{
		lastlevel += level.last
		lasttrend += trend.last
		
		if( n >  (m-1)) 
		{
			lastseasonal += seasonal(n-(m-1))
		}
		else 
		{
			lastseasonal += seasonal0(n)
		}
		
		et += series(n)-lastlevel.last-lasttrend.last-lastseasonal.last
		level    += lastlevel.last + phi*lasttrend.last +  (et.last*alpha)
		trend    += phi*lasttrend.last +  (et.last*beta*alpha)
		seasonal += lastseasonal.last + gamma*et.last
		result   += lastlevel.last + phi*lasttrend.last + lastseasonal.last
	}
	if (n >= series.length)
	{
		lastlevel += level.last
		lasttrend += trend.last
		lastseasonal += seasonal(n-(m-1))

		et += ept
		level    += lastlevel.last + phi*lasttrend.last +  (et.last*alpha)
		trend    += phi*lasttrend.last +  (et.last*beta*alpha)
		seasonal += lastseasonal.last + gamma*et.last
		result   += lastlevel.last + phi*lasttrend.last + lastseasonal.last
	}	
	
}
     result 
}

	
//Entrenar el modelo y calcular errores

val resforecast   = new ArrayBuffer[Double]()
val respredict    = new ArrayBuffer[Double]()
val residualsmse  = new ArrayBuffer[Double]()	
val residualsmae  = new ArrayBuffer[Double]()
val residualsmape = new ArrayBuffer[Double]()
val residualsmean = new ArrayBuffer[Double]()

val lik   = new ArrayBuffer[Double]()	
val rmse  = new ArrayBuffer[Double]()	
val mse   = new ArrayBuffer[Double]()	
val mae   = new ArrayBuffer[Double]()
val mape  = new ArrayBuffer[Double]()
val mean  = new ArrayBuffer[Double]()

val bestresiduals = new ArrayBuffer[Double]()
val bestloglik 	  = new ArrayBuffer[Double]()
val bestlik  	  = new ArrayBuffer[Double]()
val bestaic  	  = new ArrayBuffer[Double]()
val bestbic  	  = new ArrayBuffer[Double]()
val bestaicc 	  = new ArrayBuffer[Double]()
val bestrmse  	  = new ArrayBuffer[Double]()
val bestmae  	  = new ArrayBuffer[Double]()
val bestmape 	  = new ArrayBuffer[Double]()
val bestmse 	  = new ArrayBuffer[Double]()
val bestmean  	  = new ArrayBuffer[Double]()
val bestalpha  	  = new ArrayBuffer[Double]()
val bestbeta  	  = new ArrayBuffer[Double]()
val bestgamma     = new ArrayBuffer[Double]()
val bestphi   	  = new ArrayBuffer[Double]()

bestlik += (1000000)

//Entrenar el modelo y calcular errores

val resforecast   = new ArrayBuffer[Double]()
val respredict    = new ArrayBuffer[Double]()
val residualsmse  = new ArrayBuffer[Double]()	
val residualsmae  = new ArrayBuffer[Double]()
val residualsmape = new ArrayBuffer[Double]()
val residualsmean = new ArrayBuffer[Double]()

val lik   = new ArrayBuffer[Double]()	
val rmse  = new ArrayBuffer[Double]()	
val mse   = new ArrayBuffer[Double]()	
val mae   = new ArrayBuffer[Double]()
val mape  = new ArrayBuffer[Double]()
val mean  = new ArrayBuffer[Double]()

val bestresiduals = new ArrayBuffer[Double]()
val bestloglik 	  = new ArrayBuffer[Double]()
val bestlik  	  = new ArrayBuffer[Double]()
val bestaic  	  = new ArrayBuffer[Double]()
val bestbic  	  = new ArrayBuffer[Double]()
val bestaicc 	  = new ArrayBuffer[Double]()
val bestrmse  	  = new ArrayBuffer[Double]()
val bestmae  	  = new ArrayBuffer[Double]()
val bestmape 	  = new ArrayBuffer[Double]()
val bestmse 	  = new ArrayBuffer[Double]()
val bestmean  	  = new ArrayBuffer[Double]()
val bestalpha  	  = new ArrayBuffer[Double]()
val bestbeta  	  = new ArrayBuffer[Double]()
val bestgamma  	  = new ArrayBuffer[Double]()
val bestphi   	  = new ArrayBuffer[Double]()

bestlik += (1000000)


//time series Cross Validation 
//Generar valores alaeatorios y escoger los que generen el minimo Likelihood
//Siempre y cuanodo alpha sea mayor a beta
for (a<-1 to 3)
{
	for(b <- 1 to 100)
	{
		
		val r = scala.util.Random
		r.setSeed(1000*a*a)
		val alpha = r.nextDouble
		val beta  = r.nextDouble
		val gamma  = r.nextDouble/5
		val phi = (80 + r.nextInt(( 98 - 80) + 1)).toDouble/100

			
		//val alpha =  0.9998
		//val beta  =  1e-04
		//val gamma =  2e-04 
		//val phi   =  0.8893 
		
		if(alpha>beta && gamma < (1-alpha))
		{

			for(i <- 3 until (vector.length) )
			{
				val result     = AAdA((vector.slice(0,i)),alpha,beta,gamma,phi,1,0)
				val forecast   = AAdA((vector.slice(0,vector.length)),alpha,beta,gamma,phi,1,0)
				resforecast   += forecast(vector.length)

				if(i==2){
					respredict+=result(0)
					respredict+=result(1)
					respredict+=result(i)	
					}
				else {
					respredict+=result(i) 
					}	
				residualsmse  += math.pow(vector(i) -result(i),2)
				residualsmae  += math.abs(vector(i)-result(i))
				residualsmape += math.abs((vector(i)-result(i))/vector(i))
				residualsmean += vector(i) -result(i)

			}

				lik  += 1910*math.log(residualsmse.sum)
				mse  +=  residualsmse.sum/residualsmse.length
				rmse +=  math.sqrt(residualsmse.sum/residualsmse.length) 
				mae  +=  residualsmae.sum/residualsmae.length
				mape +=  (100./residualsmape.length)*(residualsmape.sum)
				mean += residualsmean.sum/residualsmean.length


				if(lik.last < bestlik.last && alpha>beta)
				{
				bestlik    += lik.last
				bestloglik += -0.5*lik.last
				bestaic    += lik.last + (2*4)
				bestbic    +=  lik.last + (math.log(vector.length)*4)
				bestaicc   += bestaic.last + ((2*4*(4+1))/(vector.length-4-1))
				bestmse	  += mse.last	 
				bestrmse  += rmse.last
				bestmae	  += mae.last
				bestmape  += mape.last   
				bestmean  += mean.last
				bestalpha += alpha
				bestbeta  += beta
				bestgamma += gamma
				bestphi   += phi
				}
		}
		
	}		
}

//Recuperar datos ajustados al modelo a escala inicial
val VectorPredict = new ArrayBuffer[Double]()
for (i <- 0 to data.length-1){
	VectorPredict+=math.pow(math.E,respredict(i))
}

//Obtener residuos 
val residualsv = new ArrayBuffer[Double]()
for (i <- 0 until vector.length){
	residualsv += data(i)-VectorPredict(i)
}
	
//Generar funcion de ACF
def acf(d:Array[Double])= { 
	val ac = new ArrayBuffer[Double]()
	for(k <- 0 until d.length){

		val a = new ArrayBuffer[Double]()
		val b = new ArrayBuffer[Double]()
		val mean = d.sum/d.length

		for ( i <- 0+k until d.length){
	    		a+=(d(i)-mean)*(d(i-k)-(mean))}

		for ( i <- 0 until d.length){
    		b+=math.pow((d(i)-mean),2)}
		ac += a.sum/b.sum}
		ac
}

//Calcular ACF de los residuos
val residuals =residualsv.toArray
val ac = acf(residuals)

val facf = ac.slice(0,20)
val count  = new ArrayBuffer[Double]()
val position  = new ArrayBuffer[Double]()

for ( i <- 0 until 20)
{
  if( facf(i)> 2/math.sqrt(vector.length))
  {
	count += facf(i)
	position += i
  }
}
//Generar funcion del histograma
def histogram(residuals:Array[Double])= { 

	val classdown = new ArrayBuffer[Double]()
	val classup   = new ArrayBuffer[Double]()


	val range = residuals.max-residuals.min
	val cw =  math.ceil(range/6).toInt

	classdown += math.ceil(residuals.min).toInt
	classup    += classdown.last+cw
	classdown  += classup.last
	classup    += classdown.last+cw
	classdown  += classup.last
	classup    += classdown.last+cw
	classdown  += classup.last
	classup    += classdown.last+cw
	classdown  += classup.last
	classup    += classdown.last+cw
	classdown  += classup.last
	classup    += classdown.last+cw

	var frecuency1 = 0
	var frecuency2 = 0
	var frecuency3 = 0
	var frecuency4 = 0
	var frecuency5 = 0
	var frecuency6 = 0

	for(i<- 0 until residuals.length){
	if(residuals(i) >= classdown(0) && residuals(i)<classup(0)){
		frecuency1+=1}
	else if(residuals(i) >= classdown(1) && residuals(i)<classup(1)){
		frecuency2+=1}
	else if(residuals(i) >= classdown(2) && residuals(i)<classup(2)){
		frecuency3+=1}
	else if(residuals(i) >= classdown(3) && residuals(i)<classup(3)){
		frecuency4+=1}
	else if(residuals(i) >= classdown(4) && residuals(i)<classup(4)){
		frecuency5+=1}
	else { frecuency6+=1 }
	}

	val Frecuency = new ArrayBuffer[Double]()
	Frecuency+=frecuency1
	Frecuency+=frecuency2
	Frecuency+=frecuency3
	Frecuency+=frecuency4
	Frecuency+=frecuency5
	Frecuency+=frecuency6


	val x =Array.ofDim[Double](1,6,3)
	for(i<-0 until classup.length){

	x(0)(i)(0)=classdown(i)
	x(0)(i)(1)=classup(i)
	x(0)(i)(2)=Frecuency(i)
	}

	x}


//Obtener histograma residuos
val hist = histogram(residuals)




//Entrenar modelo para realizar prónostic
val Pron1  = new ArrayBuffer[Double]()
val Pron2  = new ArrayBuffer[Double]()
val Pron3  = new ArrayBuffer[Double]()
val Pron4  = new ArrayBuffer[Double]()
val Pron5  = new ArrayBuffer[Double]()
val Pron6  = new ArrayBuffer[Double]()
val Pron7  = new ArrayBuffer[Double]()
val Pron8  = new ArrayBuffer[Double]()
val Pron9  = new ArrayBuffer[Double]()
val Pron10  = new ArrayBuffer[Double]()
val Pron11  = new ArrayBuffer[Double]()
val Pron12  = new ArrayBuffer[Double]()
val Pron13  = new ArrayBuffer[Double]()
val Pron14  = new ArrayBuffer[Double]()
val Pron15  = new ArrayBuffer[Double]()
val Pron16  = new ArrayBuffer[Double]()


val rand = new scala.util.Random(1509)
val et  = new ArrayBuffer[Double]()
//Generar los 5000 errores con distribución normal 
for(i <- 0 until 5000)
{

et +=  math.log(rand.nextGaussian()+1)

val fit = AAdA(vector,bestalpha.last,bestbeta.last,bestphi.last,bestgamma.last,16,et.last)
	
val VectorForecast = new ArrayBuffer[Double]()

	for (j <- data.length until fit.length)
	{

		VectorForecast += fit(j)
		
	}
	
	Pron1  += VectorForecast(0)
	Pron2  += VectorForecast(1)
	Pron3  += VectorForecast(2)
	Pron4  += VectorForecast(3)
	Pron5  += VectorForecast(4)
	Pron6  += VectorForecast(5)
	Pron7  += VectorForecast(6)
	Pron8  += VectorForecast(7)
	Pron9  += VectorForecast(8)
	Pron10 += VectorForecast(9)
	Pron11 += VectorForecast(10)
	Pron12 += VectorForecast(11)
	Pron13 += VectorForecast(12)
	Pron14 += VectorForecast(13)
	Pron15 += VectorForecast(14)
	Pron16 += VectorForecast(15)
	
}

//Obtener promedio de las 5000 predicciones
val mean = new ArrayBuffer[Double]()

 mean  += Pron1.sum/Pron1.length
 mean  += Pron2.filter(x => !x.isNaN).sum/Pron2.filter(x => !x.isNaN).length
 mean  += Pron3.filter(x => !x.isNaN).sum/Pron3.filter(x => !x.isNaN).length
 mean  += Pron4.filter(x => !x.isNaN).sum/Pron4.filter(x => !x.isNaN).length
 mean  += Pron5.filter(x => !x.isNaN).sum/Pron5.filter(x => !x.isNaN).length
 mean  += Pron6.filter(x => !x.isNaN).sum/Pron6.filter(x => !x.isNaN).length
 mean  += Pron7.filter(x => !x.isNaN).sum/Pron7.filter(x => !x.isNaN).length
 mean  += Pron8.filter(x => !x.isNaN).sum/Pron8.filter(x => !x.isNaN).length
 mean  += Pron9.filter(x => !x.isNaN).sum/Pron9.filter(x => !x.isNaN).length
 mean  += Pron10.filter(x => !x.isNaN).sum/Pron10.filter(x => !x.isNaN).length
 mean  += Pron11.filter(x => !x.isNaN).sum/Pron11.filter(x => !x.isNaN).length
 mean  += Pron12.filter(x => !x.isNaN).sum/Pron12.filter(x => !x.isNaN).length
 mean  += Pron13.filter(x => !x.isNaN).sum/Pron13.filter(x => !x.isNaN).length
 mean  += Pron14.filter(x => !x.isNaN).sum/Pron14.filter(x => !x.isNaN).length
 mean  += Pron15.filter(x => !x.isNaN).sum/Pron15.filter(x => !x.isNaN).length
 mean  += Pron16.filter(x => !x.isNaN).sum/Pron16.filter(x => !x.isNaN).length



val fit = AAdA(vector,bestalpha.last,bestbeta.last,bestphi.last,bestgamma.last,16,0)
//Recuperar datos ajustados al modelo a escala inicial
val VectorPredict = new ArrayBuffer[Double]()
val ep = new ArrayBuffer[Double]()

//OBtener residuos
for (i <- 0 until data.length)
{
	VectorPredict+=fit(i)
	ep += math.pow(vector(i)-fit(i),2)
}

val sd = ep.sum*math.pow(1910,-1)

//Intervalos de pronosctico con la escala real

val VectorForecast1 = new ArrayBuffer[Double]()
VectorForecast1 += math.pow(math.E,mean(0)) 
VectorForecast1 += math.pow(math.E,(mean(0) - (0.7019*sd)))
VectorForecast1 += math.pow(math.E,mean(0) + (0.7019*sd))

val VectorForecast2 = new ArrayBuffer[Double]()
VectorForecast2 += math.pow(math.E,mean(1))
VectorForecast2 += math.pow(math.E,(mean(1) - (0.7019*sd)))
VectorForecast2 += math.pow(math.E,mean(1) + (0.7019*sd))

val VectorForecast3 = new ArrayBuffer[Double]()
VectorForecast3 += math.pow(math.E,mean(2))
VectorForecast3 += math.pow(math.E,(mean(2) - (0.7019*sd)))
VectorForecast3 += math.pow(math.E,mean(2) + (0.7019*sd))

val VectorForecast4 = new ArrayBuffer[Double]()
VectorForecast4 += math.pow(math.E,mean(3))
VectorForecast4 += math.pow(math.E,(mean(3) - (0.7019*sd)))
VectorForecast4 += math.pow(math.E,mean(3) + (0.7019*sd))

val VectorForecast5 = new ArrayBuffer[Double]()
VectorForecast5 += math.pow(math.E,mean(4) )
VectorForecast5 += math.pow(math.E,(mean(4) - (0.7019*sd)))
VectorForecast5 += math.pow(math.E,mean(4) + (0.7019*sd))

val VectorForecast6 = new ArrayBuffer[Double]()
VectorForecast6 += math.pow(math.E,mean(5))
VectorForecast6 += math.pow(math.E,(mean(5) - (0.7019*sd)))
VectorForecast6 += math.pow(math.E,mean(5) + (0.7019*sd))

val VectorForecast7 = new ArrayBuffer[Double]()
VectorForecast7 += math.pow(math.E,mean(6) )
VectorForecast7 += math.pow(math.E,(mean(6) - (0.7019*sd)))
VectorForecast7 += math.pow(math.E,mean(6) + (0.7019*sd))

val VectorForecast8 = new ArrayBuffer[Double]()
VectorForecast8 += math.pow(math.E,mean(7))
VectorForecast8 += math.pow(math.E,(mean(7) - (0.7019*sd)))
VectorForecast8 += math.pow(math.E,mean(7) + (0.7019*sd))

val VectorForecast9 = new ArrayBuffer[Double]()
VectorForecast9 += math.pow(math.E,mean(8) )
VectorForecast9 += math.pow(math.E,(mean(8) - (0.7019*sd)))
VectorForecast9 += math.pow(math.E,mean(8) + (0.7019*sd))

val VectorForecast10 = new ArrayBuffer[Double]()
VectorForecast10 += math.pow(math.E,mean(9) )
VectorForecast10 += math.pow(math.E,(mean(9) - (0.7019*sd)))
VectorForecast10 += math.pow(math.E,mean(9) + (0.7019*sd))

val VectorForecast11 = new ArrayBuffer[Double]()
VectorForecast11 += math.pow(math.E,mean(10) )
VectorForecast11 += math.pow(math.E,(mean(10) - (0.7019*sd)))
VectorForecast11 += math.pow(math.E,mean(10) + (0.7019*sd))

val VectorForecast12 = new ArrayBuffer[Double]()
VectorForecast12 += math.pow(math.E,mean(11))
VectorForecast12 += math.pow(math.E,(mean(11) - (0.7019*sd)))
VectorForecast12 += math.pow(math.E,mean(11) + (0.7019*sd))

val VectorForecast13 = new ArrayBuffer[Double]()
VectorForecast13 += math.pow(math.E,mean(12) )
VectorForecast13 += math.pow(math.E,(mean(12) - (0.7019*sd)))
VectorForecast13 += math.pow(math.E,mean(12) + (0.7019*sd))

val VectorForecast14 = new ArrayBuffer[Double]()
VectorForecast14 += math.pow(math.E,mean(13) )
VectorForecast14 += math.pow(math.E,(mean(13) - (0.7019*sd)))
VectorForecast14 += math.pow(math.E,mean(13) + (0.7019*sd))

val VectorForecast15 = new ArrayBuffer[Double]()
VectorForecast15 += math.pow(math.E,mean(14) )
VectorForecast15 += math.pow(math.E,(mean(14) - (0.7019*sd)))
VectorForecast15 += math.pow(math.E,mean(14) + (0.7019*sd))

val VectorForecast16 = new ArrayBuffer[Double]()
VectorForecast16 += math.pow(math.E,mean(15) )
VectorForecast16 += math.pow(math.E,(mean(15) - (0.7019*sd)))
VectorForecast16 += math.pow(math.E,mean(15) + (0.7019*sd))
val a = vector.slice(0,4)

println(" ")

println("*******************************************************")
println("*********************************************")
println("***********************************")
println("*************************")
println("**************")
println("****** LOS RESULTADOS")
println("****** OBTENIDOS SON:")
println("**************")
println("*************************")
println("***********************************")
println("*********************************************")
println("*******************************************************")

println(" ")
println("***Estados iniciales***")
println("Alpha : " + bestalpha.last)
println("Beta : " + bestbeta.last)
println("Gamma : " + bestgamma.last)
println("Phi : " + bestphi.last)

println("lo : " +   vector.slice(0,4).sum/4)
println("bo : " +   (((vector.slice(4,8).sum/4) - vector.slice(0,4).sum/4)/4))
println("so : " +   (a(0) - (vector.slice(0,4).sum/4))  )
println("s1 : " +   (a(1) - (vector.slice(0,4).sum/4))  )
println("s2 : " +   (a(2) - (vector.slice(0,4).sum/4)) )
println("s3 : " +   (a(3) - (vector.slice(0,4).sum/4))  )

println(" ")


println("***Métricas de rendimiento***")
println("LogLik : " + bestloglik.last)
println("Lik : " + bestlik.last)
println("AIC : " + bestaic.last)
println("BIC : " + bestbic.last)
println("AICc : " + bestaicc.last)

println("MSE : " + bestmse.last)
println("RMSE : " + bestrmse.last)
println("MAE : " + bestmae.last)
println("MAPE : " + bestmape.last)

println(" ")

println("***Análisis de residuales***")
println("ACF : " + ac.slice(0,20)) 
 println("ACF >> : " + count)  
 println("ACF >> : " + position)
println(" ")

println("El histograma de los residuos: ")
println("................................ Inf ...... Sup ... Freq .....") 

hist(0)(0)
hist(0)(1)
hist(0)(2)
hist(0)(3)
hist(0)(4)
hist(0)(5)

println(" ")

println("MEAN : " + bestmean.last)

println(" ")

println("***Intervalos de confianza***") 
println("......................... Forecast .......... Inferior...........Superior..........") 

println("1911 : " + VectorForecast1)
println("1912 : " + VectorForecast2)
println("1913 : " + VectorForecast3)
println("1914 : " + VectorForecast4)
println("1915 : " + VectorForecast5)
println("1916 : " + VectorForecast6)
println("1917 : " + VectorForecast7)
println("1918 : " + VectorForecast8)
println("1919 : " + VectorForecast9)
println("1920 : " + VectorForecast10)
println("1921 : " + VectorForecast11)
println("1922 : " + VectorForecast12)
println("1923 : " + VectorForecast13)
println("1924 : " + VectorForecast14)
println("1925 : " + VectorForecast15)
println("1926 : " + VectorForecast16)














