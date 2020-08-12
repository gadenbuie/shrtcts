#' 10 random numbers
#'
#' @description 
#' @id 1
#' @interactive
function() {
    runif(10, 0, 10)
}

#' Say Something Nice
#'
#' @description A demo of cool things
#' @id 97
#' @interactive
function() {
    praise::praise
}

#' New Temporary R Markdown Document
#'
#' @description 
#' @id 2
function() {
    tmp <- tempfile(fileext = ".Rmd")
    rmarkdown::draft(tmp, template = "github_document", package = "rmarkdown", edit = FALSE)
    rstudioapi::navigateToFile(tmp)
}

#' A Random Number Between 0 and 1
#'
#' @description Another demo
#' @id 3
#' @interactive
function() {
    runif(1, 0, 1)
}
