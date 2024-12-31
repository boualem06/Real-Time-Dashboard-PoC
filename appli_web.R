# Charger les packages nécessaires
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(mongolite)
library(tibble)
library(corrplot)

# Connexion à la base de données MongoDB
password <- 'tEsTBd.2024'
uri <- sprintf("mongodb://maelleB:%s@projetlinux-shard-00-00.oujjt.mongodb.net:27017,projetlinux-shard-00-01.oujjt.mongodb.net:27017,projetlinux-shard-00-02.oujjt.mongodb.net:27017/?ssl=true&replicaSet=atlas-rvoyfr-shard-0&authSource=admin&retryWrites=true&w=majority&appName=projetLinux", password)

# Créer une connexion MongoDB
con <- mongo(collection = "prix_et_facteurs", db = "data_linux", url = uri)

# Récupérer toutes les données de la collection
data <- con$find()
data$date <- as.Date(data$date)

df = data.frame(
  date = data$date,
  taux = data$`taux_$`,
  gaz_naturel = data$facteurs$gaz_naturel,
  oil_price = data$facteurs$oil_price,
  or_prix = data$facteurs$or_prix,
  wheat = data$fa$wheat,
  corn = data$facteurs$corn)



df <- df %>%
  rename(
    "Date" = "date",
    "Rate_money" = "taux",
    "Natural Gas" = "gaz_naturel",
    "Oil" = "oil_price",
    "Gold" = "or_prix",
    "Wheat" = "wheat",
    "Corn" = "corn"
  )

df <- df %>%
  arrange(desc(Date))

df$Corn[1] = 206.25
df$Corn[2] = 204.75
df$Corn[3] = 204.50
df$Corn[4] = 204.50
df$Corn[5] = 205
df$Corn[6] = 206.2
df$Corn[7] = 207
df$Corn[8] = 20.5



# Fonction pour normaliser les données (Min-Max)
normalize <- function(x) {
  return((x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
}

# Application Shiny
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
    
      body {
        background-color: #f9f9f9; /* Gris très clair */
      }
      .title-banner {
        background-color: black;
        color: white;
        padding: 10px;
        text-align: center;
        font-size: 24px;
        font-weight: bold;
        width: 100%;
      }
      .bold-date {
        font-weight: bold;
        font-size: 18px;
      }
      
      .kpi-box {
        background-color: black;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }
      .kpi-title {
        font-size: 24px;
        font-weight: bold;
        color: white;
      }
      .kpi-value {
        font-size: 32px;
        font-weight: bold;
        color: white;
      }
      .kpi-arrow {
        font-size: 28px;
        font-weight: bold;
        color: green;
      }
      .kpi-arrow-down {
        color: red;
      }
      .plot-container {
        background-color: #ffffff; /* Fond blanc pour les graphiques */
        border-radius: 10px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Ombre autour des graphiques */
        padding: 15px;
        margin-bottom: 20px;
      }
    "))
  ),
  
  titlePanel(
    tags$div(class = "title-banner", "Analyse des Indices Economiques")
  ),
  
  # Disposition de l'appli web
  sidebarLayout(
    sidebarPanel(
      # Affichage de la dernière date
      h4("Dernière Date de chargement:"),
      tags$span(class = "bold-date", textOutput("last_date")),
      
      # Affichage de la dernière valeur et flèche pour chaque indice
      h4("Dernières valeurs et variation:"),
      div(class = "kpi-box", 
          uiOutput("rate_arrow")),
      div(class = "kpi-box", 
          uiOutput("gas_arrow")),
      div(class = "kpi-box", 
          uiOutput("oil_arrow")),
      div(class = "kpi-box", 
          uiOutput("gold_arrow")),
      div(class = "kpi-box", 
          uiOutput("wheat_arrow")),
      div(class = "kpi-box", 
          uiOutput("corn_arrow"))
      
      
    ),
    
    mainPanel(
      # Liste déroulante variables
      selectInput(
        "plot_choice",
        label = "Choisissez une variable:",
        choices = list(
          "Taux du $ vers €" = "rate_plot",
          "Gaz naturel(par BTU)" = "gas_plot",
          "Pétrole(par Baril)" = "oil_plot",
          "Or(par Oz)" = "gold_plot",
          "Blé(par Tonne)" = "wheat_plot",
          "Maïs(par Tonne)" = "corn_plot"
        ),
        selected = "gas_plot"  # Sélection par défaut
      ),
      
      selectInput("uni_periode", label = "Sélectionner la période du graphique:", 
                  choices = c("Dernière semaine", "Dernier mois", "Dernière année", "Aucune limite"),
                  selected = "Dernier mois"),
      
      uiOutput("selected_plot"),
      
      # liste deroulante choix variable graph bivar
      h4("Sélectionner les variables:"),
      selectInput("x_var", "Variable 1:",
                  choices = list(
                    "Taux du $ vers €" = "Rate_money",
                    "Gaz naturel(par BTU)" = "Natural Gas",
                    "Pétrole(par Baril)" = "Oil",
                    "Or(par Oz)" = "Gold",
                    "Blé" = "Wheat",
                    "Maïs" = "Corn"
                  ),
                  selected = "rate_money"),
      selectInput("y_var", "Variable 2:",
                  choices = list(
                    "Taux du $ vers €" = "Rate_money",
                    "Gaz naturel(par BTU)" = "Natural Gas",
                    "Pétrole(par Baril)" = "Oil",
                    "Or(par Oz)" = "Gold",
                    "Blé(par Tonne)" = "Wheat",
                    "Maïs(par Tonne)" = "Corn"
                  ),
                  selected = "Oil"),
      selectInput("bi_periode", label = "Sélectionner la Période du graph:", 
                  choices = c("Dernière semaine", "Dernier mois", "Dernière année", "Aucune limite"),
                  selected = "Dernière semaine"),
      # Graphique avec les deux lignes
      plotlyOutput("two_lines_plot"),
      
      # Afficher la corrélation entre les variables
      h4("Matrice de corrélation:"),
      selectInput("corr_periode", label = "Sélectionner la Période du graph:", 
                  choices = c("Dernière semaine", "Dernier mois", "Dernière année", "Aucune limite"),
                  selected = "Dernier mois"),
      plotOutput("corr_plot")
    )
  )
)

