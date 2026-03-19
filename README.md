## **Nutrition Calculator (*Apis mellifera*)**
#**Elastic Net Regression Model with ΔΔCt Normalization**
## 1. **Overview**
The Nutrition Calculator (*Apis mellifera*) is an academic R/Shiny application designed to estimate the diet-associated metabolic state in honey bees using qPCR gene expression data.
## 2. **Scientific Background**
Honey bees consume either beebread (protein-rich diet) or sucrose-based carbohydrate diets, which induce distinct and reproducible metabolic gene expression signatures. These signatures can be quantified using qPCR and used for predictive modeling.
## 3. **Diet Score Scale**
The model uses a fixed numerical scale:
•	Beebread + 30% sugar syrup (BS) = 1
•	30% sugar syrup (S) = 3
Predicted values closer to 1 indicate BS-like metabolism, while values closer to 3 indicate S-like metabolism.
## 4. **Ct Normalization Method**
Ct values are normalized using the ΔΔCt method (Livak & Schmittgen).
•	Housekeeping gene: *Actin*
•	Calibrator: BS group (hard-coded in the script)
•	Relative expression: ( 2^{-\Delta\Delta Ct} )
## 5. **Model Description**
- The model is based on Elastic Net Regression (ENR) with:
•	α = 0.5
•	λ selected via cross-validation
- Input features:
•	Normalized *COMP ortholog* expression
•	Normalized *α-glucosidase* expression
- Output:
A continuous diet score (~1–3) reflecting metabolic state.
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
The input file must be a tab-delimited (.txt) file containing Ct values.
- Required column names:
     1-**Sample**; 2-**Ct_**Alpha_glucosidase***; 3-**Ct_*Actin*_*Alpha_glucosidase***; 4-**Ct_*COMP***; 5-**Ct_*Actin*_COMP**
## 8. **Output**
The application provides:
- Predicted diet scores
- Diet classification (BS-like or S-like)
- Interactive visualization
- Downloadable results (Excel and PNG formats)
## 9. **Intended Use**
This software is intended for academic research only.
Commercial use or redistribution requires written permission.
## 10. **Authorship**
Dr. Olga Frunze
Laboratory CRCIV, Prof. Hyung-Wook Kwon
Incheon National University, Republic of Korea
## 11. **Citation**
If you use this tool, please cite the associated publication (to be added).


