library(shiny)
library(rCharts)

shinyUI(fluidPage(
  titlePanel("US College Ratings Review"),
  
  sidebarLayout(position="left",
    sidebarPanel(
      p("Data Filters:"),
      br(),
      selectInput("type", label="College Type", choices=c("All", "University", "Liberal Arts"), selected="All"),
      selectInput("region", label="US Region", choices=c("All", "Central South", "Midwest", "Mountain", "Northeast", "South Atlantic", "West Coast"), selected="All"),
      selectInput("ownership", label="Ownership", choices=c("All", "Private", "State"), selected="All")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Chart", showOutput("ratingsChart", "polycharts")),
        tabPanel("Documentation", uiOutput("help_file"))
      )
    )
  )

))
