library(tidyverse)

part2 <- readxl::read_excel("data-raw/Bedömda 2024-06.xlsx" ,sheet="Kundregister")  %>%
  select(Klinik = `Praktik kortnamn`, Klinik_namn = Praktik, email)


part1 <-
  readxl::read_excel("data-raw/Bedömda 2024-06.xlsx", skip=4 )%>%
  select(1:7)

data <-
  left_join(part1, part2, by = "Klinik")


data <-
  data %>%
  group_by(Klinik  ) %>%
  reframe( Klinik_namn = Klinik_namn,
           email = email,
           Veterinär = Veterinär,
           Djurägare = Djurägare,
           `Pat namn`= `Pat namn`,
           Antal = Antal,
           Besvarad = Besvarad,
           Belopp = Belopp,
           Besvarad = as.Date(Besvarad)) %>%
  group_by(Klinik) %>%
  reframe(  Klinik_namn = Klinik_namn,
            email = email,
            Belopp_Klinik = sum(Belopp),
            Moms = Belopp_Klinik * 0.25,
            Faktura_Belopp = Belopp_Klinik + Moms,
            Avläsningar = paste(Veterinär, Djurägare,`Pat namn`, Besvarad, Belopp, sep = " \t ", collapse = " \n "))

