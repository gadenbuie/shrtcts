migrate_yaml2r <- function(path, output = fs::path_ext_set(path, "R")) {
  sh <- parse_shortcuts(path)

  sh_txt <- vapply(sh, FUN.VALUE = character(1), USE.NAMES = FALSE, function(x) {
    title <- sprintf("#' %s\n#'", x$Name)
    desc <- if (!is.null(x$Description) && nzchar(x$Description)) {
      sprintf("#' @description %s", gsub("\n", " ", trimws(x$Description)))
    }
    interactive <- if (isTRUE(x$Interactive)) "#' @interactive"
    id <- if (!is.null(x$id)) sprintf("#' @id %d", x$id)
    shortcut <- if(!is.null(x$shortcut)) sprintf("#' @shortcut %s", x$shortcut)

    roxy <- c(title, desc, id, shortcut, interactive, x[["function"]])

    paste(roxy, collapse = "\n")
  })

  sh_txt <- paste(sh_txt, collapse = "\n\n")
  if (is.null(output)) return(sh_txt)

  writeLines(sh_txt, output)
  message("[shrtcts] Wrote shortcuts in roxygen2 style to ", output)
  invisible(output)
}
