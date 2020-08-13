test_that("functions are parsed and run correctly", {
  text <- "
#' @title anonymous
#' @interactive
function() {
  'apple'
}

#' @title named
#' @interactive
test <- function() 'banana'

#' @title packaged
#' @interactive
shrtcts:::test_fun
"

  tmp_shrtcts <- fs::path_temp("shrtcts.R")
  writeLines(text, tmp_shrtcts)
  on.exit(fs::file_delete(tmp_shrtcts))

  options(shrtcts.path = tmp_shrtcts)
  on.exit(options(shrtcts.path = NULL), add = TRUE)

  expect_equal(run_shortcut(1), "apple")
  expect_equal(run_shortcut(2), "banana")
  expect_equal(run_shortcut(3), "mango")
})
