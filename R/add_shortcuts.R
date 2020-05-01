#' Add Shortcuts to RStudio
#'
#' Add up to 100 fully configurable shortcuts to RStudio. Store your shortcuts
#' in `.shrtcts.yaml` in your R home or OS home directory. Then add
#' `add_rstudio_shortcuts()` to your `~/.Rprofile` to load the shortcuts when
#' starting R. Your shortcuts will automatically appear in the Addins window
#' (if not, try restarting your R session one more time). Your shortcuts can
#' be arbitrary functions written inline or functions from other packages. You
#' can set their names and even assign keyboard shortcuts to your shrtcts.
#'
#' @includeRmd man/fragments/shrtcts-yaml-format.Rmd
#'
#' @includeRmd man/fragments/rstudio-keyboard-shortcuts.Rmd
#'
#' @param path The path to your `.shtrcts.yaml` file. If `NULL`, \pkg{shrtcts}
#'   will look in your R or OS home directory (via [fs::path_home_r()] or
#'   [fs::path_home()]). You can set this path via the global option
#'   `"shrtcts.path"`.
#'
#' @examples
#' # Add shortcuts to ~/.shrtcts.yaml (see help above)
#'
#' # Add this to your ~/.Rprofile to automatically load shortcuts
#' if (interactive() & requireNamespace("shrtcts", quietly = TRUE)) {
#'   shrtcts::add_rstudio_shortcuts()
#' }
#'
#' @export
add_rstudio_shortcuts <- function(path = NULL) {
  if (!interactive()) return(invisible())
  if (is.null(path)) {
    path <- getOption("shrtcts.path", NULL)
  } else {
    path <- fs::path_norm(path)
    if (!fs::file_exists(path)) {
      stop("shrtcts file does not exist: ", path, call. = FALSE)
    }
    options("shrtcts.path" = path)
  }
  if (is.null(path)) path <- find_shortcuts_yaml()
  shortcuts <- parse_shortcuts_yaml(path)
  if (!length(shortcuts)) return(invisible())
  write_addins(shortcuts)
  invisible()
}

#' @describeIn add_rstudio_shortcuts An example `.shrtcts.yml` file.
#' @export
example_shortcuts_yaml <- function() {
  x <- readLines(system.file(".shrtcts.yaml", package = "shrtcts"))
  cat(x, sep = "\n")
  invisible(x)
}

how_to_use <- function() `?`(shrtcts::add_rstudio_shortcuts)

find_shortcuts_yaml <- function() {
  try_dirs <- c(
    fs::path_home_r(c(".config", "")),
    fs::path_home(c(".config", ""))
  )
  try_dirs <- unique(try_dirs)
  dir <- try_dirs[fs::dir_exists(try_dirs)][1]
  if (!length(dir)) cant_find_shortcuts_yaml()

  path <- fs::dir_ls(dir, regexp = "[.]shrtcts[.]ya?ml", all = TRUE)
  if (!length(path)) cant_find_shortcuts_yaml()

  path[1]
}

cant_find_shortcuts_yaml <- function() {
  stop(
    "Could not find .shrtcts.yaml in ",
    fs::path_home_r(".config"),
    " or ",
    fs::path_home_r(),
    call. = FALSE
  )
}

parse_shortcuts_yaml <- function(path) {
  x <- yaml::read_yaml(path)
  x <- add_shortcut_ids(x)
  lapply(x, function(shortcut) {
    stopifnot("name" %in% tolower(names(shortcut)))
    stopifnot("binding" %in% tolower(names(shortcut)))
    for (name in c("Name", "Binding", "Description", "Interactive")) {
      if (tolower(name) %in% names(shortcut) && !name %in% names(shortcut)) {
        names(shortcut)[which(tolower(name) == names(shortcut))] <- name
      }
    }
    shortcut[["function"]] <- shortcut$Binding
    shortcut$Binding <- sprintf("shortcut_%02d", shortcut$id)
    if (!"Description" %in% names(shortcut)) {
      shortcut[["Description"]] <- ""
    }
    if (!"Interactive" %in% names(shortcut)) {
      shortcut[["Interactive"]] <- TRUE
    }
    shortcut
  })
}

add_shortcut_ids <- function(x) {
  declared_ids <- as.integer(unlist(lapply(x, `[[`, "id")))
  if (any(is.na(declared_ids))) {
    stop("Shortcuts must have integer ids", call. = FALSE)
  }
  if (any(duplicated(declared_ids))) {
    dups <- unique(declared_ids[duplicated(declared_ids)])
    warning(
      "Multiple shortcuts have the same id: ",
      paste(dups, collapse = ", "),
      call. = FALSE,
      immediate. = TRUE
    )
  }
  if (any(declared_ids > 100)) {
    bad <- unqiue(declared_ids[declared_ids > 100])
    stop(
      "Shortcuts with id > 100 will not work: ",
      paste(bad, collapse = ", "),
      call. = FALSE
    )
  }
  ids <- c()
  i <- 1L
  for (idx in seq_along(x)) {
    if (is.null(x[[idx]][["id"]])) {
      while (i %in% c(ids, declared_ids)) {
        i <- i + 1L
      }
      x[[idx]]$id <- i
      ids <- c(ids, i)
    } else {
      x[[idx]]$id <- as.integer(x[[idx]]$id)
    }
  }
  x
}

as_dcf <- function(x) {
  local({
    txt_con <- textConnection("txt", "w")
    lapply(x, function(s) {
      s[["function"]] <- NULL
      write.dcf(s, txt_con)
      cat("\n", file = txt_con)
    })
    close(txt_con)
    txt
  })
}

write_addins <- function(x) {
  x <- as_dcf(x)
  outdir <- fs::path(system.file(package = "shrtcts"), "rstudio")
  fs::dir_create(outdir)
  writeLines(x, fs::path(outdir, "addins.dcf"))
}
