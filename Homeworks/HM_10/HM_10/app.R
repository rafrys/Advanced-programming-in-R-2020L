#---------------------------------------------------------#
#               Advanced Programming in R                 #
#              10.   asics of Shiny                       #  
#                Academic year 2019/2020                  #
#                Rafal Rysiejko, 423827                   #
#---------------------------------------------------------# 

library(shiny)
library(DT)
library(ggplot2)
library(shinythemes)
library(tidyverse)

mydata = read.csv("mtcars.csv", header = T,row.names =NULL)

attach(mydata)

server = function(input, output, session){
    
    mydata_filtered <- reactive({
        mydata %>%
            filter(
                between(disp, input$displacement_var[1], input$displacement_var[2]),
                cyl %in% input$cylinders)
    })

    
    output$tableDT <- DT::renderDataTable(DT::datatable(mydata_filtered()))
    
    
    output$scat = renderPlot({
        ggplot(mydata_filtered(), aes(mpg, disp)) +
            geom_point() + geom_smooth(method = "lm") +
            xlab("Miles/(US) gallon") + ylab("Displacement (cu.in.)")
    })
    
    
    mydata.new = reactive({
        
        user_brush <- input$user_brush
        mysel <- brushedPoints(mydata_filtered(), user_brush)
        return(mysel)
        
    })
    
    
    output$table = DT::renderDataTable(DT::datatable(mydata.new()))
    
    output$mydownload = downloadHandler(
        filename = "selected_cars.csv",
        content = function(file) {
            write.csv(mydata.new(), file)})
    
    
}
###########
### UI ###

ui = navbarPage(theme = shinytheme("sandstone"), title = h3("MTCars dataset analysis"),
                tabPanel(
                    ("Miles per gallon vs. diesplacement"),
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("cylinders", "Cylinders - Multiselect",
                                        c("Four" = 4,
                                          "Six" = 6,
                                          "Eight" = 8),multiple = T),
                            sliderInput("displacement_var", HTML("Displacement [CU<sup>2</sup>]:"),
                                        min = 100, max = 360, value = c(100, 300), step = 10)
                        ),
                        mainPanel(
                            plotOutput("scat", brush = "user_brush")
                        )
                    ),
                    DT::dataTableOutput("table"),
                    downloadButton(outputId = "mydownload", label = "Download Table")
                ),
                
                tabPanel("Documentation",
                         h4("Project Functionalities:"),
                         tags$div(
                             "1. (Multi) select the number of cylinders (four,six,eight) of the cars in the MTcars dataset..", 
                             tags$br(),
                             "2. Select the range of engine displacement by using a slider.", 
                             tags$br(),
                             "3. Visualize the relationship between miles per gallon and displacement.", 
                             tags$br(),
                             "4. Select observations on a graph using brush feature from the DataTables shiny package.",
                             tags$br(),
                             "5. Display selected observations in a data table.",
                             tags$br(),
                             "6. Filter record in a data table via theSearch Field.",
                             tags$br(),
                             "7. Move to the 'Previous' or 'Next' tab of data table",
                             tags$br(),
                             "8. Download selected observations to .csv",
                             
                         )
                         
                )
)

shinyApp(ui = ui, server = server)