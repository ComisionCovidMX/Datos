#######################################################################################
#Análisis de conglomerados a nivel país
#Comisión Independiente de Investigación sobre la Pandemia de Covid-19 en México

#Paquetes
library(tidyverse)
library(lubridate)
library(readxl)
library(readr)
library(ggridges)
library(ggplot2)
library(cluster)


################################################################################
#################  Análisis de conglomerados          ##########################
################################################################################

#Definir ruta
country <- read_csv("muestra_estimacion_modeloexceso_paises.csv")

#Variables consideradas en el cluster
paises <- select(country,countryname,poptot2021:diabetesprevalence2021) %>% 
  select(-logpop,-logmedianage)

#Registros sin NA
paises_bis <- na.omit(paises)

#Paises excluidos con NA en algun registro
setdiff(paises$countryname,paises_bis$countryname)

#Estandarización de los valores
paises_bis <- cbind(select(paises_bis,countryname),scale(select(paises_bis,-countryname)))


#Análisis de clustering con k-means
A <- select(paises_bis,-countryname)

model_1=kmeans(A,1) #No tiene mucho sentido pero para cuadrar la grafica

#Cluster con 2 grupos
model_2=kmeans(A,2)

#Cluster con 3 grupos
model_3=kmeans(A,3)

#Cluster con 4 grupos
model_4=kmeans(A,4)

#Cluster con 5 grupos
model_5=kmeans(A,5)

#Cluster con 6 grupos
model_6=kmeans(A,6)

#Cluster con 7 grupos
model_7=kmeans(A,7)

#Cluster con 8 grupos
model_8=kmeans(A,8)

#Cluster con 9 grupos
model_9=kmeans(A,9)

#Cluster con 10 grupos
model_10=kmeans(A,10)


#Matriz para almacenar los resultados
mat <- matrix(0,10,2) %>% data.frame()
colnames(mat) <- c("cluster","withinss")

mat$cluster <- c(1,2,3,4,5,6,7,8,9,10)
mat$withinss <- c(model_1$tot.withinss,
                  model_2$tot.withinss,model_3$tot.withinss,model_4$tot.withinss,
                  model_5$tot.withinss,model_6$tot.withinss,
                  model_7$tot.withinss,model_8$tot.withinss,
                  model_9$tot.withinss,model_10$tot.withinss)

#Grafica de codo
plot(mat$withinss,xlab="Número de grupos",
     ylab="Withinss Total")
lines(mat$withinss)

#Resultados con 3 conglomerados
A$cluster_3 <- model_3$cluster
#miembros por grupo
table(A$cluster_3)

#Etiqueta por paises
A <- cbind(select(paises_bis,countryname),A)
