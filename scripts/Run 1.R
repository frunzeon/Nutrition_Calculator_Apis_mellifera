# ============================================================
# R Setup Script for Nutrition Calculator (Apis mellifera)
# Installs and loads all required packages
# ============================================================

# List of required packages
required_pkgs <- c(
  "shiny",
  "glmnet",
  "ggplot2",
  "openxlsx",
  "dplyr",
  "Metrics",
  "ggrepel"
)

# Function to install missing packages
install_if_missing <- function(pkg){
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
    message(paste("Installed and loaded:", pkg))
  } else {
    library(pkg, character.only = TRUE)
    message(paste("Already installed:", pkg))
  }
}

# Loop through all required packages
for (pkg in required_pkgs){
  install_if_missing(pkg)
}

message("All required packages are installed and loaded successfully!")


