rm(list=ls())
library(googlesheets4)
library(tidyverse)

#getwd()
#setwd("/Users/IDECOR/Documents/Code/Political_Economy/eco pol 2023/migracion_votos/"); getwd()

getwd()
setwd("/Users/stefa/Documents/Code/Political_Economy/eco pol 2023/migracion_votos/"); getwd()

#gs4_deauth()
#gs4_auth()
datos <- read_sheet('https://docs.google.com/spreadsheets/d/1fXkkvYr6ZeD9N2YGAPV78o78lJX4apR6dBvK6-OTdBE/edit?usp=sharing')

head(datos)
names(datos)

migracion <- datos[, -c(2, 3, 4, 5, 6, 8, 9, 10)]; names(migracion)

migracion <- rename(migracion,  "id" = "Marca temporal",
                                "voto_gen" = "¿Cuál sería su intención de voto en las elecciones generales?",
                                "voto_paso" =  "¿A quién votaste en las PASO?")
names(migracion)
migracion$id <- 1:43
head(migracion)
class(migracion)
migracion <- as.data.frame(migracion); class(migracion)

migracion <- migracion %>% select(id, voto_paso, voto_gen)
head(migracion)

##########################################

#df = datos[,c("voto", "voto_paso")]
#df$id = 1:nrow(datos)
migracion = gather(migracion, escenario, voto, voto_paso:voto_gen, factor_key=TRUE)
head(migracion)


migracion %>%
  ggplot(aes(x = escenario, fill = voto)) +
  geom_bar(stat = "count") +
  scale_fill_viridis_d()

library(ggalluvial)
migracion %>%
  ggplot(aes(x = escenario,
             stratum = voto,
             alluvium = id,
             fill = voto)) +
  geom_stratum(alpha = 0.5) +
  geom_flow() +
  # scale_fill_viridis_d() +
  scale_fill_manual(values=c("yellow", "purple", "blue",
                                    "grey", "grey", "orange","skyblue")) +
                                      theme_minimal() +
  theme(legend.position = "bottom",
        axis.title.y = element_text(angle = 0, hjust = 0)) +
  geom_segment(aes(
    x = 0.75, xend = 2.16,
    y = 0, yend = 0),
    arrow = arrow(length=unit(0.30,"cm"), 
                  ends="first", 
                  type = "closed"))
#ggsave("/Users/stefa/Documents/Code/Political_Economy/eco pol 2023/migracion_votos/migracion_plot.jpeg", last_plot())
