# Datos

Este repositorio contiene las bases de datos y código para reproducir los análisis contenidos en el Informe de la Comisión Independiente de Investigación sobre la Pandemia de COVID-19 en México. 

**Cap. 2, "¿Pudo ser diferente? México frente al mundo"**
- La matriz con las variables utilizadas en el modelo de regresión múltiple con todos los países corresponde al archivo "excesomortalidad_paises.csv". Las fuentes de las variables se encuentran descritas en el texto principal.
- El código para replicar los resultados reportados en el texto principal se encuentra en el archivo "dofile modelo exceso mortalidad.do". El análisis se realizó en el programa estadístico Stata. Sin embargo, el código puede consultarse en cualquier procesador de texto.
  
- El código para reproducir la selección de una submuestra de 50 países mediante un algoritmo de clustering, utilizada en el anexo metodológico al capítulo 2, se encuentra en el archivo "clustering_model.R". Se usó la función kmeans del programa estadístico R.
- La submuestra de 50 países con todas las variables se encuentra en el archivo "excesomortalidad_paises_clustersample.csv" 
- El código para replicar el análisis en el anexo metodológico del capítulo 2 (submuestra de países) se encuentra en el archivo "dofile exceso submuestra.do"

**Cap. 3 "Desigualdades"**
- La base de datos de dos niveles utilizada en el capítulo 3 se encuentra en "SISVER_COVID_VARSMUN_2020_2021.csv". Esta base combina observaciones del Sistema de Vigilancia Epidemiológica de Enfermedades Respiratorias (pacientes) con variables municipales según el municipio de residencia del paciente, obtenidas de CONAPO e INEGI. Por el tamaño del archivo, se utilizó Git Large File Storage. Para descarga se requiere uso de la terminal. Si usted tiene problemas para acceder al archivo, puede ponerse en contacto a comision.covid.mx(at)gmail.com 
- El código para replicar los modelos de regresión logística multinivel reportados en la gráfica 5 del capítulo se encuentra en el archivo "dofile modelos multinivel.do"
- Los datos para la reproducción de la gráfica 8 se encuentran en el archivo "excesoZMVM.csv"

**Cap. 7 "Vacunación: lenta salida de la pandemia"**
- La base de datos sobre el avance mensual de la campaña de vacunación por entidad, obtenida mediante solicitudes de transparencia y utilizada en las gráficas del capítulo 7, se encuentra en el archivo "SSA REPORTE VACUNAS_HISTORICO_DESGLOSADO_RRA 2710-24.xlsx"
- No se cuenta con información más desagregada en el tiempo o a menores escalas geográficas, pues las autoridades involucradas (SSA, Secretaría de Bienestar) se declararon incompetentes o declararon la información inexistente.

 **Caps. 6, 9 y 10, cifras reportadas de ENIGH**
- Los cálculos sobre gasto de los hogares en salud y educación por ingreso y decil a partir de las ENIGH de INEGI, así como de asistencia escolar, pueden reproducirse utilizando el código en el archivo "dofile ENIGHs 2018-2022.do"
 
**Cómo citar el informe y los datos**
Mariano Sánchez Talanquer y Jaime Sepúlveda (coords.), Informe de la Comisión Independiente de Investigación sobre la Pandemia de COVID-19 en México, Ciudad de México, 2024.
