# ════════════════════════════════════════════════════════════════════════════════
# SHINY APP: ANÁLISIS DE EGRESADOS
# Versión 3.4 - CON FILTROS GLOBALES Y CURVAS NORMALIZADAS
# Cambios: 1) Filtros globales 2) Curvas punteadas normalizadas 3) Proyecciones
# ════════════════════════════════════════════════════════════════════════════════

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(dplyr)
library(RColorBrewer)

# ════════════════════════════════════════════════════════════════════════════════
# CARGAR Y PREPARAR DATOS
# ════════════════════════════════════════════════════════════════════════════════

df <- read.csv("egresados.csv", sep = ";", encoding = "UTF-8")

# Preparar datos
df <- df %>%
  select(
    anio_ingreso_propuesta,
    propuesta_formativa,
    anios_de_permanencia,
    alumnos,
    cohorte_tot_y1,
    cohorte_tot_y2,
    cohorte_tot_y3,
    cohorte_tot_y4
  ) %>%
  rename(
    anio_ingreso = anio_ingreso_propuesta,
    propuesta = propuesta_formativa,
    anos_permanencia = anios_de_permanencia,
    cohorte_y1 = cohorte_tot_y1,
    cohorte_y2 = cohorte_tot_y2,
    cohorte_y3 = cohorte_tot_y3,
    cohorte_y4 = cohorte_tot_y4
  ) %>%
  # FILTRAR: Excluir 2009, limitar a 2016, y AÑOS >= 3
  filter(!(anio_ingreso == 2009), anio_ingreso <= 2016, anos_permanencia >= 3)

cat("✅ ARCHIVO CARGADO\n")

# ════════════════════════════════════════════════════════════════════════════════
# CALCULAR PROYECCIONES NORMALIZADAS
# ════════════════════════════════════════════════════════════════════════════════

# Obtener distribución histórica de años desde cohortes viejas (2005, 2006)
dist_viejas <- df %>%
  filter(anio_ingreso %in% c(2005, 2006)) %>%
  group_by(propuesta, anos_permanencia) %>%
  summarise(total_alumnos = sum(alumnos), .groups = 'drop') %>%
  group_by(propuesta) %>%
  mutate(prop_distribucion = total_alumnos / sum(total_alumnos)) %>%
  ungroup()

# Calcular años promedio normalizado (usando distribución histórica)
anos_normalizados <- df %>%
  filter(cohorte_y1 > 0) %>%
  left_join(
    dist_viejas %>% select(propuesta, anos_permanencia, prop_distribucion),
    by = c("propuesta", "anos_permanencia")
  ) %>%
  mutate(prop_distribucion = ifelse(is.na(prop_distribucion), 0, prop_distribucion)) %>%
  group_by(anio_ingreso, propuesta) %>%
  summarise(
    anos_prom_observado = weighted.mean(anos_permanencia, alumnos),
    anos_prom_normalizado = weighted.mean(anos_permanencia, prop_distribucion),
    total_y1 = first(cohorte_y1),
    total_y2 = first(cohorte_y2),
    total_y3 = first(cohorte_y3),
    total_y4 = first(cohorte_y4),
    egresados_totales = sum(alumnos),
    prop_egr_y1_observado = sum(alumnos) / first(cohorte_y1),
    .groups = 'drop'
  )

# Calcular tasa de egreso normalizada (proyectada)
tasa_egreso_normalizada <- df %>%
  filter(cohorte_y1 > 0) %>%
  left_join(
    dist_viejas %>% select(propuesta, anos_permanencia, prop_distribucion),
    by = c("propuesta", "anos_permanencia")
  ) %>%
  mutate(prop_distribucion = ifelse(is.na(prop_distribucion), 0, prop_distribucion)) %>%
  group_by(anio_ingreso, propuesta) %>%
  summarise(
    # Proyección de egresados usando distribución histórica
    egresados_proyectados = sum(prop_distribucion * first(cohorte_y1)),
    prop_egr_y1_normalizada = egresados_proyectados / first(cohorte_y1),
    .groups = 'drop'
  )

