rm(list=ls())

library(openxlsx)
tabla <- read.xlsx("/Users/IDECOR/Documents/Code/UNC/Eco Pol/Preferencia por candidatos (respuestas).xlsx")
names(tabla)

library(dplyr)
tabla <- rename(tabla, n = Marca.temporal,
                STM = Sergio.Massa,
                PB = Patricia.Bullrich,
                HRL = Horacio.Rodriguez.Larreta,
                JM = Javier.Milei,
                JG = Juan.Grabois,
                IntencionPASO = "¿Cuál.es.su.intención.de.voto.para.las.PASO?",
                IntencionOtro = "En.caso.de.seleccionar.\"Otro\".¿A.quién.votaría?",
                IntencionHRLgana = "Ante.el.eventual.escenario.que.Horacio.Rodríguez.Larreta.gane.la.interna.contra.Patricia.Bullrich,.¿Cuál.sería.su.intención.de.voto.en.las.elecciones.generales?",
                IntencionPBgana = "Ante.el.eventual.escenario.que.Patricia.Bullrich.gane.la.interna.contra.Horacio.Rodriguez.Larreta,.¿Cuál.sería.su.intención.de.voto.en.las.elecciones.generales?",
                STMvsHRL = "Ante.un.eventual.enfrentamiento.entre.Sergio.Massa.y.Horacio.Rodríguez.Larreta,.¿A.quién.votaría?",
                STMvsPB = "Ante.un.eventual.enfrentamiento.entre.Sergio.Massa.y.Patricia.Bullrich,.¿A.quién.votaría?",
                STMvsJM = "Ante.un.eventual.enfrentamiento.entre.Sergio.Massa.y.Javier.Milei,.¿A.quién.votaría?",
                HRLvsJM = "Ante.un.eventual.enfrentamiento.entre.Horacio.Rodríguez.Larreta.y.Javier.Milei,.¿A.quién.votaría?",
                PBvsJM = "Ante.un.eventual.enfrentamiento.entre.Patricia.Bullrich.y.Javier.Milei,.¿A.quién.votaría?"
                )
names(tabla)
preferencias <- tabla[, 1:6]
names(preferencias)
head(preferencias)

indice <- 1:48
preferencias$n <- indice

head(preferencias)

library(tidyr)

ordenamientos <- c("Orden 1", "Orden 2", "Orden 3", "Orden 4", "Orden 5")

candidatos <- c("STM", "PB", "HRL", "JM", "JG")
preferencias[candidatos] <- candidatos[unlist(preferencias[candidatos])]
colnames(preferencias)[2:6] <- ordenamientos

preferencias_2 <- pivot_longer(preferencias, cols = starts_with("Orden"), names_to = "Orden", values_to = "Candidato")
preferencias_2$Candidato <- factor(preferencias_2$Candidato, levels = candidatos)
preferencias_final <- pivot_wider(preferencias_2, names_from = "Orden", values_from = "Candidato")

head(preferencias_final)

write.xlsx(preferencias_final, "preferencias_final.xlsx")
getwd()


### ROUTINE USING "VOTESYS" PACKAGE

data  <- import(here("epol","data","raw-respuestas-alumnos.xlsx"),setclass="data.table",header=TRUE)

data  <- data[,-1]
data  <- data[,1:5]

data.fp  <- 1*(data==1)


### APPLY DIFFERENT VOTING RULES

plurality(data.fp)
tworound.runoff(data.fp)
score(data,larger.wins=FALSE)
condorcet(data)

View(stv(data))

head(data)

data[data == "1"] <- "A"
data[data == "2"] <- "B"
data[data == "4"] <- "D"
data[data == "5"] <- "E"

data[data == "A"] <- "5"
data[data == "B"] <- "4"
data[data == "D"] <- "2"
data[data == "E"] <- "1"

# data2 <- data.frame(group = c(1, 2, 3, 4, 5)
 score(data)
