# ============================================================
# Nutrition Calculator (Apis mellifera)
# ============================================================
# Academic Research Use Only
# This script is provided for non-commercial academic research.
# Redistribution or commercial use without permission is prohibited.
# The authors disclaim all warranties and liability.
#
# Investigator: Dr. Olga Frunze
# Laboratory of Prof. Hyung-Wook Kwon
# Incheon National University, Republic of Korea
#
# If you intend to use this app for commercial purposes,
# please contact the authors.
# ============================================================
# ===============================
# Shiny App: ENR Prediction model with ddCt Normalization (BS=1, S=3)
# ===============================

library(shiny)
library(glmnet)
library(ggplot2)
library(openxlsx)
library(dplyr)
library(Metrics)
library(ggrepel)

# -------------------------------
# Built-in training dataset (10 BS=1, 10 S=3)
# -------------------------------
train_data <- data.frame(
  Diet = c(rep("BS",10), rep("S",10)),
  COMP = c(rep(1.00,10),
           5.578974665,6.36429187,5.377174805,5.465753,5.403046,
           5.3167,6.3256,5.3577,6.4212,6.3779),
  Alfa_glucosidase = c(rep(1.00,10),
                       2.928171392,2.313376368,2.234574276,2.922567,2.314483,
                       2.247112,2.308648,2.928876,2.915521,2.228324),
  Score = c(rep(1,10), rep(3,10))  # <-- BS=1, S=3
)

x_train <- as.matrix(train_data[, c("COMP","Alfa_glucosidase")])
y_train <- train_data$Score

set.seed(123)
cv_fit <- cv.glmnet(x_train, y_train, alpha=0.5)
best_lambda <- cv_fit$lambda.min
train_pred <- as.numeric(predict(cv_fit, newx=x_train, s="lambda.min"))

R2 <- cor(y_train, train_pred)^2
MSE <- mean((y_train - train_pred)^2)
RMSE <- sqrt(MSE)

# -------------------------------
# Shiny UI
# -------------------------------
ui <- fluidPage(
  titlePanel("Nutrition Calculator (Apis mellifera)"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload Ct data (tab-delimited)", accept = ".txt"),
      downloadButton("downloadExcel", "Download Excel Results"),
      downloadButton("downloadPlot", "Download Prediction Plot")
    ),
    mainPanel(
      h4("Training Performance"),
      verbatimTextOutput("trainMetrics"),
      plotOutput("trainPlot"),
      plotOutput("residualsPlot"),
      h4("User Predictions"),
      tableOutput("predTable"),
      plotOutput("userPlot")
    )
  )
)

