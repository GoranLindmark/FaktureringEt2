library(tidyverse)
library(readxl)


data <- read_excel("data-raw/Bedömda 2024-06.xlsx",skip = 4)


data <- data[, 1:7]

data <-
  data %>%

  mutate(Veterinär = paste(Veterinär, Klinik, sep = " - "))

klinik <-
  data %>%
  select(Klinik, Veterinär)

fall <-
  data %>%
  select(-Klinik) %>%
    mutate(fall = 1:nrow(.))

fakturaunderlag
  fall %>%
    inner_join(klinik, by = c("Veterinär"))

