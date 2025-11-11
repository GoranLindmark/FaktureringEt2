#define packages to install
packages <- c('shiny', 'dplyr', 'tidyr', 'readr', 'readxl', 'xlsx', 'lubridate', 'shinyjs')

#install all packages that are not already installed
install.packages(setdiff(packages, rownames(installed.packages())), repos = "https://cran.r-project.org")
library(shiny)
library(dplyr)
library(tidyr)
library(readr)
library(readxl)
library(xlsx)
library(shinyjs)
library(lubridate)


ui <- fluidPage(
  titlePanel("Data Formatter"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose Excel File", accept = ".xlsx"),
      actionButton("process", "Process Data"),
      downloadButton("downloadData", "Download Formatted Data")
    ),
    mainPanel(
      tableOutput("processed_table")
    ))
)

server <- function(input, output, session) {

  # Reactive expression to read the Excel file
  data <- reactive({
    req(input$file)
    save_path <- dirname(input$file$datapath)
    list(
      Avläsningar = filter(read_xlsx(input$file$datapath, skip = 5,  sheet = "Avläsningar",
                                     col_types = c("numeric",
                                                   "text", "text", "text", "text", "text",
                                                   "date", "numeric", "skip", "skip")),
                           Fakturerat  == 0) %>%
        select(Klinik, Veterinär, Djurägare, `Pat namn`, Besvarad, Antal, Belopp),
      kundregister = read_xlsx(input$file$datapath, sheet = "Kundregister")
    )
    ...
  })

  session$onSessionEnded(function() {
    stopApp()
  })

  # Process
  formatted_data <- eventReactive(input$process, {
    req(data())
    # Identify unmatched Kliniks
    diff <- data()$Avläsningar %>%
      anti_join(data()$kundregister, by = "Klinik") %>%
      select(Klinik)

    if (any(nrow(diff)) > 0) {
      # Show warning modal with actual clinic names
      showModal(modalDialog(
        title = "Warning",
        "Följande kliniker gick ej att hitta i Kundregistret:",
        renderTable(diff), # Display the actual unmatched Kliniks
        easyClose = TRUE,
        footer = NULL
      ))

      return(diff) # Return unmatched Kliniks for debugging
    } else {
      # Proceed with data formatting
      return(
        data()$Avläsningar %>%
          inner_join(data()$kundregister, by = "Klinik") %>%

          group_by(Klinik, email, Adress) %>%
          summarize(
            Delsumma = sum(Belopp, na.rm = TRUE),
            moms = Delsumma * 0.25,
            Att_Betala = Delsumma + moms,
            Avläsningar = paste(Veterinär, Djurägare,`Pat namn`, Besvarad,
                                Antal, Belopp, sep = "\t", collapse = "\n"),
            .groups = "drop" ) %>%
          mutate(FakturaNr = "") %>%
          mutate(FakturaDatum = "") %>%
          mutate(FörfalloDatum = "") %>%
          mutate(Betalat = "") %>%
          select(Klinik, email, Adress, FakturaNr, FakturaDatum, FörfalloDatum, Betalat, everything()) %>%
          mutate( Avläsningar = paste( "Veterinär\t Djurägare\t Pat namn\t Besvarad\t Antal\t Belopp\n \n",
                                       Avläsningar))
      )
    }
  })

  # Display the processed data or unmatched Kliniks
  output$processed_table <- renderTable({
    req(formatted_data())
    formatted_data() # Displays either unmatched Kliniks or formatted data
  })


  # Download handler for the formatted data
  output$downloadData <- downloadHandler(
    filename = function() { "formatted_data.xlsx" },

    content = function(file) {
      req(formatted_data())  # Ensure data exists before proceeding

      df_to_save <- as.data.frame(formatted_data())  # Convert tibble to a standard dataframe

      write.xlsx(df_to_save, file, row.names = FALSE)  # Save as an Excel file
      runjs("window.close();")

    })
}


runApp(shinyApp(ui = ui, server = server), launch.browser = TRUE)
# End of the script
