#' List Shortcuts and Their Current Key Bindings
#'
#' Lists all shortcuts declared in `.shrtcts.R` or `.shrtcts.yml`. Also lists
#' the currently assigned RStudio keyboard shortcuts.
#'
#' @param path_shortcuts Path to `.shrtcts.R` or `.shrtcts.yml`. See [locate_shortcuts_source()] for more detail.
#' @param path_addins_json Path to RStudio's `addins.json` keybindings config file. See [locate_addins_json()] for more detail.
#'
#' @examples
#' if (
#'   interactive() &&
#'   requireNamespace("rstudioapi", quietly = TRUE) &&
#'   rstudioapi::hasFun("versionInfo")
#'  ) {
#'   list_shortcuts()
#' }
#'
#' @return A data frame with the shortcut `name`, it's assigned `addin`
#'   placeholder function, the `shrcts_keybinding` declared in the shrtcts
#'   source file, and the `rstudio_keybinding` currently assigned to the
#'   shortcut in RStudio.
#' @seealso [add_rstudio_shortcuts()], [paths]
#' @export
list_shortcuts <- function(path_shortcuts = NULL, path_addins_json = NULL) {
  path_shortcuts <- locate_shortcuts_source(path_shortcuts)
  path_addins_json <- locate_addins_json(path_addins_json)

  shtcts <- parse_shortcuts(path_shortcuts)
  if (!length(shtcts)) {
    message("[shrtcts] No shortcuts.")
    return(invisible(NULL))
  }
  shtcts <- lapply(shtcts, function(sh) {
    data.frame(
      name = sh$Name,
      addin = sh$Binding,
      shrtcts_keybinding = sh$shortcut %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  shtcts <- do.call("rbind", shtcts)

  kbd_shtcts <- if (!is.null(path_addins_json)) {
    kbd_rstudio <- jsonlite::fromJSON(path_addins_json, simplifyVector = FALSE)
    unlist(kbd_rstudio[grepl("^shrtcts::", names(kbd_rstudio))])
  }

  if (is.null(kbd_shtcts)) {
    shtcts$rstudio_keybinding <- NA_character_
    return(shtcts)
  }

  rstudio <- data.frame(
    addin = names(kbd_shtcts),
    rstudio_keybinding = unname(kbd_shtcts),
    stringsAsFactors = FALSE
  )
  rstudio$addin <- sub("^shrtcts::", "", rstudio$addin)

  z <- merge(rstudio, shtcts, by = "addin", all = TRUE)
  z[c("name", "addin", "shrtcts_keybinding", "rstudio_keybinding")]
}
