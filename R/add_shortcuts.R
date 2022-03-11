#' Add Shortcuts to RStudio
#'
#' Add up to 100 fully configurable shortcuts to RStudio. Store your shortcuts
#' in `.shrtcts.yaml` in your R home or OS home directory. Then add
#' `add_rstudio_shortcuts()` to your `~/.Rprofile` to load the shortcuts when
#' starting R. Your shortcuts will automatically appear in the Addins window
#' (if not, try restarting your R session one more time). Your shortcuts can
#' be arbitrary functions written inline or functions from other packages. You
#' can set their names and even assign keyboard shortcuts to your shrtcts.
#' See detailed sections below.
#'
#' @includeRmd man/fragments/shrtcts-r-format.Rmd
#'
#' @includeRmd man/fragments/shrtcts-where-install.Rmd
#'
#' @includeRmd man/fragments/rstudio-keyboard-shortcuts.Rmd
#'
#' @includeRmd man/fragments/shrtcts-yaml-format.Rmd
#'
#' @param path The path to your `.shtrcts.yaml` file. If `NULL`, \pkg{shrtcts}
#'   will look in your R or OS home directory (via [fs::path_home_r()] or
#'   [fs::path_home()]). You can set this path via the global option
#'   `"shrtcts.path"`. For more information, see the help documentation on
#'   [paths].
#' @param set_keyboard_shortcuts If `TRUE`, will attempt to set the RStudio
#'   keyboard shortcuts in `addins.json`.
#'
#' @examples
#' # Add shortcuts to ~/.shrtcts.yaml (see help above)
#'
#' # Add this to your ~/.Rprofile to automatically load shortcuts
#' if (interactive() && requireNamespace("shrtcts", quietly = TRUE)) {
#'   shrtcts::add_rstudio_shortcuts()
#' }
#'
#' @seealso [list_shortcuts()]
#' @export
add_rstudio_shortcuts <- function(path = NULL, set_keyboard_shortcuts = FALSE) {
  if (!is_interactive()) return(invisible())

  path <- locate_shortcuts_source(path)

  shortcuts <- parse_shortcuts(path)

  if (!length(shortcuts)) return(invisible())

  write_addins(shortcuts)
  if (is.character(set_keyboard_shortcuts) || isTRUE(set_keyboard_shortcuts)) {
    write_keyboard_shortcuts(
      shortcuts,
      path = if (!is.logical(set_keyboard_shortcuts)) set_keyboard_shortcuts
    )
  }

  invisible(path)
}

#' @describeIn add_rstudio_shortcuts An example `.shrtcts.yml` file.
#' @export
example_shortcuts_yaml <- function() {
  x <- readLines(system.file("ex-shrtcts.yaml", package = "shrtcts"))
  cat(x, sep = "\n")
  invisible(x)
}

#' @describeIn add_rstudio_shortcuts An example `.shrtcts.R` file.
#' @export
example_shortcuts_r <- function() {
  x <- readLines(system.file("ex-shrtcts.R", package = "shrtcts"))
  cat(x, sep = "\n")
  invisible(x)
}

#' Open the shrtcts Source File
#'
#' This helper function locates and opens (or returns the path to) the
#' `.shrtcts.R` or `.shrtcts.yml` file.
#'
#' @param open If `TRUE` and the shrtcts source file is found (see [paths]),
#'   then the file is opened via `file.edit()`. Otherwise, the path is returned.
#' @inheritParams add_rstudio_shortcuts
#'
#' @return The path to the `.shrtcts.R` or `.shrtcts.yml` source file (invisibly
#'  if the file is opened).
#'
#' @export
edit_shortcuts <- function(open = TRUE, path = NULL) {
  path <- locate_shortcuts_source(path)
  if (is.null(path)) {
    path <- maybe_create_shortcuts_file()
  }
  if (isTRUE(open)) {
    if (
      requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::hasFun("navigateToFile")
    ) {
      rstudioapi::navigateToFile(path)
    } else {
      utils::file.edit(as.character(path))
    }
    invisible(path)
  } else {
    path
  }
}

how_to_use <- function() utils::`?`(shrtcts::add_rstudio_shortcuts)

as_dcf <- function(x) {
  txt <- ""
  txt_con <- textConnection("txt", "w", local = TRUE)
  lapply(x, function(s) {
    if (is_likely_packaged_fn(s[["function"]])) {
      s[["Interactive"]] <- FALSE
    }
    s <- s[c("Name", "Description", "Interactive", "Binding")]
    write.dcf(s, txt_con)
    cat("\n", file = txt_con)
  })
  close(txt_con)
  txt
}

write_addins <- function(x) {
  x <- as_dcf(x)
  outdir <- fs::path(system.file(package = "shrtcts"), "rstudio")
  fs::dir_create(outdir)
  writeLines(x, fs::path(outdir, "addins.dcf"))
}

is_likely_packaged_fn <- function(f_text) {
  length(f_text) == 1 &&
    !grepl("\n", f_text) &&
    grepl("^[a-zA-Z][a-zA-Z0-9.]+[:]{2,3}\\w+$", f_text)
}
