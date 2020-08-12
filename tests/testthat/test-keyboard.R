test_that("writes keyboard shortcuts", {
  # first pass ----
  shrtcts_text <- "
#' Some other shortcut
function() message('hello world')

#' Say Something Nice
#'
#' @description A demo of cool things
#' @interactive
#' @shortcut Ctrl+Alt+P
praise::praise
"
  prev_addins <- list(
    "something::else" = "Ctrl+Alt+A",
    "shrtcts::shortcut_02" = "Ctrl+Shift+P",
    "pkg::addin" = "Alt+Cmd+A"
  )

  tmp_shrtcts <- fs::path_temp(".shrtcts.R")
  tmp_addins <- fs::path_temp("addins.json")
  on.exit(unlink(c(tmp_shrtcts, tmp_addins, paste0(tmp_addins, ".bak"))))

  write_json(prev_addins, tmp_addins)
  writeLines(shrtcts_text, tmp_shrtcts)

  with_mock(
    write_addins = function(...) TRUE,
    is_interactive = function(...) TRUE,
    .env = "shrtcts",
    expect_message(add_rstudio_shortcuts(tmp_shrtcts, tmp_addins))
  )

  new_addins <- jsonlite::read_json(tmp_addins)

  expect_equal(names(new_addins)[2], "shrtcts::shortcut_02")
  expect_equal(new_addins[["shrtcts::shortcut_02"]], "Ctrl+Alt+P")

  # kept other addins
  expect_equal(names(new_addins)[-2], names(prev_addins)[-2])
  expect_equal(new_addins[[3]], prev_addins[[3]])

  # addins.json was backed up
  expect_true(fs::file_exists(paste0(tmp_addins, ".bak")))

  # write again, expect no output ----
  change_time <- fs::file_info(tmp_addins)$change_time
  with_mock(
    write_addins = function(...) TRUE,
    is_interactive = function(...) TRUE,
    .env = "shrtcts",
    expect_silent(add_rstudio_shortcuts(tmp_shrtcts, tmp_addins))
  )

  expect_equal(fs::file_info(tmp_addins)$change_time, change_time)

  # add another shortcut, expect update ----
  cat(
    "#' @title Another function",
    "#' @shortcut Ctrl+Alt+Shift+L",
    "#' @id 42",
    "function() message('the meaning of life')\n",
    sep = "\n",
    append = TRUE,
    file = tmp_shrtcts
  )

  with_mock(
    write_addins = function(...) TRUE,
    is_interactive = function(...) TRUE,
    .env = "shrtcts",
    expect_message(add_rstudio_shortcuts(tmp_shrtcts, tmp_addins))
  )

  prev_addins <- new_addins
  new_addins <- jsonlite::read_json(tmp_addins)

  expect_equal(names(new_addins)[2], "shrtcts::shortcut_02")
  expect_equal(new_addins[["shrtcts::shortcut_02"]], "Ctrl+Alt+P")

  expect_equal(names(new_addins)[4], "shrtcts::shortcut_42")
  expect_equal(new_addins[["shrtcts::shortcut_42"]], "Ctrl+Alt+Shift+L")

  # kept other addins
  expect_equal(names(new_addins)[1:3], names(prev_addins)[1:3])
  expect_equal(new_addins[1:3], prev_addins[1:3])
})