# Merge con datos de cohortes summary
cohortes_summary <- df %>%
  filter(cohorte_y1 > 0) %>%
  group_by(anio_ingreso, propuesta) %>%
  summarise(
    total_y1 = first(cohorte_y1),
    total_y2 = first(cohorte_y2),
    total_y3 = first(cohorte_y3),
    total_y4 = first(cohorte_y4),
    egresados_totales = sum(alumnos),
    prop_egr_y1 = sum(alumnos) / first(cohorte_y1),
    tasa_ret_y1y2 = first(cohorte_y2) / first(cohorte_y1),
    tasa_ret_y2y3 = first(cohorte_y3) / first(cohorte_y2),
    tasa_ret_y3y4 = first(cohorte_y4) / first(cohorte_y3),
    .groups = 'drop'
  ) %>%
  filter(!is.na(prop_egr_y1), !is.na(tasa_ret_y1y2), !is.na(tasa_ret_y2y3)) %>%
  left_join(tasa_egreso_normalizada, by = c("anio_ingreso", "propuesta"))

# ════════════════════════════════════════════════════════════════════════════════
# UI - INTERFACE
# ════════════════════════════════════════════════════════════════════════════════

ui <- dashboardPage(
  dashboardHeader(title = "Análisis de Egresados v3.4"),

  dashboardSidebar(
    # ═════════════════════════════════════════════════════════════════════════
    # MENÚ DE SECCIONES (ARRIBA)
    # ═════════════════════════════════════════════════════════════════════════
    sidebarMenu(
      menuItem("Inicio", tabName = "inicio", icon = icon("home")),
      menuItem("Curvas Acumulativas", tabName = "ojivas", icon = icon("chart-line")),
      menuItem("Comparación Cohortes", tabName = "comparacion", icon = icon("bar-chart")),
      menuItem("Análisis Predictivo", tabName = "predictivo", icon = icon("crystal-ball")),
      menuItem("Datos Detallados", tabName = "datos", icon = icon("table"))
    ),

    # ═════════════════════════════════════════════════════════════════════════
    # FILTROS GENERALES (DEBAJO del menú)
    # ═════════════════════════════════════════════════════════════════════════
    hr(),

    p(strong("Filtros Generales"), style = "padding-left: 15px; padding-top: 10px;"),

    # Filtro 1: Propuesta Formativa
    selectInput(
      "filtro_propuesta",
      "Propuesta Formativa:",
      choices = c("Todas", sort(unique(df$propuesta))),
      selected = "Todas",
      multiple = FALSE,
      width = "90%"
    ),

    # Filtro 2: Año de Ingreso (Cohorte)
    selectInput(
      "filtro_anio",
      "Cohorte (Año Ingreso):",
      choices = c("Todas", sort(unique(df$anio_ingreso))),
      selected = "Todas",
      multiple = FALSE,
      width = "90%"
    )
  ),

  dashboardBody(
    tabItems(

      # ═══════════════════════════════════════════════════════════════════════
      # TAB 1: INICIO
      # ═══════════════════════════════════════════════════════════════════════
      tabItem(tabName = "inicio",
        fluidRow(
          box(title = "Dashboard de Análisis de Egresados v3.4", width = 12,
              status = "primary", solidHeader = TRUE,
              p("Bienvenido al dashboard interactivo."),
              p("Utiliza los filtros en el panel izquierdo para filtrar por Propuesta Formativa y Cohorte."),
              p("Los filtros se aplican a TODOS los gráficos y métricas."))
        )
      ),

      # ═══════════════════════════════════════════════════════════════════════
      # TAB 2: OJIVA ACUMULATIVA
      # ═══════════════════════════════════════════════════════════════════════
      tabItem(tabName = "ojivas",
        fluidRow(
          box(
            title = "Distribución Acumulada de Egresados según Años de Permanencia",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            fluidRow(
              column(4,
                radioButtons("ojiva_escala", "Escala:",
                  choices = c("Porcentaje" = "pct", "Absoluto" = "abs"),
                  selected = "pct", inline = TRUE)
              ),
              column(4,
                selectInput("ojiva_base_poblacional", "Base Poblacional:",
                  choices = c("Y1" = "y1", "Y2" = "y2", "Y3" = "y3", "Y4" = "y4"),
                  selected = "y1")
              ),
              column(4,
                selectInput("ojiva_denominador", "Denominador:",
                  choices = c("Cohorte Total" = "cohorte", "Solo Egresados" = "egresados"),
                  selected = "cohorte")
              )
            ),
            plotlyOutput("plot_ojiva", height = "500px")
          )
        )
      ),

      # ═══════════════════════════════════════════════════════════════════════
      # TAB 3: COMPARACIÓN - TASAS DE RETENCIÓN CONSOLIDADAS
      # ═══════════════════════════════════════════════════════════════════════
      tabItem(tabName = "comparacion",
        # Gráfico único: Tasas de Retención Consolidadas
        fluidRow(
          box(title = "Tasas de Retención por Cohorte",
              width = 12, status = "primary",
              solidHeader = TRUE,
              plotlyOutput("plot_retencion_consolidado", height = "550px"),
              p("Línea continua: Y1→Y2 | Línea discontinua: Y2→Y3 | Línea punteada: Y3→Y4"))
        )
      ),

      # ═══════════════════════════════════════════════════════════════════════
      # TAB 4: ANÁLISIS PREDICTIVO
      # ═══════════════════════════════════════════════════════════════════════
      tabItem(tabName = "predictivo",
        fluidRow(
          box(title = "Probabilidad de Egreso (Modelo Logístico)", width = 12,
              status = "primary", solidHeader = TRUE,
              plotlyOutput("plot_prediccion", height = "650px"))
        ),
        fluidRow(
          box(title = "Tabla de Probabilidades por Años de Permanencia", width = 12,
              status = "info", solidHeader = TRUE,
              DTOutput("tabla_prediccion"))
        )
      ),

      # ═══════════════════════════════════════════════════════════════════════
      # TAB 5: DATOS DETALLADOS
      # ═══════════════════════════════════════════════════════════════════════
      tabItem(tabName = "datos",
        fluidRow(
          box(title = "Tabla de Datos Completa", width = 12, status = "primary",
              solidHeader = TRUE, DTOutput("tabla_datos"))
        )
      )
    )
  )
)

