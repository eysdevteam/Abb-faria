//Importar librerÃ­as
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


//Export data bullet graph

val df1 = spark.read.json("/var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json")
val df2 = spark.read.json("/var/www/html/DashboardProc/web/Jefes/bullet/bullet.json")
val df3 = spark.read.json("/var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json") 
val df4 = spark.read.json("/var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json")


//Export data donuts graph

val df5 = spark.read.json("/var/www/html/DashboardProc/web/Vicepr/donut/donut.json")
val df6 = spark.read.json("/var/www/html/DashboardProc/web/Jefes/donut/donut.json")
val df7 = spark.read.json("/var/www/html/DashboardProc/web/Nacionales/donut/donut.json") 
val df8 = spark.read.json("/var/www/html/DashboardProc/web/Internacionales/donut/donut.json")


