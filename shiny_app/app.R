library(shiny)
library(tidyverse)
library(httr)
library(scales)

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
                         max = 6500)
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
    sex_pred <- reactive({
        httr::GET(
            "https://colorado.rstudio.com/rsc/penguins_api/pred",
            query = list(
                species = input$species,
                bill_length_mm = input$bl,
                bill_depth_mm = input$bd,
                flipper_length_mm = input$fl,
                body_mass_g = input$bm
            )
        ) %>%
            httr::content() %>%
            map_df(as_tibble) %>%
            rename(Female = .pred_female, Male = .pred_male) %>%
            pivot_longer(
                cols = c(Male, Female),
                names_to = "Sex",
                values_to = "Probability"
            )
    })
    
    # Plot Probabilities
    output$sex_prob_plot <- renderPlot({
        ggplot(sex_pred(), aes(x = Sex, y = Probability)) +
            geom_bar(stat = "identity") +
            theme_minimal() +
            labs(x = "") +
            scale_y_continuous(labels = percent_format(scale = 100)) +
            theme(
                axis.text = element_text(size = 15),
                axis.title = element_text(size = 18)
            )
        
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
