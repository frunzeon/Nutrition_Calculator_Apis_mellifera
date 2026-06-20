## **Nutrition Calculator (*Apis mellifera*): A Biomarker-Based Dietary-Response Classifier**
#**Elastic Net Regression Model with ΔΔCt Normalization**
## 1. **Overview**
The Nutrition Calculator (*Apis mellifera*): A Biomarker-Based Dietary-Response Classifier is an academic R/Shiny application designed to classify honey bee samples into biomarker-defined dietary-response states using qPCR gene expression data.
## 2. **Scientific Background**
Honey bees consume either beebread (protein-rich diet) or sucrose-based carbohydrate diets, which induce distinct gene-expression and proteomic response patterns associated with different dietary treatments.
## 3. **Dietary-Response Class Labels**
The model uses a fixed numerical scale:
- Beebread + 30% sugar syrup (BS) = 1
- 30% sugar syrup (S) = 3
Predicted values closer to 1 indicate greater similarity to the Diet BS reference state, whereas values closer to 3 indicate greater similarity to the Diet S reference state. These class labels do not represent nutritional quality scores and should not be interpreted as direct measures of dietary intake, colony health, or behavioral caste.
## 4. **Ct Normalization Method**
Ct values are normalized using the ΔΔCt method (Livak & Schmittgen).
- Housekeeping gene: *Actin*
- Calibrator: BS group (hard-coded in the script)
- Relative expression: ( 2^{-\Delta\Delta Ct} )
## 5. **Model Description**
- The model is based on Elastic Net Regression (ENR) with:
•	α = 0.5
•	λ selected via cross-validation
- Input features:
•	Normalized *COMP ortholog* expression
•	Normalized *α-glucosidase* expression
- Output:
A continuous dietary-response class label (~1–3) reflecting similarity to the molecular reference states used during model development.
## 6. **Usage**
The application is executed in two sequential steps in RStudio:
- **Step 1 — Environment Setup**
-Run the script:
**Run 1.R**.
  This script:
Automatically installs all required R packages (if not already installed)
Loads the libraries necessary for data processing, modeling, and visualization
- **Step 2 — Run Model and Launch Application**
-Run the script:
**Run 2 Shiny.R**.
  This script:
Loads the pre-trained Elastic Net Regression model
Performs ΔΔCt normalization of input data
Generates diet score predictions
Launches the Shiny application interface
- **Notes**
Ensure that both scripts are located in the same working directory
Input data should be prepared according to the format described in Section 7
The application will open automatically in the RStudio Viewer or a web browser
## 7. **Input File Requirements**
- A sample dataset (data.txt) is provided to allow users to quickly test the application workflow and reproduce example results (result EN_predictions.xlsx; result ENR_plot.png).
- The user input file must be a tab-delimited (.txt) file containing Ct values.
- Required column names:
     1-**Sample**; 2-**Ct_*Alpha_glucosidase***; 3-**Ct_*Actin*_*Alpha_glucosidase***; 4-**Ct_*COMP***; 5-**Ct_*Actin*_COMP**
## 8. **Output**
The application provides:
- Predicted dietary-response class labels
- Similarity to Diet BS-like and Diet S-like molecular reference states
- Interactive visualization
- Downloadable results (Excel and PNG formats)
## 9.Limitations
- Developed using early adult Apis mellifera ligustica workers.
- Based on controlled laboratory feeding experiments.
- Food consumption was not measured directly.
- Class labels represent molecular response states rather than direct measures of dietary intake or nutritional quality.
- Additional validation across seasons, subspecies, colonies, and forage environments is required before routine field application.
## 10. **Intended Use**
This software is intended for academic research only.
Commercial use or redistribution requires written permission.
## 11. **Authorship**
Dr. Olga Frunze / 
Laboratory CRCIV, Prof. Hyung-Wook Kwon /
Incheon National University, Republic of Korea
## 12. **Citation**
If you use this tool, please cite the associated publication (to be added).


