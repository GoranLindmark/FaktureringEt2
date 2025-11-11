library(officer)
library(tidyverse)

createWriteSave <- function(){

  # create empty Word file
  sample_doc <- read_docx()

  sample_doc <- sample_doc %>%
    body_add_par("This is the first paragraph")
  sample_doc <- sample_doc %>%
    body_add_par("This is the second paragraph")
  sample_doc <- sample_doc %>%
    body_add_par("This is the third paragraph")

  # create sample data frame
  df <- data.frame(a = 1:10, b = 11:20, c= 21:30)

  # add table containing the data frame's contents
  sample_doc <-
    sample_doc %>%
    body_add_table(df, style = "table_template")


  print(sample_doc, target = "sample_file.docx")


}

readxl::read_excel(path = "data-raw/Bedömda 2024-06.xlsx", skip = 4, sheet =  "Månadens Bedömningar" ) %>%
  select(Klinik, Veterinär, Djurägare, `Pat namn`, Antal, Besvarad, Belopp) %>%
  group_by(Klinik  ) %>%
  reframe( Veterinär = Veterinär,
             Djurägare = Djurägare,
             `Pat namn`= `Pat namn`,
             Antal = Antal,
             Besvarad = Besvarad,
             Belopp = Belopp,

             Besvarad = as.Date(Besvarad),
             .groups = "drop") %>%
  group_by(Klinik) %>%
  reframe(  Belopp_Klinik = sum(Belopp),
              Moms = Belopp_Klinik * 0.25,
              Faktura_Belopp = Belopp_Klinik + Moms,
              Avläsningar = paste(Veterinär, Djurägare,`Pat namn`, Besvarad, Belopp, sep = " \t ", collapse = " \n ")) %>%
  write.csv(file = "data/fakturaunderlag.csv", row.names=FALSE)


