# ============================================================================
# VERSIÓN MÍNIMA - PARA DEBUGGING
# Maneja datos incompletos de cohortes
# ============================================================================

library(shiny)
library(tidyverse)
library(plotly)

# Cargar datos con mejor manejo de errores
datos <- tryCatch({
  read_delim("egresados.csv",
             delim = ";",
             locale = locale(encoding = "UTF-8"),
             show_col_types = FALSE)
}, error = function(e) {
  # Si falla, intentar con otro encoding
  read_delim("egresados_segun_años_de_permanencia.csv",
             delim = ";",
             locale = locale(encoding = "latin1"),
             show_col_types = FALSE)
})

# Verificar que los datos se cargaron
if (nrow(datos) == 0) {
  stop("No se pudieron cargar los datos")
}

# Identificar cohortes con datos completos (tienen valores en cohorte_tot_y4)
cohortes_completas <- datos %>%
  filter(!is.na(cohorte_tot_y4), cohorte_tot_y4 > 0) %>%
  pull(anio_ingreso_propuesta) %>%
  unique() %>%
  sort(decreasing = TRUE)

# Si no hay cohortes completas, usar todas las disponibles
if (length(cohortes_completas) == 0) {
  cohortes_completas <- sort(unique(datos$anio_ingreso_propuesta), decreasing = TRUE)
  mensaje_cohortes <- "⚠️ Usando todas las cohortes (algunas pueden tener datos incompletos)"
} else {
  mensaje_cohortes <- paste0("✓ ", length(cohortes_completas), " cohortes con datos completos disponibles")
}

cat("\n", mensaje_cohortes, "\n")
cat("Cohortes disponibles:", paste(cohortes_completas, collapse = ", "), "\n\n")

