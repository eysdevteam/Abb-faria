//Importar librerÃƒÂ­as
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
import org.apache.spark.ml.feature.PCA
import java.util.Calendar
import org.apache.hadoop.fs._;



//Leer datos y ajustar para su procesamiento
case class Obs1( id: Int, q1: Int, q2: Int, 
	q3: Int, q4: Int, q5: Int, q6: Int, q7: Int, q8: Int, q9: Int, q10: Int, q11: Int, q12: Int, q13: Int)

case class Obs2( id: Int, q1: Int, q2: Int, 
	q3: Int, q4: Int, q5: Int, q6: Int, q7: Int, q8: Int, q9: Int, q10: Int, q11: Int, q12: Int, q13: Int, q14: Int)
 
case class Obs3( id: Int, q1: Int, q2: Int, 
	q3: Int, q4: Int, q5: Int, q6: Int)
 
case class Obs4( id: Int, q1: Int, q2: Int, 
	q3: Int, q4: Int, q5: Int, q6: Int, q7: Int, q8: Int, q9: Int, q10: Int, q11: Int, q12: Int)



def parseObs1(line: Array[Int]): Obs1 = {
    Obs1( line(0), line(1), line(2), line(3), line(4), line(5), line(6), line(7), line(8), line(9), line(10), line(11), line(12), line(13)   )     }

def parseObs2(line: Array[Int]): Obs2 = {
    Obs2( line(0), line(1), line(2), line(3), line(4), line(5), line(6), line(7), line(8), line(9), line(10), line(11), line(12), line(13), line(14) ) }
    
def parseObs3(line: Array[Int]): Obs3 = {
    Obs3( line(0), line(1), line(2), line(3), line(4), line(5), line(6) ) }
    
def parseObs4(line: Array[Int]): Obs4 = {
    Obs4( line(0), line(1), line(2), line(3), line(4), line(5), line(6), line(7), line(8), line(9), line(10), line(11), line(12) ) }



def parseRDD1(rdd: RDD[String]): RDD[Array[Int]] = {
    rdd.map(_.split(",")).map(_.drop(0)).map(_.map(_.toInt))}

def parseRDD2(rdd: RDD[String]): RDD[Array[Int]] = {
    rdd.map(_.split(",")).map(_.drop(0)).map(_.map(_.toInt))}	
    
def parseRDD3(rdd: RDD[String]): RDD[Array[Int]] = {
    rdd.map(_.split(",")).map(_.drop(0)).map(_.map(_.toInt))}
    
def parseRDD4(rdd: RDD[String]): RDD[Array[Int]] = {
    rdd.map(_.split(",")).map(_.drop(0)).map(_.map(_.toInt))}
	
 
 
val rdd1 = sc.textFile("/home/edgar/Escritorio/DataIPS/Nacionales/seccion1.txt")
val rdd2 = sc.textFile("/home/edgar/Escritorio/DataIPS/Nacionales/seccion2.txt")
val rdd3 = sc.textFile("/home/edgar/Escritorio/DataIPS/Nacionales/seccion3.txt")
val rdd4 = sc.textFile("/home/edgar/Escritorio/DataIPS/Nacionales/seccion4.txt")



val Obs1RDD = parseRDD1(rdd1).map(parseObs1)
val Obs2RDD = parseRDD2(rdd2).map(parseObs2)
val Obs3RDD = parseRDD3(rdd3).map(parseObs3)
val Obs4RDD = parseRDD4(rdd4).map(parseObs4)



val df1 = Obs1RDD.toDF().cache()
val df2 = Obs2RDD.toDF().cache()
val df3 = Obs3RDD.toDF().cache()
val df4 = Obs4RDD.toDF().cache()



df1.registerTempTable("obs1")
df2.registerTempTable("obs2")
df3.registerTempTable("obs3")
df4.registerTempTable("obs4")



//Calcular el percentil de la seccion1 por cada una de de las preguntas
val per11  = df1.stat.approxQuantile("q1",Array(0.75),0)
val per12  = df1.stat.approxQuantile("q2",Array(0.75),0)
val per13  = df1.stat.approxQuantile("q3",Array(0.75),0)
val per14  = df1.stat.approxQuantile("q4",Array(0.75),0)
val per15  = df1.stat.approxQuantile("q5",Array(0.75),0)
val per16  = df1.stat.approxQuantile("q6",Array(0.75),0)
val per17  = df1.stat.approxQuantile("q7",Array(0.75),0)
val per18  = df1.stat.approxQuantile("q8",Array(0.75),0)
val per19  = df1.stat.approxQuantile("q9",Array(0.75),0)
val per110 = df1.stat.approxQuantile("q10",Array(0.75),0)
val per111 = df1.stat.approxQuantile("q11",Array(0.75),0)
val per112 = df1.stat.approxQuantile("q12",Array(0.75),0)
val per113 = df1.stat.approxQuantile("q13",Array(0.75),0)