server <- function(input, output) {
  
  # Fonction de filtrage par période
  filter_data_by_period <- function(data, period_choice) {
    last_date <- max(df$Date, na.rm = TRUE)
    
    if (period_choice == "Dernière semaine") {
      start_date <- last_date - 7
    } else if (period_choice == "Dernier mois") {
      start_date <- last_date - 30
    } else if (period_choice == "Dernière année") {
      start_date <- last_date - 365
    } else {
      return(data)  # Aucune limite
    }
    
    return(data %>% filter(Date >= start_date))
  }
  

  # Dernière date
  output$last_date <- renderText({
    last_date <- max(df$Date, na.rm = TRUE)
    return(as.character(last_date))
  })

  
  # Fonction pour déterminer la flèche
  get_arrow <- function(new_value, old_value) {
    valid_values <- na.omit(c(old_value, new_value)) 
    if (length(valid_values) < 2) return("-") 
    
    # Comparer les deux dernières valeurs
    if (valid_values[1] > valid_values[2]) {
      return("↓")  
    } else if (valid_values[1] < valid_values[2]) {
      return("↑")  
    } else {
      return("-")
    }
  }
  
  
  round_value <- function(value) {
    return(round(value, 5))
  }
  
  
  
  # Affichage des flèches et des dernières valeurs pour chaque action
  output$rate_arrow <- renderUI({
    last_rate <- round_value(head(na.omit(df$Rate_money), 1)) 
    prev_rate <- round_value(head(na.omit(df$Rate_money), 2)[2])  
    arrow <- get_arrow(last_rate, prev_rate)  
    evol_rate = round(((last_rate * 100)/prev_rate)-100,2)
    if (evol_rate >= 0){
    tagList(
      div(class = "kpi-title", paste("Taux du $ vers €:")),
      div(class = "kpi-value", paste(last_rate)),
      div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (+",evol_rate,"%)"))
    )
    }else{
    tagList(
      div(class = "kpi-title", paste("Taux du $ vers €:")),
      div(class = "kpi-value", paste(last_rate)),
      div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (",evol_rate,"%)"))
      )
    }
  })


  output$gas_arrow <- renderUI({
    last_gas <- round_value(head(na.omit(df$`Natural Gas`), 1))  
    prev_gas <- round_value(head(na.omit(df$`Natural Gas`), 2)[2])
    arrow <- get_arrow(last_gas, prev_gas)
    evol_gas = round(((last_gas * 100)/prev_gas)-100,2)
    if (evol_gas >= 0){
      tagList(
        div(class = "kpi-title", paste("Gas Naturel(par BTU):")),
        div(class = "kpi-value", paste(last_gas),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (+",evol_gas,"%)"))
      )
    }else{
      tagList(
        div(class = "kpi-title", paste("Gas Naturel(par BTU):")),
        div(class = "kpi-value", paste(last_gas),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (",evol_gas,"%)"))
      )
    }
  })
  

  
  
  output$oil_arrow <- renderUI({
    last_oil <- round_value(head(na.omit(df$Oil), 1)) 
    prev_oil <- round_value(head(na.omit(df$Oil), 2)[2]) 
    arrow <- get_arrow(last_oil, prev_oil)
    evol_oil = round(((last_oil * 100)/prev_oil)-100,2)
    if (evol_oil >= 0){
      tagList(
        div(class = "kpi-title", paste("Pétrole(par Baril):")),
        div(class = "kpi-value", paste(last_oil),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (+",evol_oil,"%)"))
      )
    }else{
      tagList(
        div(class = "kpi-title", paste("Pétrole(par Baril):")),
        div(class = "kpi-value", paste(last_oil),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (",evol_oil,"%)"))
      )
    }
  })
  
  output$gold_arrow <- renderUI({
    last_gold <- round_value(head(na.omit(df$Gold), 1)) 
    prev_gold <- round_value(head(na.omit(df$Gold), 2)[2])
    arrow <- get_arrow(last_gold, prev_gold)
    evol_gold = round(((last_gold * 100)/prev_gold)-100,2)
    if (evol_gold >= 0){
      tagList(
        div(class = "kpi-title", paste("Or(par Oz):")),
        div(class = "kpi-value", paste(last_gold),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (+",evol_gold,"%)"))
      )
    }else{
      tagList(
        div(class = "kpi-title", paste("Or(par Oz):")),
        div(class = "kpi-value", paste(last_gold),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (",evol_gold,"%)"))
      )
    }
  })
  
  output$wheat_arrow <- renderUI({
    last_wheat <- round_value(head(na.omit(df$Wheat), 1)) 
    prev_wheat <- round_value(head(na.omit(df$Wheat), 2)[2])  
    arrow <- get_arrow(last_wheat, prev_wheat)
    evol_wheat = round(((last_wheat * 100)/prev_wheat)-100,2)
    if (evol_wheat >= 0){
      tagList(
        div(class = "kpi-title", paste("Blé(par Tonne):")),
        div(class = "kpi-value", paste(last_wheat),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (+",evol_wheat,"%)"))
      )
    }else{
      tagList(
        div(class = "kpi-title", paste("Blé(par Tonne):")),
        div(class = "kpi-value", paste(last_wheat),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (",evol_wheat,"%)"))
      )
    }
  })
  
  output$corn_arrow <- renderUI({
    last_corn <- round_value(head(na.omit(df$Corn), 1))  
    prev_corn <- round_value(head(na.omit(df$Corn), 2)[2]) 
    arrow <- get_arrow(last_corn, prev_corn)
    evol_corn = round(((last_corn * 100)/prev_corn)-100,2)
    if (evol_corn >= 0){
      tagList(
        div(class = "kpi-title", paste("Maïs(par Tonne):")),
        div(class = "kpi-value", paste(last_corn),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (+",evol_corn,"%)"))
      )
    }else{
      tagList(
        div(class = "kpi-title", paste("Maïs(par Tonne):")),
        div(class = "kpi-value", paste(last_corn),"$"),
        div(class = paste("kpi-arrow", ifelse(arrow == "↑", "", "kpi-arrow-down")), paste("Variation: ", arrow, " (",evol_corn,"%)"))
      )
    }
  })
  
  
  
  
  # Corrélogramme
  output$corr_plot <- renderPlot({
    
    filtered_data <- filter_data_by_period(df, input$corr_periode)
    df_corr <- filtered_data %>%
      select(-Date)
    
    # matrice de corrélation
    corr_matrix <- cor(df_corr, use = "pairwise.complete.obs")
    
    # Afficher la matrice de corrélation
    corrplot(corr_matrix, method = "color", type = "upper", tl.cex = 0.8, number.cex = 0.7, addCoef.col = "black")
  })
  
  
  # Graphiques avec régression stochastique
  output$rate_plot <- renderPlotly({
    
    filtered_data <- filter_data_by_period(df, input$uni_periode)

    p <- ggplot(filtered_data, aes(x = Date, y = Rate_money)) +
      geom_line() +
      geom_smooth(method = "loess", se = TRUE, color = "blue", linetype = "dashed") +
      labs(title = "Évolution du Taux du $ vers €") +
      ylab("")+
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$gas_plot <- renderPlotly({
    
    filtered_data <- filter_data_by_period(df, input$uni_periode)
    
    p <- ggplot(filtered_data, aes(x = Date, y = `Natural Gas`)) +
      geom_line() +
      geom_smooth(method = "loess", se = TRUE, color = "blue", linetype = "dashed") +
      labs(title = "Évolution du Prix du Gaz Naturel") +
      ylab("")+
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$oil_plot <- renderPlotly({
    
    filtered_data <- filter_data_by_period(df, input$uni_periode)
    
    p <- ggplot(filtered_data, aes(x = Date, y = Oil)) +
      geom_line() +
      geom_smooth(method = "loess", se = TRUE, color = "blue", linetype = "dashed") +
      labs(title = "Évolution du Prix du Pétrole") +
      ylab("")+
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$gold_plot <- renderPlotly({
    
    filtered_data <- filter_data_by_period(df, input$uni_periode)
    
    p <- ggplot(filtered_data, aes(x = Date, y = Gold)) +
      geom_line() +
      geom_smooth(method = "loess", se = TRUE, color = "blue", linetype = "dashed") +
      labs(title = "Évolution du Prix de l'Or") +
      ylab("")+
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$wheat_plot <- renderPlotly({
    
    filtered_data <- filter_data_by_period(df, input$uni_periode)
    
    p <- ggplot(filtered_data, aes(x = Date, y = Wheat)) +
      geom_line() +
      geom_smooth(method = "loess", se = TRUE, color = "blue", linetype = "dashed") +
      labs(title = "Évolution du Prix du Blé") +
      ylab("")+
      theme_minimal()
    
    ggplotly(p)
  })
  
  
  
  output$corn_plot <- renderPlotly({
    
    filtered_data <- filter_data_by_period(df, input$uni_periode)
    
    p <- ggplot(filtered_data, aes(x = Date, y = Corn)) +
      geom_line() +
      geom_smooth(method = "loess", se = TRUE, color = "blue", linetype = "dashed") +
      labs(title = "Évolution du Prix du Maïs") +
      ylab("")+
      theme_minimal()
    
    ggplotly(p)
  })
  
  # affichage du graph sélectionné
  output$selected_plot <- renderUI({
    req(input$plot_choice)  
    
    if (input$plot_choice == "rate_plot") {
      plotlyOutput("rate_plot")
    } else if (input$plot_choice == "gas_plot") {
      plotlyOutput("gas_plot")
    } else if (input$plot_choice == "oil_plot") {
      plotlyOutput("oil_plot")
    } else if (input$plot_choice == "gold_plot") {
      plotlyOutput("gold_plot")
    } else if (input$plot_choice == "wheat_plot") {
      plotlyOutput("wheat_plot")
    } else if (input$plot_choice == "corn_plot") {
      plotlyOutput("corn_plot")
    }
  })
  
  output$two_lines_plot <- renderPlotly({
    # Obtenir les variables sélectionnées
    x_var <- input$x_var
    y_var <- input$y_var
    
    # Normaliser les données
    df_normalized <- df %>%
      mutate(
        across(c(x_var, y_var), normalize)
      )
    
    filtered_data <- filter_data_by_period(df_normalized, input$bi_periode)
    
    # Création du graphique
    p <- ggplot(filtered_data, aes(x = Date)) +
      geom_point(aes(y = .data[[x_var]], color = "Variable 1"), size = 2) + 
      geom_smooth(aes(y = .data[[x_var]], color = "Variable 1 Regresssion"), method = "loess", se = FALSE, linetype = "longdash") +
      geom_point(aes(y = .data[[y_var]], color = "Variable 2"), size = 2, shape = 17) + 
      geom_smooth(aes(y = .data[[y_var]], color = "Variable 2 Regresssion"), method = "loess", se = FALSE, linetype = "longdash") +
      labs(title = paste("Évolution normalisée de", x_var, "et", y_var)) +
      theme_minimal() +
      scale_color_manual(
        values = c("Variable 1" = "lightblue", "Variable 2" = "lightcoral", "Variable 1 Regresssion" = "blue", "Variable 2 Regresssion" = "red"),
        name = "",
        labels = c(x_var, y_var)
      ) +
      ylab("")+
      theme(legend.position = "right")
    
    ggplotly(p)
    
  })
}

# Démarrer l'application
shinyApp(ui = ui, server = server)
