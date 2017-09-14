*SES Scala*

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



case class Obs(clas: Double, Tout: Double, Error: Double, DiskA: Double, 
	Tin: Double, RamF: Double, DiskU: Double, RamU: Double)

def parseObs(line: Array[Double]): Obs = {
    Obs(
      if (line(7) == 1.0) 1 else 0, line(0), line(1), line(2), line(3), 
	  line(4), line(5), line(6) )       }
	
def parseRDD(rdd: RDD[String]): RDD[Array[Double]] = {
    rdd.map(_.split(",")).map(_.drop(1)).map(_.map(_.toDouble))
}

val rdd = sc.textFile("spark-1.6.0-bin-hadoop2.6/examples/src/main/resources/datatotal.txt")
val obsRDD = parseRDD(rdd).map(parseObs)
val obsDF = obsRDD.toDF().cache()
obsDF.registerTempTable("obs")



val featureCols = Array("DiskU")
val assembler = new VectorAssembler().setInputCols(featureCols).setOutputCol("featuresv")
val df2 = assembler.transform(obsDF)


val scaler = new StandardScaler().setInputCol("featuresv").setOutputCol("features").setWithStd(true).setWithMean(true)

val scalerModel  = scaler.fit(df2)

val scaledData = scalerModel.transform(df2)

val fin = scaledData.select("features").rdd.map {case Row(v: Vector) => v}

fin.saveAsTextFile("out")


//Leer datos limpios
val data = Source.fromFile("data.txt").getLines.toArray.map(_.toDouble)

//Normalizar los datos
val vectorn = new ArrayBuffer[Double]()
for (i <- 0 to data.length-1){
	vectorn+=(data(i)-data.min)/(data.max-data.min)
}
val vector  = vectorn.toArray


//Definir función SES
def exponential(series:Array[Double],alpha:Double)= { 
     val result = new ArrayBuffer[Double]()
     
     for ( n <- 1 until (series.length+1) ){
	if (n==1){
		result += series(0)}
	if (n >= series.length){
		result += alpha * result.last + (1-alpha) * result(n-1) }
	else { 
		result += alpha * series(n) + (1-alpha) * result(n-1) }
        } 
     result }

	 
//Entrenar el modelo
val result = exponential(vector,0.9)

//Calcular errores
val residuals = new ArrayBuffer[Double]()
for (i <- 0 to vector.length-1){
	residuals += math.pow((vector(i)-result(i)),2)}
	
val mse = residuals.sum/vector.length
val rmse = math.sqrt(residuals.sum/vector.length) 

val residuals = new ArrayBuffer[Double]()
for (i <- 0 to vector.length-1){
	residuals += math.abs((vector(i)-result(i)))}

val mae = residuals.sum/vector.length

val residuals = new ArrayBuffer[Double]()
for (i <- 0 to vector.length-1){
	residuals += math.abs((vector(i)-result(i)))/vector(i)}


val mape = 100*(residuals.sum/vector.length)


//Agrupar predicciones
val predictions = new ArrayBuffer[Double]()
for (j <- vector.length to result.length-1){
	predictions += result(j)}

result -= result.last

//Recuperar datos ajustados al modelo a escala inicial
val VectorPredict = new ArrayBuffer[Double]()
for (i <- 0 to data.length-1){
	VectorPredict+=data.min+(result(i)*(data.max-data.min))

}

//Calcular intervalos de confianza
val mean   = VectorPredict.sum/vector.length
val devs   = VectorPredict.map(score => (score-mean) * (score-mean))
val stddev = math.sqrt(devs.sum / (vector.length-1))

//Recuperar predicción a escala real
val VectorForecast = new ArrayBuffer[Double]()
VectorForecast+=data.min+(predictions(0)*(data.max-data.min))

val int95 = Vector(VectorForecast(0)+ (1.96*stddev), VectorForecast(0)- (1.96*stddev))
val int80 = Vector(VectorForecast(0)+ (1.28*stddev), VectorForecast(0)- (1.28*stddev))
	
	
	
	
	
	
	
	
	