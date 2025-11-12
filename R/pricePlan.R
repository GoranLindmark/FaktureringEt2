#' pricePlan
#'
#' @param noDocuments
#'
#' @returns price

pricePlan <- function(noDocuments){

  if( noDocuments <= 7 ){
    price <- 600
  } else {
    price <- 800
  }

  return(price)
}