# ════════════════════════════════════════════════════════════════════════════════
# SERVER - LÓGICA
# ════════════════════════════════════════════════════════════════════════════════

server <- function(input, output, session) {

  # ─────────────────────────────────────────────────────────────────────────────
  # FUNCIÓN PARA APLICAR FILTROS GLOBALES
  # ─────────────────────────────────────────────────────────────────────────────

  datos_filtrados <- reactive({
    datos <- df

    if (input$filtro_propuesta != "Todas") {
      datos <- datos %>% filter(propuesta == input$filtro_propuesta)
    }

    if (input$filtro_anio != "Todas") {
      datos <- datos %>% filter(anio_ingreso == as.numeric(input$filtro_anio))
    }

    return(datos)
  })

  anos_filtrados <- reactive({
    datos <- anos_normalizados

    if (input$filtro_propuesta != "Todas") {
      datos <- datos %>% filter(propuesta == input$filtro_propuesta)
    }

    if (input$filtro_anio != "Todas") {
      datos <- datos %>% filter(anio_ingreso == as.numeric(input$filtro_anio))
    }

    return(datos)
  })

  cohortes_filtrados <- reactive({
    datos <- cohortes_summary

    if (input$filtro_propuesta != "Todas") {
      datos <- datos %>% filter(propuesta == input$filtro_propuesta)
    }

    if (input$filtro_anio != "Todas") {
      datos <- datos %>% filter(anio_ingreso == as.numeric(input$filtro_anio))
    }

    return(datos)
  })

  # ─────────────────────────────────────────────────────────────────────────────
  # 1. OJIVA ACUMULATIVA (CON FILTROS GLOBALES)
  # ─────────────────────────────────────────────────────────────────────────────

  output$plot_ojiva <- renderPlotly({

    datos <- datos_filtrados() %>%
      filter(cohorte_y1 > 0, alumnos > 0) %>%  # Excluir filas sin alumnos
      arrange(anio_ingreso, propuesta, anos_permanencia) %>%
      group_by(anio_ingreso, propuesta) %>%
      mutate(
        egresados_acum = cumsum(alumnos),
        total_egresados_cohorte = sum(alumnos),
        cohorte_y1_first = first(cohorte_y1),
        cohorte_y2_first = first(cohorte_y2),
        cohorte_y3_first = first(cohorte_y3),
        cohorte_y4_first = first(cohorte_y4)
      ) %>%
      ungroup()

    if (nrow(datos) == 0) {
      return(plot_ly() %>% layout(title = "Sin datos disponibles"))
    }

    # ═════════════════════════════════════════════════════════════════════════
    # COLORES: Por COHORTE (RdYlGn: Rojo antiguo → Verde reciente)
    # PATRONES: Por PROPUESTA (líneas diferentes)
    # ═════════════════════════════════════════════════════════════════════════

    propuestas_unicas <- sort(unique(datos$propuesta))
    cohortes_unicas <- sort(unique(datos$anio_ingreso))

    # Colores para COHORTES (RdYlGn invertido: Rojo viejo → Verde nuevo)
    n_cohortes <- length(cohortes_unicas)
    if (n_cohortes <= 11) {
      # RdYlGn tiene 11 colores: usamos directo (rojo-amarillo-verde)
      colores_cohorte <- RColorBrewer::brewer.pal(n_cohortes, "RdYlGn")
    } else {
      # Si hay más cohortes, interpolamos
      colores_cohorte <- colorRampPalette(RColorBrewer::brewer.pal(11, "RdYlGn"))(n_cohortes)
    }
    color_map_cohorte <- setNames(colores_cohorte, cohortes_unicas)

    # Patrones para PROPUESTAS (dash patterns)
    dash_patterns <- c("solid", "dash", "dot", "dashdot")
    dash_map_prop <- setNames(
      dash_patterns[((seq_along(propuestas_unicas) - 1) %% length(dash_patterns)) + 1],
      propuestas_unicas
    )

    denom_tipo <- input$ojiva_denominador
    if (is.null(denom_tipo)) denom_tipo <- "cohorte"

    if (denom_tipo == "egresados") {
      datos <- datos %>%
        group_by(anio_ingreso, propuesta) %>%
        mutate(
          base_total = sum(alumnos),
          pct_acum = ifelse(base_total > 0, 100 * egresados_acum / base_total, 0)
        ) %>%
        ungroup()
      titulo_extra <- " (% del Total de Egresados)"
    } else {
      base_sel <- input$ojiva_base_poblacional
      if (is.null(base_sel)) base_sel <- "y1"

      datos$base_total <- switch(base_sel,
                                 y1 = datos$cohorte_y1_first,
                                 y2 = datos$cohorte_y2_first,
                                 y3 = datos$cohorte_y3_first,
                                 y4 = datos$cohorte_y4_first,
                                 datos$cohorte_y1_first)

      datos$pct_acum <- ifelse(datos$base_total > 0, 100 * datos$egresados_acum / datos$base_total, 0)
      titulo_extra <- paste(" (% de la Cohorte", base_sel, ")")
    }

    escala <- input$ojiva_escala
    if (is.null(escala)) escala <- "pct"
    if (denom_tipo == "egresados") escala <- "pct"

    y_var <- if (escala == "pct") "pct_acum" else "egresados_acum"
    y_label <- if (escala == "pct") "Porcentaje (%)" else "Egresados"

    p <- plot_ly(data = datos)

    # Graficar cada combinación cohorte-propuesta
    # Agrupar por cohorte para una leyenda limpia (solo cohorte)
    for (cohorte in cohortes_unicas) {
      subset_data_cohorte <- datos %>% filter(anio_ingreso == cohorte)

      # Para cada propuesta dentro de esta cohorte
      propuestas_en_cohorte <- sort(unique(subset_data_cohorte$propuesta))

      for (propuesta in propuestas_en_cohorte) {
        subset_data <- subset_data_cohorte %>% filter(propuesta == !!propuesta)

        if (nrow(subset_data) > 0) {
          # Leyenda SOLO muestra la cohorte (showlegend solo para la primera propuesta)
          show_legend <- (propuesta == propuestas_en_cohorte[1])

          p <- p %>%
            add_trace(
              data = subset_data,
              x = ~anos_permanencia,
              y = as.formula(paste("~", y_var)),
              name = paste("Cohorte", cohorte),  # ← SOLO la cohorte en la leyenda
              legendgroup = cohorte,  # Agrupa por cohorte
              type = 'scatter',
              mode = 'lines+markers',
              marker = list(
                size = 6,
                color = color_map_cohorte[as.character(cohorte)]
              ),
              line = list(
                color = color_map_cohorte[as.character(cohorte)],
                width = 2.5,
                dash = dash_map_prop[as.character(propuesta)]
              ),
              showlegend = show_legend,  # Solo mostrar en leyenda la primera propuesta de cada cohorte
              hovertemplate = paste(
                "<b>", propuesta, "</b><br>",
                "Cohorte: ", cohorte, "<br>",
                "Años: %{x}<br>",
                "Valor: %{y:.1f}<extra></extra>"
              )
            )
        }
      }
    }

    p %>% layout(
      title = paste("Distribución Acumulada", titulo_extra),
      xaxis = list(title = "Años de Permanencia"),
      yaxis = list(title = y_label),
      hovermode = "x unified",
      legend = list(x = 1.02, y = 1, xanchor = "left", yanchor = "top")
    )
  })

  # ─────────────────────────────────────────────────────────────────────────────
  # 2. GRÁFICO: TASAS DE RETENCIÓN CONSOLIDADAS (Y1→Y2, Y2→Y3, Y3→Y4)
  # ─────────────────────────────────────────────────────────────────────────────

  output$plot_retencion_consolidado <- renderPlotly({
    datos <- cohortes_filtrados() %>%
      filter(!is.na(tasa_ret_y1y2) | !is.na(tasa_ret_y2y3) | !is.na(tasa_ret_y3y4))

    if (nrow(datos) == 0) {
      return(plot_ly() %>% layout(title = "Sin datos"))
    }

    # Obtener propuestas únicas
    propuestas_unicas <- unique(datos$propuesta)

    # Paleta de colores
    colores_prop <- setNames(
      colorRampPalette(RColorBrewer::brewer.pal(max(3, length(propuestas_unicas)), "Set2"))(length(propuestas_unicas)),
      propuestas_unicas
    )

    p <- plot_ly()

    # Agregar trazas para cada propuesta
    for (prop in propuestas_unicas) {
      datos_prop <- datos %>% filter(propuesta == prop)
      color_actual <- colores_prop[prop]

      # Y1→Y2 (línea continua)
      if (any(!is.na(datos_prop$tasa_ret_y1y2))) {
        p <- p %>% add_trace(
          data = datos_prop %>% filter(!is.na(tasa_ret_y1y2)),
          x = ~anio_ingreso,
          y = ~tasa_ret_y1y2 * 100,
          type = 'scatter',
          mode = 'lines+markers',
          name = paste(prop, "Y1→Y2"),
          legendgroup = prop,
          line = list(color = color_actual, width = 2, dash = "solid"),
          marker = list(color = color_actual, size = 8),
          hovertemplate = paste0(
            "<b>", prop, "</b><br>",
            "Cohorte: %{x}<br>",
            "Y1→Y2: %{y:.1f}%<br>",
            "<extra></extra>"
          )
        )
      }

      # Y2→Y3 (línea discontinua)
      if (any(!is.na(datos_prop$tasa_ret_y2y3))) {
        p <- p %>% add_trace(
          data = datos_prop %>% filter(!is.na(tasa_ret_y2y3)),
          x = ~anio_ingreso,
          y = ~tasa_ret_y2y3 * 100,
          type = 'scatter',
          mode = 'lines+markers',
          name = paste(prop, "Y2→Y3"),
          legendgroup = prop,
          line = list(color = color_actual, width = 2, dash = "dash"),
          marker = list(color = color_actual, size = 8, symbol = "square"),
          hovertemplate = paste0(
            "<b>", prop, "</b><br>",
            "Cohorte: %{x}<br>",
            "Y2→Y3: %{y:.1f}%<br>",
            "<extra></extra>"
          )
        )
      }

      # Y3→Y4 (línea punteada)
      if (any(!is.na(datos_prop$tasa_ret_y3y4))) {
        p <- p %>% add_trace(
          data = datos_prop %>% filter(!is.na(tasa_ret_y3y4)),
          x = ~anio_ingreso,
          y = ~tasa_ret_y3y4 * 100,
          type = 'scatter',
          mode = 'lines+markers',
          name = paste(prop, "Y3→Y4"),
          legendgroup = prop,
          line = list(color = color_actual, width = 2, dash = "dot"),
          marker = list(color = color_actual, size = 8, symbol = "diamond"),
          hovertemplate = paste0(
            "<b>", prop, "</b><br>",
            "Cohorte: %{x}<br>",
            "Y3→Y4: %{y:.1f}%<br>",
            "<extra></extra>"
          )
        )
      }
    }

    p %>% layout(
      title = "Tasas de Retención por Cohorte",
      xaxis = list(title = "Año de Ingreso (Cohorte)"),
      yaxis = list(title = "Tasa de Retención (%)", range = c(0, 100)),
      hovermode = "closest",
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        yanchor = "top",
        orientation = "v"
      ),
      margin = list(r = 200)
    )
  })

  # ─────────────────────────────────────────────────────────────────────────────
  # 3. GRÁFICO: PREDICCIÓN (MODELO LOGÍSTICO)
  # ─────────────────────────────────────────────────────────────────────────────

  output$plot_prediccion <- renderPlotly({
    # Obtener datos filtrados por propuesta
    datos_filt <- datos_filtrados()

    if (nrow(datos_filt) == 0) {
      return(plot_ly() %>% layout(title = "Sin datos disponibles"))
    }

    # Calcular distribución de años de permanencia para la propuesta filtrada
    dist_anos <- datos_filt %>%
      filter(alumnos > 0) %>%
      group_by(anos_permanencia) %>%
      summarise(total_alumnos = sum(alumnos), .groups = 'drop') %>%
      mutate(prop = total_alumnos / sum(total_alumnos)) %>%
      arrange(anos_permanencia)

    # Calcular media y desviación estándar de años de permanencia (ponderado)
    media_anos <- weighted.mean(dist_anos$anos_permanencia, dist_anos$total_alumnos)
    sd_anos <- sqrt(sum(dist_anos$total_alumnos * (dist_anos$anos_permanencia - media_anos)^2) / sum(dist_anos$total_alumnos))

    # Usar media y sd para parametrizar la curva logística
    centro <- media_anos
    escala <- sd_anos * 1.2  # Ajustar escala según desviación estándar

    # Generar grid de predicción
    grid_pred <- tibble(anios = seq(3, 21, by = 0.5))
    grid_pred$prob <- 1 / (1 + exp((grid_pred$anios - centro) / escala))

    # Obtener nombre de propuesta para el título
    propuestas_filtradas <- unique(datos_filt$propuesta)
    titulo_propuesta <- if (length(propuestas_filtradas) == 1) {
      paste("para", propuestas_filtradas[1])
    } else {
      "por Propuesta Formativa"
    }

    plot_ly(grid_pred, x = ~anios, y = ~prob, type = 'scatter', mode = 'lines+markers',
            fill = 'tozeroy', name = 'Probabilidad',
            marker = list(size = 5, color = ~prob,
                         colorscale = list(c(0, "#d73027"), c(0.5, "#fee090"), c(1, "#1a9850")),
                         showscale = TRUE),
            line = list(color = 'darkgreen', width = 3),
            hovertemplate = "Años: %{x}<br>Prob: %{y:.1%}<extra></extra>") %>%
      layout(
        title = paste("Probabilidad de Egreso:", titulo_propuesta,
                     "<br><sub>Parámetros estimados: media =", round(media_anos, 1),
                     "años, sd =", round(sd_anos, 2), "</sub>"),
        xaxis = list(title = "Años de Permanencia", range = c(2, 22)),
        yaxis = list(title = "Probabilidad (0-1)", range = c(-0.05, 1.05)),
        hovermode = "x unified",
        plot_bgcolor = "rgba(240, 240, 240, 0.5)",
        font = list(size = 12)
      )
  })

  # ─────────────────────────────────────────────────────────────────────────────
  # 4. TABLA: PROBABILIDADES
  # ─────────────────────────────────────────────────────────────────────────────

  output$tabla_prediccion <- renderDT({
    # Obtener datos filtrados por propuesta
    datos_filt <- datos_filtrados()

    if (nrow(datos_filt) == 0) {
      return(datatable(tibble(), options = list(pageLength = 17, dom = 'tip')))
    }

    # Calcular distribución de años de permanencia para la propuesta filtrada
    dist_anos <- datos_filt %>%
      filter(alumnos > 0) %>%
      group_by(anos_permanencia) %>%
      summarise(total_alumnos = sum(alumnos), .groups = 'drop') %>%
      mutate(prop = total_alumnos / sum(total_alumnos)) %>%
      arrange(anos_permanencia)

    # Calcular media y desviación estándar de años de permanencia (ponderado)
    media_anos <- weighted.mean(dist_anos$anos_permanencia, dist_anos$total_alumnos)
    sd_anos <- sqrt(sum(dist_anos$total_alumnos * (dist_anos$anos_permanencia - media_anos)^2) / sum(dist_anos$total_alumnos))

    # Usar media y sd para la curva logística
    centro <- media_anos
    escala <- sd_anos * 1.2

    # Generar tabla de años
    grid_tabla <- tibble("Años" = seq(3, 21, by = 1))

    grid_tabla$"Probabilidad" <- 1 / (1 + exp((grid_tabla$"Años" - centro) / escala))
    grid_tabla$"Porcentaje" <- round(grid_tabla$"Probabilidad" * 100, 1)
    grid_tabla$"Interpretación" <- case_when(
      grid_tabla$"Probabilidad" >= 0.85 ~ "🟢 MUY ALTA",
      grid_tabla$"Probabilidad" >= 0.65 ~ "🟡 ALTA",
      grid_tabla$"Probabilidad" >= 0.35 ~ "🟠 MODERADA",
      grid_tabla$"Probabilidad" >= 0.15 ~ "🔴 BAJA",
      TRUE ~ "⚫ MUY BAJA"
    )
    grid_tabla$"Probabilidad" <- round(grid_tabla$"Probabilidad", 3)

    datatable(grid_tabla, options = list(pageLength = 19, scrollX = TRUE, dom = 'tip'),
              rownames = FALSE)
  })

  # ─────────────────────────────────────────────────────────────────────────────
  # 5. TABLA: DATOS COMPLETOS (CON FILTROS)
  # ─────────────────────────────────────────────────────────────────────────────

  output$tabla_datos <- renderDT({
    datatable(datos_filtrados(), options = list(scrollX = TRUE, pageLength = 20, dom = 'ftp'),
              rownames = FALSE)
  })
}

# ════════════════════════════════════════════════════════════════════════════════
# EJECUTAR APP
# ════════════════════════════════════════════════════════════════════════════════

shinyApp(ui, server)