//Calcular el percentil de la seccion2 por cada una de de las preguntas
val per21  = df2.stat.approxQuantile("q1",Array(0.75),0)
val per22  = df2.stat.approxQuantile("q2",Array(0.75),0)
val per23  = df2.stat.approxQuantile("q3",Array(0.75),0)
val per24  = df2.stat.approxQuantile("q4",Array(0.75),0)
val per25  = df2.stat.approxQuantile("q5",Array(0.75),0)
val per26  = df2.stat.approxQuantile("q6",Array(0.75),0)
val per27  = df2.stat.approxQuantile("q7",Array(0.75),0)
val per28  = df2.stat.approxQuantile("q8",Array(0.75),0)
val per29  = df2.stat.approxQuantile("q9",Array(0.75),0)
val per210 = df2.stat.approxQuantile("q10",Array(0.75),0)
val per211 = df2.stat.approxQuantile("q11",Array(0.75),0)
val per212 = df2.stat.approxQuantile("q12",Array(0.75),0)
val per213 = df2.stat.approxQuantile("q13",Array(0.75),0)
val per214 = df2.stat.approxQuantile("q14",Array(0.75),0)

//Calcular el percentil de la seccion3 por cada una de de las preguntas
val per31  = df2.stat.approxQuantile("q1",Array(0.75),0)
val per32  = df2.stat.approxQuantile("q2",Array(0.75),0)
val per33  = df2.stat.approxQuantile("q3",Array(0.75),0)
val per34  = df2.stat.approxQuantile("q4",Array(0.75),0)
val per35  = df2.stat.approxQuantile("q5",Array(0.75),0)
val per36  = df2.stat.approxQuantile("q6",Array(0.75),0)

//Calcular el percentil de la seccion4 por cada una de de las preguntas
val per41  = df2.stat.approxQuantile("q1",Array(0.75),0)
val per42  = df2.stat.approxQuantile("q2",Array(0.75),0)
val per43  = df2.stat.approxQuantile("q3",Array(0.75),0)
val per44  = df2.stat.approxQuantile("q4",Array(0.75),0)
val per45  = df2.stat.approxQuantile("q5",Array(0.75),0)
val per46  = df2.stat.approxQuantile("q6",Array(0.75),0)
val per47  = df2.stat.approxQuantile("q7",Array(0.75),0)
val per48  = df2.stat.approxQuantile("q8",Array(0.75),0)
val per49  = df2.stat.approxQuantile("q9",Array(0.75),0)
val per410 = df2.stat.approxQuantile("q10",Array(0.75),0)
val per411 = df2.stat.approxQuantile("q11",Array(0.75),0)
val per412 = df2.stat.approxQuantile("q12",Array(0.75),0)



//Almacenar en un solo Array el percentil de cada pregunta de la sección 1 
val distance1 = new ArrayBuffer[Double]()
distance1 += per11(0)
distance1 += per12(0)
distance1 += per13(0)
distance1 += per14(0)
distance1 += per15(0)
distance1 += per16(0)
distance1 += per17(0)
distance1 += per18(0)
distance1 += per19(0)
distance1 += per110(0)
distance1 += per111(0)
distance1 += per112(0)
distance1 += per113(0)

//Almacenar en un solo Array el percentil de cada pregunta de la sección 2 
val distance2 = new ArrayBuffer[Double]()
distance2 += per21(0)
distance2 += per22(0)
distance2 += per23(0)
distance2 += per24(0)
distance2 += per25(0)
distance2 += per26(0)
distance2 += per27(0)
distance2 += per28(0)
distance2 += per29(0)
distance2 += per210(0)
distance2 += per211(0)
distance2 += per212(0)
distance2 += per213(0)
distance2 += per214(0)

//Almacenar en un solo Array el percentil de cada pregunta de la sección 3
val distance3 = new ArrayBuffer[Double]()
distance3 += per31(0)
distance3 += per32(0)
distance3 += per33(0)
distance3 += per34(0)
distance3 += per35(0)
distance3 += per36(0)

//Almacenar en un solo Array el percentil de cada pregunta de la sección 4 
val distance4 = new ArrayBuffer[Double]()
distance4 += per41(0)
distance4 += per42(0)
distance4 += per43(0)
distance4 += per44(0)
distance4 += per45(0)
distance4 += per46(0)
distance4 += per47(0)
distance4 += per48(0)
distance4 += per49(0)
distance4 += per410(0)
distance4 += per411(0)
distance4 += per412(0)



