*Holt Linear Trend Scala*

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


//Leer datos y ajustar para su procesamiento
case class Obs(clas: Double, Tout: Double, Error: Double, DiskA: Double, 
	Tin: Double, RamF: Double, DiskU: Double, RamU: Double)

def parseObs(line: Array[Double]): Obs = {
    Obs(
      if (line(7) == 1.0) 1 else 0, line(0), line(1), line(2), line(3), 
	  line(4), line(5), line(6) )       }
	
def parseRDD(rdd: RDD[String]): RDD[Array[Double]] = {
    rdd.map(_.split(",")).map(_.drop(1)).map(_.map(_.toDouble))
}

val rdd = sc.textFile("spark-1.6.0-bin-hadoop2.6/examples/src/main/resources/datat.txt")
val obsRDD = parseRDD(rdd).map(parseObs)
val obsDF = obsRDD.toDF().cache()
obsDF.registerTempTable("obs")

val featureCols = Array("DiskU")
val assembler = new VectorAssembler().setInputCols(featureCols).setOutputCol("featuresv")
val df2 = assembler.transform(obsDF)


val data = df2.select("DiskU").rdd.map{case Row(v: Double) =>v}.toArray

////Dividir los datos
//val splitSeed = 5043
//val Array(trainingData, testData) = df2.randomSplit(Array(0.7, 0.3), splitSeed)
//val dataTrain = trainingData.select("DiskU").rdd.map{case Row(v: Double) =>v}.toArray
//val dataTest  = testData.select("DiskU").rdd.map{case Row(v: Double) =>v}.toArray

val mean   = data.sum/data.length
val devs   = data.map(score => (score-mean) * (score-mean))
val stddev = math.sqrt(devs.sum / (data.length-1))


val vectorn = new ArrayBuffer[Double]()
for (i <- 0 to data.length-1){
	vectorn+=(data(i)-mean)/(stddev)
}

val vector  = vectorn.toArray


//Definir función HOLT
def holt(series:Array[Double],alpha:Double,beta:Double,h:Int)= { 
     val result = new ArrayBuffer[Double]()
     val level = new ArrayBuffer[Double]()
     val trend = new ArrayBuffer[Double]()
     val lastlevel = new ArrayBuffer[Double]()
     result += series(1)
  
     for ( n <- 1 until (series.length+h) )
	{
	if (n==1){
		level += series(0)
		trend += series(1) - series(0) }
	if (n >= series.length){
		lastlevel += level.last 
		level += alpha * result.last + (1-alpha) * (level.last+trend.last)
		trend += beta  * (level.last - lastlevel.last) + (1-beta) * trend.last 
		result += level(n)+trend(n) }
	else {
		lastlevel += level.last 
		level += alpha * series(n) + (1 - alpha) * (level.last + trend.last)
		trend += beta  * (level.last - lastlevel.last) + (1-beta) * trend.last
		result += level(n) + trend(n)} 	
	}
     result }

	 
//Entrenar el modelo y calcular errores
val resforecast   = new ArrayBuffer[Double]()
val respredict    = new ArrayBuffer[Double]()
val residualsmse  = new ArrayBuffer[Double]()
val residualsmae  = new ArrayBuffer[Double]()
val residualsmape = new ArrayBuffer[Double]()
respredict += vector(0)
respredict += vector(1)

for(i <- 2 until (vector.length) )
{
	val result     = holt((vector.slice(0,i)),0.9,0.4,1)
	val forecast   = holt((vector.slice(0,vector.length)),0.9,0.4,1)
  	resforecast   += forecast(vector.length)
	respredict    += result(i)
 	residualsmse  += math.pow(vector(i) - result(i),2)
	residualsmae  += math.abs(vector(i)-result(i))
	residualsmape += math.abs((vector(i)-result(i))/vector(i))
}

val mse  =  residualsmse.sum/residualsmse.length
val rmse =  math.sqrt(residualsmse.sum/residualsmse.length) 
val mae  =  residualsmae.sum/residualsmae.length
val mape =  (100./residualsmape.length)*(residualsmape.sum)



//Recuperar datos ajustados al modelo a escala inicial
val VectorPredict = new ArrayBuffer[Double]()
for (i <- 0 to data.length-1){
	VectorPredict+=(respredict(i)*stddev)+mean
}

//Obtener residuos en escala normal
val residualsv = new ArrayBuffer[Double]()
for (i <- 0 until vector.length){
	residualsv += data(i)-VectorPredict(i)
}
	
//ACF
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

val residuals =residualsv.toArray
val ac = acf(residuals)

//Histogramm
def hist(residuals:Array[Double])= { 

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

val histogram = hist(residuals)

//Calcular intervalos de confianza

val forecast = new ArrayBuffer[Double]()
forecast += resforecast(0)

respredict+= forecast(0)


val meanfor   = respredict.sum/respredict.length
val devsfor   = respredict.map(score => (score-meanfor) * (score-meanfor))
val stddevfor = math.sqrt(devsfor.sum / (respredict.length-1))


val int95inf = forecast(0)- (1.96*stddevfor)
val int95med = forecast(0)
val int95sup = forecast(0)+ (1.96*stddevfor)


val int80inf = forecast(0)- (1.28*stddevfor)
val int80med = forecast(0)
val int80sup = forecast(0)+ (1.28*stddevfor)


val VectorForecast95 = new ArrayBuffer[Double]()
VectorForecast95 += (int95inf*stddev)+mean
VectorForecast95 += (int95med*stddev)+mean
VectorForecast95 += (int95sup*stddev)+mean

val VectorForecast80 = new ArrayBuffer[Double]()
VectorForecast80 += (int80inf*stddev)+mean
VectorForecast80 += (int80med*stddev)+mean
VectorForecast80 += (int80sup*stddev)+mean
	
	
	
	
	
	
	