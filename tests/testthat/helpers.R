parse_shortcuts_text <- function(text, ext = "R") {
  file <- fs::file_temp(ext = ext)
  on.exit(unlink(file))
  writeLines(text, file)

  parse_shortcuts(file)
}
