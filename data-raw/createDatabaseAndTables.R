library(RSQLite)
library(DBI)
library(tidyverse)
library(readxl)



# Create the database

mydb <- DBI::dbConnect(RSQLite::SQLite(), "invoicing.sqlite")

# Create the table for customer register

custRegister <- readxl::read_excel("data-raw/Indata f et1/Bedömda 2024-2025.xlsx",
                           sheet = "Kundregister")

DBI::dbWriteTable(mydb, "custReg", custRegister)

# create the table for observations

observations <-
  readxl::read_excel("data-raw/Indata f et1/Bedömda 2024-2025.xlsx",
                           sheet = "Avläsningar", skip = 5) %>%
  dplyr::select(-...9, -...10) %>%
  dplyr::filter(!is.na(Veterinär)) %>%
  dplyr::mutate(InvoiceCreated = ifelse(Fakturerat == 1, T, F)) %>%
  dplyr::mutate( Clinic = Klinik, Vet = Veterinär, PetOwner = Djurägare, Patient = `Pat namn`,
          NoPics = Antal, AnsDate = as.Date(as.numeric(Besvarad), origin = "1899-12-30")) %>%
  dplyr::select(-Klinik, -Veterinär, -Djurägare, -'Pat namn', -Antal, -Besvarad, -Fakturerat)

DBI::dbWriteTable(mydb, "observations", observations)

DBI::dbListTables(mydb)

DBI::dbDisconnect(mydb)


# This is how we work with the database

db_path <- system.file("x-rayReadings", "appData", "invoicing.sqlite", package = "FaktureringEt2")
mydb <- DBI::dbConnect(RSQLite::SQLite(), db_path)


dbListTables(mydb)

custReg <- dplyr::tbl(mydb, "custReg")

view(custReg)
