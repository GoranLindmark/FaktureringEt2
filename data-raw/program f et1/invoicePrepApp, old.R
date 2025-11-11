#define packages to install

packages <- c('shiny', 'dplyr', 'tidyr', 'readr', 'readxl', 'xlsx')

#install all packages that are not already installed
install.packages(setdiff(packages, rownames(installed.packages())), repos = "https://cran.r-project.org")
library(shiny)
library(dplyr)
library(tidyr)
library(readr)
library(readxl)
library(xlsx)

ui <- fluidPage(
  titlePanel("Data Formatter"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose Excel File", accept = ".xlsx"),
      actionButton("process", "Process Data"),
      # actionButton("store", "download new sheet"),
      downloadButton("downloadData", "Download Formatted Data")
    ),
    mainPanel(
      tableOutput("table")
    )
  )
)

server <- function(input, output, session) {

  data <- reactive({
    req(input$file)
    fileName <- input$file
    read_xlsx(input$file$datapath, skip = 4, sheet = "ofakturerat") %>%
      select(1:7)
  })

  formatted_data <- eventReactive(input$process, {
    req(data())
    data() %>%
      group_by(Klinik  ) %>%
      reframe( Veterinär = Veterinär,
               Djurägare = Djurägare,
               `Pat namn`= `Pat namn`,
               Antal = Antal,
               Besvarad = Besvarad,
               Belopp = Belopp,
               Besvarad = as.Date(Besvarad)) %>%
      group_by(Klinik) %>%
      reframe(  Belopp_Klinik = sum(Belopp),
                Moms = Belopp_Klinik * 0.25,
                Faktura_Belopp = Belopp_Klinik + Moms,
                Avläsningar = paste(Veterinär, Djurägare,`Pat namn`, Besvarad, Belopp, sep = " \t ", collapse = " \n "))



  })

  output$table <- renderTable({ formatted_data() })

  # output$store <- eventReactive(input$store, {
  #
  #   write.xlsx( formatted_data() , fileName, sheetName = "wertyt", append = T)
  # })

  output$downloadData <- downloadHandler(
    filename = function() { "formatted_data.xlsx" },
    content = function(file) { write.xlsx( formatted_data() , file, sheetName = "qwer")}
  )
}

runApp(shinyApp(ui = ui, server = server), launch.browser = TRUE)
