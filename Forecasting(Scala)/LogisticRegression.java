** Regresión Logistica Scala **

//**Cargar librerias necesarias 
import org.apache.spark._
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.SQLContext
import org.apache.spark.ml.feature.{StringIndexer, VectorAssembler,Normalizer}
import org.apache.spark.ml.evaluation.{BinaryClassificationEvaluator, BinaryClassificationMetrics}
import org.apache.spark.ml.classification.{LogisticRegression,BinaryLogisticRegressionSummary}
import org.apache.spark.sql.functions._
import org.apache.spark.mllib.linalg.DenseVector
import org.apache.spark.ml.Pipeline


//**Cargar y analizar la Data provieniento de un archivo txt(csv) ** 

// Definir el esquema de la data, variables y tipo.
case class Obs(clas: Double, Tout: Double, Error: Double, DiskA: Double, 
	Tin: Double, RamF: Double, DiskU: Double, RamU: Double)

// Crear una clase Obs de una matriz Double 
def parseObs(line: Array[Double]): Obs = {
    Obs(
      if (line(7) == 1.0) 1 else 0, line(0), line(1), line(2), line(3), 
	  line(4), line(5), line(6) )       }
	
// Transformar un RDD de cadenas en un RDD Double. Eliminar primera columna.
def parseRDD(rdd: RDD[String]): RDD[Array[Double]] = {
    rdd.map(_.split(",")).map(_.drop(1)).map(_.map(_.toDouble))
}

// Cargar la dtaa en un DataFrame**
val rdd = sc.textFi= parseRDD(rdd).map(parseObs)
val obsDF = obsRDD.toDF().cache()
obsDF.registerTempTable("obs")

// Mostrar el esquema del DataFrame**
obsDF.printSchema

// Mostrar 20 columnas del DataFrame**
obsDF.show

// Describir estadísticas de cálculo para la columna "thickness" , incluyendo count, mean, stddev, min, y max
obsDF.describe("thickness").show

//Más estadísticas en https://mapr.com/blog/predicting-breast-cancer-using-apache-spark-machine-learning-logistic-regression/

//**Extracción de características**

//Definir las columnas de características para poner en el vector de características 
val featureCols = Array("Tout","Error", "DiskA", "Tin", "RamF", "DiskU", "RamU")
//Establecer las columnas de entrada y salida 
val assembler = new VectorAssembler().setInputCols(featureCols).setOutputCol("featuresv")
//devuelve un marco de datos con todas las columnas de características en una columna vectorial 
val df2 = assembler.transform(obsDF)
// El método de transformación produjo una nueva columna: features.
df2.show

//  Crear la columna de etiqueta (valor de la salida) con StringIndexer, normalizar los datos, dividirlos y entrenar modelo
//Definiendo etapas de pipline
val labelIndexer = new StringIndexer().setInputCol("clas").setOutputCol("label").fit(df2)
val normalizer = new Normalizer().setInputCol("featuresv").setOutputCol("features").setP(2.0)
val splitSeed = 5043
val Array(trainingData, testData) = df2.randomSplit(Array(0.7, 0.3),sql)
val lr = new LogisticRegression()

val pipeline = new Pipeline().setStages(Array(normalizer,labelIndexer,lr))
val df3 = pipeline.fit(trainingData)



 

//**Evauluar el modelo**


// Ejecutar el modelo en las características de prueba para obtener predicciones 
val predictions = model.transform(testData)

// Como se puede ver, la transformación del modelo anterior produjo una nueva columna: Prediccióy yrobabilidad
predictions.show

//Obter area bajo la curva
// Crear un Evaluador para la clasificación binaria, que espera dos columnas de entrada: Predicción y etiqueta 
val evaluator = new BinaryClassificationEvaluator().setLabelCol("label").setRawPredictionCol("rawPrediction").setMetricName("areaUnderROC")

//Evalúa predicciones y devuelve  área bajo la curva
val accuracy = evaluator.evaluate(predictions)

// Métricas
val lp = predictions.select( "label", "prediction")
val counttotal = predictions.count()
val correct = lp.filter($"label" === $"prediction").count()
val wrong = lp.filter(not($"label" === $"prediction")).count()
val truep = lp.filter($"prediction" === 0.0).filter($"label" === $"prediction").count()
val falseN = lp.filter($"prediction" === 0.0).filter(not($"label" === $"prediction")).count()
val falseP = lp.filter($"prediction" === 1.0).filter(not($"label" === $"prediction")).count()
val ratioWrong=wrong.toDouble/counttotal.toDouble
val ratioCorrect=correct.toDouble/counttotal.toDouble

// Utilizar MLlib para evaluar, convertir DF a RDD 
val  predictionAndLabels =predictions.select("rawPrediction", "label").rdd.map(x => (x(0).asInstanceOf[DenseVector](1), x(1).asInstanceOf[Double]))
val metrics = new BinaryClassificationMetrics(predictionAndLabels)
println("Area bajo la curva (precision-recall) : " + metrics.areaUnderPR)
println("ROC : " + metrics.areaUnderROC)


