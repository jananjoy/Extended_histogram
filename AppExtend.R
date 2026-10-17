
# ============================================================
# BIOS640 Exercise 1: Interactive NHANES Shiny App
# Author: Jananjoy Rajkumar
# Purpose: Explore, filter, visualize, and download NHANES data
# ============================================================
library(pacman)
library(DT)
pacman::p_load(
  shiny,
  tidyverse,
  here,
  rio,
  plotly,
  shinyjs
)

# Import and preprocess Alzheimer's data
alzheimer_data <- import(here("data", "alzheimers_data_clean.csv"))

# Pre-process: round specified numeric columns to 1 decimal place
numeric_columns <- c(
  "bmi", "alcohol", "physical_activity", "diet_quality",
  "sleep_quality", "mmse", "functional", "adl"
)

alzheimer_data <- alzheimer_data %>%
  mutate(across(all_of(numeric_columns), ~ round(.x, 1)))

# Define constants for UI components
min_age <- floor(min(alzheimer_data$age))
max_age <- ceiling(max(alzheimer_data$age))
gender_choice <- levels(factor(alzheimer_data$gender))
default_columns <- c(
  "patient_id", "age", "gender", "mmse", "functional",
  "memory", "behavioral", "adl", "diagnosis", "hospital"
)

# UI
ui <- navbarPage(
  title = "Advanced Shiny App",

  # Enable shinyjs for dynamically enabling and disabling controls.
  shinyjs::useShinyjs(),

  # Tab 1: About
  tabPanel(
    title = "About",
    fluidPage(
      h3("About This App"),
      p("This Shiny app demonstrates advanced functionalities including
		interactive plots, dynamic data tables,
        and tab-based navigation. It uses Alzheimer’s data to provide insights
        based on user-selected filters."),
      h4("Features:"),
      tags$ul(
        tags$li("Interactive scatter plot with customizable filters."),
        tags$li("Summary statistics for filtered data."),
        tags$li("Dynamic data table with column selection."),
        tags$li("Download option for filtered data."),
        tags$li("User-friendly tab-based navigation.")
      ),
      h3("About Alzheimer’s Disease"),
      p("Alzheimer’s disease is a progressive neurological disorder that causes
		brain cells to degenerate and die.
        It is the most common cause of dementia, characterized by memory loss,
		confusion, and difficulty performing everyday tasks.
        For more information, visit the ",
        tags$a(href = "https://www.alz.org", "Alzheimer's Association"), "."),
      h3("Understanding the MMSE Score"),
      p("The Mini-Mental State Examination (MMSE) is a commonly used test
		to assess cognitive function.
        It evaluates various cognitive domains, including memory, attention,
        language, and visual-spatial skills."),
      p("The MMSE is scored on a scale from 0 to 30:"),
      tags$ul(
        tags$li("Scores of 24-30 are generally considered normal."),
        tags$li("Scores of 18-23 may indicate mild cognitive impairment."),
        tags$li("Scores below 17 suggest severe cognitive impairment.")
      ),
      p("MMSE scores can help track the progression of Alzheimer’s disease and
        other forms of dementia.")
    )
  ),

  # Tab 2: Interactive Scatter Plot
  tabPanel(
    title = "Scatter Plot",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          h4("Filter Options"),
          sliderInput("age_range", "Age range selection:",
                      min = min_age, max = max_age,
                      value = c(min_age, max_age)
          ),
          br(),
          selectInput(
            "gender", "Gender selection:",
            choices = gender_choice,
            selected = gender_choice[2],
            multiple = TRUE
          ),
          textInput("color", "Enter point color:", value = "#ED1B2F"),
          br(),
          h5("Instructions:"),
          p("Use the filters above to refine the data displayed in the scatter plot.
            Enter a valid color name or hex code to customize the plot points.")
        ),
        mainPanel(
          plotlyOutput("scatterPlot"),
          br(),
          h5("Summary of Filtered Data:"),
          tableOutput("summaryStatistics")
        )
      )
    )
  ),


  # Tab 3: Histogram
  tabPanel(
    title = "Histogram",
    fluidPage(
      h4("Histogram of Age or MMSE Scores"),

      radioButtons(
        inputId = "hist_variable",
        label = "Select a variable to display:",
        choices = c(
          "Age" = "age",
          "MMSE Score" = "mmse"
        ),
        selected = "mmse",
        inline = TRUE
      ),

      sliderInput(
        inputId = "hist_age_range",
        label = "Select age range:",
        min = min_age,
        max = max_age,
        value = c(min_age, max_age),
        step = 1
      ),

      selectInput(
        inputId = "hist_fill",
        label = "Select a variable to color the histogram:",
        choices = c(
          "diagnosis",
          "ethnicity",
          "education",
          "memory",
          "behavioral",
          "symptom_confusion",
          "symptom_disorientation",
          "symptom_personality",
          "symptom_tasks",
          "symptom_forgetfulness"
        ),
        selected = "diagnosis"
      ),

      plotlyOutput("histogramPlot"),
      h4("MMSE Summary by Category"),
      tableOutput("summary_table")
    )
  ),

  # Tab 4: Data Table
  tabPanel(
    title = "Data Table",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          h4("Customize Table"),
          checkboxGroupInput(
            "columns", "Select Columns to Display:",
            choices = colnames(alzheimer_data),
            selected = default_columns
          )
        ),
        mainPanel(
          h4("Filtered Data Table"),
          DTOutput("dataTable"),
          br(),
          p("Only the selected columns will be included in the downloaded file."),
          downloadButton("downloadData", "Download Filtered Data")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {

  # Enable or disable controls based on the selected variable
  observe({
    if (input$hist_variable == "age") {
      shinyjs::enable("hist_age_range")
      shinyjs::disable("hist_fill")
    } else {
      shinyjs::disable("hist_age_range")
      shinyjs::enable("hist_fill")
    }
  })

  # Reactive data set
  filtered_data <- reactive({
    alzheimer_data %>%
      filter(
        age >= input$age_range[1] &
          age <= input$age_range[2] &
          gender %in% input$gender
      )
  })

  # Render scatter plot with Plotly
  output$scatterPlot <- renderPlotly({
    plotly::ggplotly(
      ggplot(filtered_data(), aes(x = age, y = mmse)) +
        geom_point(color = input$color, size = 1) +
        labs(
          x = "Age",
          y = "MMSE Score",
          title = "Scatter Plot of Age vs. MMSE"
        ) +
        theme_bw() +
        theme(
          plot.title = element_text(size = 16, face = "bold"),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10)
        )
    ) %>% config(
      modeBarButtonsToRemove = c(
        "autoScale2d", "lasso2d",
        "hoverCompareCartesian", "toggleSpikelines"
      ),
      toImageButtonOptions = list(
        format = "png",
        filename = "scatterplot",
        height = 800,
        width = 1200
      ),
      displaylogo = FALSE
    )
  })

  # Render summary statistics
  output$summaryStatistics <- renderTable({
    data <- filtered_data()

    if (length(unique(data$gender)) > 1) {
      data %>%
        group_by(gender) %>%
        summarise(
          `Sample Size` = n(),
          `Mean Age` = mean(age, na.rm = TRUE),
          `SD Age` = sd(age, na.rm = TRUE),
          `Mean MMSE` = mean(mmse, na.rm = TRUE),
          `SD MMSE` = sd(mmse, na.rm = TRUE)
        )
    } else {
      data %>%
        summarise(
          `Sample Size` = n(),
          `Mean Age` = mean(age, na.rm = TRUE),
          `SD Age` = sd(age, na.rm = TRUE),
          `Mean MMSE` = mean(mmse, na.rm = TRUE),
          `SD MMSE` = sd(mmse, na.rm = TRUE)
        )
    }
  })


  # Create the histogram
  output$histogramPlot <- renderPlotly({

    # Select the variable for the histogram
    if (input$hist_variable == "age") {

      # Age histogram
      plot_data <- alzheimer_data %>%
        filter(
          !is.na(age),
          age >= input$hist_age_range[1],
          age <= input$hist_age_range[2]
        )

      p <- ggplot(plot_data, aes(x = age)) +
        geom_histogram(
          binwidth = 5,
          fill = "#ED1B2F",
          color = "white"
        ) +
        labs(
          title = "Distribution of Age",
          x = "Age",
          y = "Number of Individuals"
        ) +
        theme_minimal()

    } else {

      # MMSE histogram: filter individuals using the selected age range
      plot_data <- alzheimer_data %>%
        filter(
          !is.na(mmse),
          !is.na(age),
          age >= input$hist_age_range[1],
          age <= input$hist_age_range[2],
          !is.na(.data[[input$hist_fill]])
        )

      p <- ggplot(
        plot_data,
        aes(
          x = mmse,
          fill = .data[[input$hist_fill]]
        )
      ) +
        geom_histogram(
          binwidth = 2,
          color = "white",
          position = "stack"
        ) +
        labs(
          title = paste0(
            "Distribution of MMSE Scores (Age ",
            input$hist_age_range[1], "–",
            input$hist_age_range[2], ")"
          ),
          x = "MMSE Score",
          y = "Number of Individuals",
          fill = input$hist_fill
        ) +
        theme_minimal()

    }

    ggplotly(p)
  })

  # 4. ADD THE MMSE SUMMARY TABLE HERE
  output$summary_table <- renderTable({

    alzheimer_data %>%
      filter(
        !is.na(mmse),
        !is.na(age),
        age >= input$hist_age_range[1],
        age <= input$hist_age_range[2]
      ) %>%
      mutate(
        mmse_category = case_when(
          mmse >= 25 & mmse <= 30 ~ "Normal (25–30)",
          mmse >= 18 & mmse < 25  ~ "Possible mild/moderate impairment (18–24)",
          mmse >= 0 & mmse < 18   ~ "Possible severe impairment (0–17)",
          TRUE ~ NA_character_
        )
      ) %>%
      filter(!is.na(mmse_category)) %>%
      group_by(mmse_category, diagnosis) %>%
      summarise(
        Number_of_Individuals = n(),
        Mean_MMSE = round(mean(mmse, na.rm = TRUE), 2),
        Median_MMSE = median(mmse, na.rm = TRUE),
        IQR_MMSE = IQR(mmse, na.rm = TRUE),
        Minimum_MMSE = min(mmse, na.rm = TRUE),
        Maximum_MMSE = max(mmse, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(mmse_category, diagnosis)

  }, striped = TRUE, bordered = TRUE, hover = TRUE)

  # Render data table
  output$dataTable <- renderDT({
    datatable(
      filtered_data()[, input$columns, drop = FALSE],
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        autoWidth = TRUE
      )
    )
  })

  # Download filtered data with selected columns
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("filtered_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      selected_data <- filtered_data() %>%
        select(all_of(input$columns))
      export(selected_data, file)
    }
  )
}

shinyApp(ui = ui, server = server)
#=============================================