# -------------------------------
# Shiny Server
# -------------------------------
server <- function(input, output) {
  
  output$trainMetrics <- renderPrint({
    cat("Best lambda:", best_lambda, "\n")
    cat("Training metrics:\n")
    cat("R2 =", round(R2,3), " MSE =", round(MSE,3), " RMSE =", round(RMSE,3), "\n")
  })
  
  output$trainPlot <- renderPlot({
    ggplot(data.frame(Observed=y_train, Predicted=train_pred), aes(x=Observed, y=Predicted)) +
      geom_point(color="blue", size=3) +
      geom_abline(slope=1, intercept=0, linetype="dashed") +
      ylim(0,5) +
      theme_minimal() +
      labs(title="Training: Predicted vs Observed",
           x="Observed Score (BS=1, S=3)", y="Predicted Score")
  })
  
  output$residualsPlot <- renderPlot({
    residuals <- y_train - train_pred
    ggplot(data.frame(Fitted=train_pred, Residuals=residuals), aes(x=Fitted, y=Residuals)) +
      geom_point(color="red", size=3) +
      geom_hline(yintercept=0, linetype="dashed") +
      theme_minimal() +
      labs(title="Residuals plot (Training)", x="Fitted values", y="Residuals")
  })
  
  # Reactive predictions
  user_results <- reactive({
    req(input$file)
    df <- read.delim(input$file$datapath, header=TRUE, sep="\t")
    colnames(df) <- gsub("-", "_", colnames(df))
    
    # Add Sample column if missing
    if(!"Sample" %in% colnames(df)){
      df$Sample <- paste0("S", seq_len(nrow(df)))
    }
    
    # -------------------------------
    # ddCt normalization (BS = first row hardcoded)
    # -------------------------------
    df$DeltaCt_Alfa <- df$Ct_Alfa_glucosidase - df$Ct_Actin_of_Alfa_glucosidase
    df$DeltaCt_COMP <- df$Ct_COMP - df$Ct_Actin_of_COMP
    
    BS_ctrl <- df[1, ]  # first row = BS reference
    df$ddCt_Alfa <- df$DeltaCt_Alfa - BS_ctrl$DeltaCt_Alfa
    df$ddCt_COMP <- df$DeltaCt_COMP - BS_ctrl$DeltaCt_COMP
    
    df$Norm_Alfa <- 2^(-df$ddCt_Alfa)
    df$Norm_COMP <- 2^(-df$ddCt_COMP)
    
    # -------------------------------
    # ENR prediction
    # -------------------------------
    x_new <- as.matrix(df[, c("Norm_COMP","Norm_Alfa")])
    pred <- as.numeric(predict(cv_fit, newx=x_new, s="lambda.min"))
    df$Predicted_Score <- round(pred, 2)
    
    # Classification: closer to 1 (BS) or 3 (S)
    df$Expected_Result <- ifelse(abs(df$Predicted_Score - 1) < abs(df$Predicted_Score - 3),
                                 "BS (≈1)", "S (≈3)")
    
    df
  })
  
  # Table
  output$predTable <- renderTable({
    user_results()
  })
  
  # User plot
  output$userPlot <- renderPlot({
    results <- user_results()
    
    y_min <- min(results$Predicted_Score, na.rm = TRUE) - 0.5
    y_max <- max(results$Predicted_Score, na.rm = TRUE) + 0.5
    
    ggplot(results, aes(x=factor(Sample, levels=unique(Sample)), 
                        y=Predicted_Score, color=Expected_Result)) +
      geom_point(size=1) +
      geom_text_repel(aes(label=Predicted_Score), size=4.5, nudge_y = 0.1, show.legend=FALSE) +
      scale_color_manual(values=c("BS (≈1)"="red","S (≈3)"="blue")) +
      coord_cartesian(ylim=c(y_min, y_max)) +
      geom_hline(yintercept = 1, linetype="dashed", alpha=0.6) +
      geom_hline(yintercept = 3, linetype="dashed", alpha=0.6) +
      scale_x_discrete(guide = guide_axis(angle = 45)) +
      theme_minimal(base_size = 16) +
      theme(panel.grid = element_blank(),
            legend.title = element_blank()) +
      labs(title="Predicted Scores for User Data", x="Sample", y="Predicted Score (BS=1, S=3)")
  })
  
  # Download Excel
  output$downloadExcel <- downloadHandler(
    filename = function() {"ENR_predictions.xlsx"},
    content = function(file) {
      wb <- createWorkbook()
      addWorksheet(wb,"Predictions")
      writeData(wb,"Predictions", user_results())
      saveWorkbook(wb, file, overwrite=TRUE)
    }
  )
  
  # Download Plot
  output$downloadPlot <- downloadHandler(
    filename = function() {"ENR_user_predictions.png"},
    content = function(file) {
      results <- user_results()
      y_min <- min(results$Predicted_Score, na.rm = TRUE) - 0.5
      y_max <- max(results$Predicted_Score, na.rm = TRUE) + 0.5
      p <- ggplot(results, aes(x=factor(Sample, levels=unique(Sample)), 
                               y=Predicted_Score, color=Expected_Result)) +
        geom_point(size=3) +
        geom_text_repel(aes(label=Predicted_Score), size=3.5, nudge_y = 0.1, show.legend=FALSE) +
        scale_color_manual(values=c("BS (≈1)"="red","S (≈3)"="blue")) +
        coord_cartesian(ylim=c(y_min, y_max)) +
        geom_hline(yintercept = 1, linetype="dashed", alpha=0.6) +
        geom_hline(yintercept = 3, linetype="dashed", alpha=0.6) +
        scale_x_discrete(guide = guide_axis(angle = 45)) +
        theme_minimal(base_size = 14) +
        theme(panel.grid = element_blank(),
              legend.title = element_blank()) +
        labs(title="Predicted Scores for User Data", x="Sample", y="Predicted Score (BS=1, S=3)")
      ggsave(file, p, width=8, height=5)
    }
  )
}

# -------------------------------
# Run App
# -------------------------------
shinyApp(ui, server)
