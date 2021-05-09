library(shiny)
library(tidyverse)
library(httr)

# Define UI
ui <- fluidPage(

    # Application title
    titlePanel("Penguin Sex Prediction"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "species",
                        label = "Species",
                        choices = c("Adelie", "Gentoo", "Chinstrap"),
                        ),
            numericInput(inputId = "bl", 
                         label = "Bill Length (mm)", 
                         value = 38,
                         min = 30, 
                         max = 60),
            numericInput(inputId = "bd", 
                         label = "Bill Depth (mm)", 
                         value = 17,
                         min = 13, 
                         max = 22),
            numericInput(inputId = "fl", 
                         label = "Flipper Length (mm)", 
                         value = 200,
                         min = 170, 
                         max = 240),
            numericInput(inputId = "bm", 
                         label = "Body Mass (g)", 
                         value = 3500,
                         min = 2500, 
                         max = 6500),
            actionButton("go", "Predict!")
        ),

        # Show Female or Male
        mainPanel(
           plotOutput("sex_prob_plot")
        )
    )
)

# Define server
server <- function(input, output) {

    # Use API to get penguin sex prediction
    sex_pred <- eventReactive(
        input$go,
        {
            httr::GET(
                "https://colorado.rstudio.com/rsc/penguins_api/pred",
                query = list(
                    species = "Adelie",
                    bill_length_mm = input$bl,
                    bill_depth_mm = input$bd,
                    flipper_length_mm = input$fl,
                    body_mass_g = input$bm
                ),
                add_headers(Authorization = paste0(
                    "Key ", Sys.getenv("CONNECT_API_KEY")
                ))
            ) %>%
                httr::content() %>% 
                map_df(as_tibble) %>% 
                rename(Female = .pred_female, Male = .pred_male) %>% 
                pivot_longer(cols = c(Male, Female), 
                             names_to = "Sex", 
                             values_to = "Probability")
    })
    
    output$sex_prob_plot <- renderPlot({
        ggplot(sex_pred(), aes(x = Sex, y = Probability)) +
            geom_bar(stat = "identity")
        
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
