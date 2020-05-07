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

mydata = read.csv("mtcars.csv", header = T,row.names =NULL)

attach(mydata)

server = function(input, output, session){
    
    # table for the Data table tab
    
    output$tableDT <- DT::renderDataTable(DT::datatable(mydata))
    
    
    output$scat = renderPlot({
        ggplot(mydata, aes(mpg, disp)) +
            geom_point() + geom_smooth(method = "lm") +
            xlab("Miles/(US) gallon") + ylab("Displacement (cu.in.)")
    })
    
    
    mydata.new = reactive({
        
        user_brush <- input$user_brush
        mysel <- brushedPoints(mydata, user_brush)
        return(mysel)
        
    })
    
    
    output$table = DT::renderDataTable(DT::datatable(mydata.new()))
    
    output$mydownload = downloadHandler(
        filename = "selected_cars.csv",
        content = function(file) {
            write.csv(mydata.new(), file)})
    
    
}

ui = navbarPage(theme = shinytheme("sandstone"), title = h3("MTCars dataset analysis"),
                tabPanel(
                    ("Miles per gallon vs. diesplacement"),
                    
                    plotOutput("scat", brush = "user_brush"),
                    DT::dataTableOutput("table"),
                    downloadButton(outputId = "mydownload", label = "Download Table")
                ),
                
                tabPanel("Documentation",
                         h4("Project Functionalities:"),
                         tags$div(
                             "1. Visualize the relationship between miles per gallon and displacement of the cars in the MTcars dataset.", 
                             tags$br(),
                             "2. Select observations on a graph using brush feature from the DataTables shiny package.",
                             tags$br(),
                             "3. Display selected observations in a data table.",
                             tags$br(),
                             "4. Filter record in a data table via theSearch Field.",
                             tags$br(),
                             "5. Move to the 'Previous' or 'Next' tab of data table",
                             tags$br(),
                             "6. Download selected observations to .csv",
                             
                         )
                         
                )
)

shinyApp(ui = ui, server = server)