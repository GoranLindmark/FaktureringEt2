#' OpenDb
#'
#' @returns mydb
#' @import DBI RSQLite

openDB <- function(){

  db_path <- system.file("x-rayReadings", "appData", "invoicing.sqlite", package = "FaktureringEt2")
  mydb <- DBI::dbConnect(RSQLite::SQLite(), db_path)

  return(mydb)

}