# UI simplificada
ui <- fluidPage(
  titlePanel("Test - Análisis de Egresados"),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      h4("📊 Información"),
      verbatimTextOutput("info_datos"),

      hr(),

      selectInput("propuesta", "Propuesta Formativa:",
                 choices = sort(unique(datos$propuesta_formativa))),

      selectizeInput("cohorte", "Cohortes:",
                 choices = cohortes_completas,
                 selected = head(cohortes_completas, min(3, length(cohortes_completas))),
                 multiple = TRUE,
                 options = list(
                   placeholder = 'Seleccione cohortes',
                   plugins = list('remove_button')
                 )),

      hr(),

      checkboxInput("mostrar_incompletas",
                   "Mostrar cohortes incompletas",
                   value = FALSE),

      actionButton("reset", "Resetear Filtros",
                  class = "btn-warning w-100")
    ),

    mainPanel(
      width = 9,

      tabsetPanel(
        tabPanel("Gráfico Ojiva",
                h3("Distribución Acumulativa de Egresados"),
                plotlyOutput("grafico_ojiva", height = "500px"),
                hr(),
                h4("Estadísticas"),
                fluidRow(
                  column(3, wellPanel(
                    h5("Total Egresados"),
                    textOutput("stat_total")
                  )),
                  column(3, wellPanel(
                    h5("Promedio Años"),
                    textOutput("stat_promedio")
                  )),
                  column(3, wellPanel(
                    h5("Mediana"),
                    textOutput("stat_mediana")
                  )),
                  column(3, wellPanel(
                    h5("Cohortes Selec."),
                    textOutput("stat_cohortes")
                  ))
                )
        ),

        tabPanel("Datos por Cohorte",
                h3("Vista de Datos Filtrados"),
                tableOutput("tabla_cohortes")
        ),

        tabPanel("Datos Crudos",
                h3("Muestra de Datos"),
                tableOutput("tabla_raw")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {

  # Actualizar cohortes disponibles según checkbox
  observe({
    if (input$mostrar_incompletas) {
      todas_cohortes <- sort(unique(datos$anio_ingreso_propuesta), decreasing = TRUE)
      updateSelectizeInput(session, "cohorte",
                          choices = todas_cohortes,
                          selected = input$cohorte)
    } else {
      updateSelectizeInput(session, "cohorte",
                          choices = cohortes_completas,
                          selected = input$cohorte[input$cohorte %in% cohortes_completas])
    }
  })

  # Reset filtros
  observeEvent(input$reset, {
    updateSelectInput(session, "propuesta",
                     selected = sort(unique(datos$propuesta_formativa))[1])
    updateSelectizeInput(session, "cohorte",
                        selected = head(cohortes_completas, 3))
  })

  output$info_datos <- renderText({
    paste0(
      "Total registros: ", format(nrow(datos), big.mark = "."), "\n",
      "Cohortes totales: ", length(unique(datos$anio_ingreso_propuesta)), "\n",
      "Cohortes completas: ", length(cohortes_completas), "\n",
      "Propuestas: ", length(unique(datos$propuesta_formativa)), "\n",
      "Total egresados: ", format(sum(datos$alumnos, na.rm = TRUE), big.mark = ".")
    )
  })

  datos_filtrados <- reactive({
    req(input$propuesta, input$cohorte)

    datos %>%
      filter(
        propuesta_formativa == input$propuesta,
        anio_ingreso_propuesta %in% input$cohorte
      )
  })

  # Estadísticas
  output$stat_total <- renderText({
    format(sum(datos_filtrados()$alumnos, na.rm = TRUE), big.mark = ".")
  })

  output$stat_promedio <- renderText({
    df <- datos_filtrados()
    if(nrow(df) == 0) return("N/A")
    prom <- weighted.mean(df$años_de_permanencia, df$alumnos, na.rm = TRUE)
    paste0(round(prom, 1), " años")
  })

  output$stat_mediana <- renderText({
    df <- datos_filtrados()
    if(nrow(df) == 0) return("N/A")
    df_exp <- df %>% uncount(alumnos)
    paste0(median(df_exp$años_de_permanencia, na.rm = TRUE), " años")
  })

  output$stat_cohortes <- renderText({
    length(input$cohorte)
  })

  # Gráfico ojiva
  output$grafico_ojiva <- renderPlotly({
    req(nrow(datos_filtrados()) > 0)

    df <- datos_filtrados() %>%
      group_by(años_de_permanencia) %>%
      summarise(total = sum(alumnos, na.rm = TRUE), .groups = "drop") %>%
      arrange(años_de_permanencia) %>%
      mutate(acumulado = cumsum(total))

    plot_ly(df, x = ~años_de_permanencia, y = ~acumulado,
           type = 'bar',
           marker = list(color = '#e74c3c'),
           text = ~paste0("Años: ", años_de_permanencia, "<br>",
                         "Egresados: ", format(total, big.mark = "."), "<br>",
                         "Acumulado: ", format(acumulado, big.mark = ".")),
           hovertemplate = '%{text}<extra></extra>') %>%
      layout(
        xaxis = list(title = "Años de permanencia", dtick = 1),
        yaxis = list(title = "Egresados (acumulado)"),
        hovermode = 'x unified'
      )
  })

  # Tabla por cohorte
  output$tabla_cohortes <- renderTable({
    req(nrow(datos_filtrados()) > 0)

    datos_filtrados() %>%
      group_by(anio_ingreso_propuesta) %>%
      summarise(
        `Total Egresados` = sum(alumnos, na.rm = TRUE),
        `Cohorte Inicial (Y1)` = first(cohorte_tot_y1),
        `Activos Y2` = first(cohorte_tot_y2),
        `Activos Y3` = first(cohorte_tot_y3),
        `Activos Y4` = first(cohorte_tot_y4),
        `Tasa Egreso` = paste0(round(sum(alumnos, na.rm = TRUE) / first(cohorte_tot_y1) * 100, 1), "%"),
        .groups = "drop"
      ) %>%
      rename(Cohorte = anio_ingreso_propuesta)
  })

  # Tabla raw
  output$tabla_raw <- renderTable({
    head(datos_filtrados(), 20)
  })
}

# Ejecutar
shinyApp(ui = ui, server = server)# ============================================================================
# VERSIÓN MÍNIMA - PARA DEBUGGING
# Si esta versión funciona, el problema está en la versión completa
# ============================================================================

library(shiny)
library(tidyverse)
library(plotly)

# Cargar datos con mejor manejo de errores
datos <- tryCatch({
  read_delim("egresados_segun_años_de_permanencia.csv",
             delim = ";",
             locale = locale(encoding = "UTF-8"),
             show_col_types = FALSE)
}, error = function(e) {
  # Si falla, intentar con otro encoding
  read_delim("egresados_segun_años_de_permanencia.csv",
             delim = ";",
             locale = locale(encoding = "latin1"),
             show_col_types = FALSE)
})

# Verificar que los datos se cargaron
if (nrow(datos) == 0) {
  stop("No se pudieron cargar los datos")
}

# UI simplificada
ui <- fluidPage(
  titlePanel("Test - Análisis de Egresados"),

  sidebarLayout(
    sidebarPanel(
      h4("Información de datos"),
      textOutput("info_datos"),
      hr(),
      selectInput("propuesta", "Propuesta:",
                 choices = unique(datos$propuesta_formativa)),
      selectInput("cohorte", "Cohorte:",
                 choices = sort(unique(datos$anio_ingreso_propuesta),
                               decreasing = TRUE),
                 multiple = TRUE,
                 selected = tail(sort(unique(datos$anio_ingreso_propuesta)), 5))
    ),

    mainPanel(
      h3("Gráfico de Prueba"),
      plotlyOutput("grafico_test", height = "500px"),
      hr(),
      h4("Vista de datos"),
      tableOutput("tabla_test")
    )
  )
)

# Server
server <- function(input, output, session) {

  output$info_datos <- renderText({
    paste0("Total registros: ", nrow(datos), "\n",
           "Cohortes: ", length(unique(datos$anio_ingreso_propuesta)), "\n",
           "Propuestas: ", length(unique(datos$propuesta_formativa)))
  })

  datos_filtrados <- reactive({
    req(input$propuesta, input$cohorte)

    datos %>%
      filter(
        propuesta_formativa == input$propuesta,
        anio_ingreso_propuesta %in% input$cohorte
      )
  })

  output$grafico_test <- renderPlotly({
    df <- datos_filtrados() %>%
      group_by(años_de_permanencia) %>%
      summarise(total = sum(alumnos, na.rm = TRUE), .groups = "drop") %>%
      arrange(años_de_permanencia) %>%
      mutate(acumulado = cumsum(total))

    plot_ly(df, x = ~años_de_permanencia, y = ~acumulado,
           type = 'bar',
           marker = list(color = '#e74c3c')) %>%
      layout(
        xaxis = list(title = "Años de permanencia"),
        yaxis = list(title = "Egresados (acumulado)")
      )
  })

  output$tabla_test <- renderTable({
    head(datos_filtrados(), 10)
  })
}

# Ejecutar
shinyApp(ui = ui, server = server)
