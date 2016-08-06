shinyUI(fluidPage(theme="bootstrap.css",
  
  titlePanel("Exchange Rates to Canadian over Time"),
  "Click on the different options in the left panel to view on graph. Clicking on moving average will display a slider for the window size of the moving average.",
  "Code can be found on ",
  a("Github",href="https://github.com/graeme-j/DataProducts/tree/gh-pages"),
  sidebarLayout(
    sidebarPanel(
      checkboxInput(inputId = "trendline",
                    label = strong("Show trendline"),
                    value = FALSE),
      
      checkboxInput(inputId = "forecast",
                    label = strong("Show 6 Month Forecast"),
                    value = FALSE),
      
      checkboxInput(inputId = "rolling_avg",
                    label = strong("Show moving average"),
                    value = FALSE),
      
      conditionalPanel(condition = "input.rolling_avg == true",
                       sliderInput("ma_size", "Length of Moving Average:", 
                                   min=2, max=7, value=2)
      )
    ),
    mainPanel(
      plotOutput(outputId = "main_plot", height = "600px")
    )
  )
  
))