//Convertir en un DataFrame el array que contiene los percentiles de cada pregunta de la seccion1
val df11 = distance1.map(x => x.toDouble).toDF("section1")
//Convertir en un DataFrame el array que contiene los percentiles de cada pregunta de la seccion2
val df22 = distance2.map(x => x.toDouble).toDF("section2")
//Convertir en un DataFrame el array que contiene los percentiles de cada pregunta de la seccion3
val df33 = distance3.map(x => x.toDouble).toDF("section3")
//Convertir en un DataFrame el array que contiene los percentiles de cada pregunta de la seccion2
val df44 = distance4.map(x => x.toDouble).toDF("section4")


//Calcular el percentil de la seccion1 tomando los percentiles de cada una de las preguntas de la  misma seccion1
val PerSection1 = df11.stat.approxQuantile("section1",Array(0.75),0).toBuffer
//Calcular el percentil de la seccion2 tomando los percentiles de cada una de las preguntas de la  misma seccion2
val PerSection2 = df22.stat.approxQuantile("section2",Array(0.75),0).toBuffer
//Calcular el percentil de la seccion2 tomando los percentiles de cada una de las preguntas de la  misma seccion3
val PerSection3 = df33.stat.approxQuantile("section3",Array(0.75),0).toBuffer
//Calcular el percentil de la seccion2 tomando los percentiles de cada una de las preguntas de la  misma seccion2
val PerSection4 = df44.stat.approxQuantile("section4",Array(0.75),0).toBuffer

val name1 = ArrayBuffer[String]("Seccion1").toDF("seccion").withColumn("id", monotonicallyIncreasingId+1.toFloat)
val name2 = ArrayBuffer[String]("Seccion2").toDF("seccion").withColumn("id", monotonicallyIncreasingId+1.toFloat)
val name3 = ArrayBuffer[String]("Seccion3").toDF("seccion").withColumn("id", monotonicallyIncreasingId+1.toFloat)
val name4 = ArrayBuffer[String]("Seccion4").toDF("seccion").withColumn("id", monotonicallyIncreasingId+1.toFloat)

val con = ArrayBuffer[Int](5).toDF("contC").withColumn("id", monotonicallyIncreasingId+1.toFloat)

val dfPersection1 = PerSection1.map(x => x.toInt).toDF("valor").withColumn("id", monotonicallyIncreasingId+1.toFloat) 
val dfPersection2 = PerSection2.map(x => x.toInt).toDF("valor").withColumn("id", monotonicallyIncreasingId+1.toFloat)
val dfPersection3 = PerSection3.map(x => x.toInt).toDF("valor").withColumn("id", monotonicallyIncreasingId+1.toFloat)
val dfPersection4 = PerSection4.map(x => x.toInt).toDF("valor").withColumn("id", monotonicallyIncreasingId+1.toFloat)

val dfPS1 = name1.join(dfPersection1,"id").join(con,"id")
val dfPS2 = name2.join(dfPersection2,"id").join(con,"id")
val dfPS3 = name3.join(dfPersection3,"id").join(con,"id")
val dfPS4 = name4.join(dfPersection4,"id").join(con,"id")

val dfPS = dfPS1.union(dfPS2).union(dfPS3).union(dfPS4)

val k = new ArrayBuffer[Int]()
//Numero de personas que han diligenciado
	if (df1.count == df2.count)
	{
		k += df1.count.toInt 		
	}
 
//Export data bullet graph

dfPS.drop("id").coalesce(1).write.mode("overwrite").json("/var/www/html/DashboardProc/web/Nacionales/bullet/")
val fs = FileSystem.get(sc.hadoopConfiguration);
val file = fs.globStatus(new Path("/var/www/html/DashboardProc/web/Nacionales/bullet/part*"))(0).getPath().getName();
fs.rename(new Path("/var/www/html/DashboardProc/web/Nacionales/bullet/"+file), new Path("/var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json"));
 

//Export data donuts graph

val dfK = k.toDF("Colaboradores").withColumn("total",lit(20))
dfK.coalesce(1).write.mode("overwrite").format("com.databricks.spark.csv").option("header", "FALSE").save("/var/www/html/DashboardProc/web/Nacionales/donut/")
val file = fs.globStatus(new Path("/var/www/html/DashboardProc/web/Nacionales/donut/part*"))(0).getPath().getName();
fs.rename(new Path("/var/www/html/DashboardProc/web/Nacionales/donut/"+file), new Path("/var/www/html/DashboardProc/web/Nacionales/donut/donut.json"));


System.exit(0) 
