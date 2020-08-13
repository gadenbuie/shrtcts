
write_keyboard_shortcuts <- function(shortcuts, path = NULL) {
  stopifnot(is_shrtcts(shortcuts))

  # has a kbd shortcut if $shortcut is non-empty, non-zero string
  has_kbd <- vapply(shortcuts, function(x) {
    has_entry <- !is.null(x$shortcut) && is.character(x$shortcut)
    if (!has_entry) return(FALSE)
    nzchar(x$shortcut) && length(x$shortcut) == 1
  }, logical(1))

  if (!any(has_kbd)) return()

  sh <- shortcuts[has_kbd]
  kbd_shrtcts <- list()
  for (i in seq_along(shortcuts[has_kbd])) {
    sh_id <- paste0("shrtcts::", sh[[i]][["Binding"]])
    kbd_shrtcts[[sh_id]] <- sh[[i]][["shortcut"]]
  }

  path <- locate_addins_json(path)

  kbd_rstudio <- jsonlite::fromJSON(path, simplifyVector = FALSE)

  # remove all current "shrtcts::" keyboard shortcuts
  kbd_other <- kbd_rstudio[!grepl("^shrtcts::", names(kbd_rstudio))]

  # add new (or current) keyboard shortcuts
  kbd_new <- c(kbd_other, kbd_shrtcts)
  # ... keep order of original but only the ones that are in new
  kbd_names_order <- intersect(names(kbd_rstudio), names(kbd_new))
  # ... and also any new shortcuts we're adding now
  kbd_names_order <- union(kbd_names_order, names(kbd_new))
  kbd_new <- kbd_new[kbd_names_order]

  # do we have new shortcuts or changes?
  has_changed <- !identical(kbd_rstudio, kbd_new)

  if (!has_changed) return()

  fs::file_copy(path, paste0(path, ".bak"), overwrite = TRUE)
  write_json(kbd_new, path)
  message("[shrtcts] Keyboard shortcuts were updated. Restart RStudio to enable.")

  invisible(path)
}

write_json <- function(x, path) {
  x <- jsonlite::toJSON(x, auto_unbox = TRUE, pretty = 4)
  writeLines(trimws(x), path)
}
