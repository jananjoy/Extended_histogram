# Extended_histogram using Shiny

## Overview

This project is an interactive R Shiny application developed to explore and visualize Alzheimer’s disease-related data. It allows users to examine age distributions, MMSE (Mini-Mental State Examination) scores, diagnosis categories, and summary statistics through an interactive interface.

## Features

- **Interactive Scatter Plot:** Explore relationships between selected variables using interactive visualizations.
- **Age Histogram:** Visualize the age distribution and filter observations by a selected age range.
- **MMSE Histogram:** Explore MMSE score distributions on a fixed 0–30 scale.
- **Dynamic Controls:** Enable or disable the age-range slider and category-selection dropdown based on the selected histogram variable.
- **Age-Range Filtering:** Filter the MMSE histogram and summary results using the selected age range.
- **MMSE Summary Table:** Display sample size, mean, median, interquartile range (IQR), minimum, and maximum MMSE scores by diagnosis.
- **Interactive Data Table:** Select columns to display and explore the dataset.
- **Download Functionality:** Download filtered data for further analysis.
- **About Tab:** Provide information about the application, Alzheimer’s disease, and MMSE scores.

## Technologies Used

- R
- Shiny
- Tidyverse
- ggplot2
- Plotly
- DT
- shinyjs
- rio
- here

## Project Structure

```text
.
├── AppExtend.R
├── data/
│   └── alzheimers_data_clean.csv
└── README.md
```

## Installation

1. Install [R](https://cran.r-project.org/) and [RStudio](https://posit.co/download/rstudio-desktop/).
2. Clone or download this repository.
3. Open the project folder in RStudio.
4. Install the required R packages:

```r
install.packages(c(
  "shiny",
  "tidyverse",
  "here",
  "rio",
  "plotly",
  "shinyjs",
  "DT"
))
```

## Running the Application

Ensure that the dataset is located at `data/alzheimers_data_clean.csv` relative to the project root.

Run the following command in the RStudio Console:

```r
shiny::runApp("AppExtend.R")
```

Alternatively, open `AppExtend.R` in RStudio and run the application from the script.

## How to Use

1. Open the **About** tab to learn about the application and MMSE scores.
2. Use the **Scatter Plot** tab to explore data with interactive filters.
3. Open the **Histogram** tab and select Age or MMSE Score.
4. Adjust the age range to examine the relevant population. When MMSE Score is selected, the age-range slider is disabled, but its selected range is still applied to the histogram and summary results.
5. Select a category, such as diagnosis, to compare MMSE score distributions.
6. Review the MMSE summary table for descriptive statistics by diagnosis.
7. Open the **Data Table** tab to select columns and download data.

## MMSE Score Interpretation

The MMSE is a cognitive screening instrument with a score range of 0–30. The application uses score groupings for exploratory visualization and summary purposes. These groupings are not a clinical diagnosis, and interpretation should consider factors such as education, language, and clinical context.

## Purpose

The application demonstrates interactive data exploration, filtering, visualization, descriptive statistical analysis, and dynamic user-interface behavior using R Shiny.

## Author

Jananjoy Rajkumar

## Disclaimer

This application is intended for educational and exploratory data analysis. It is not a medical diagnostic tool and should not be used as a substitute for professional medical assessment.
