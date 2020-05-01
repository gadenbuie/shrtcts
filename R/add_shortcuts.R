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
#' @section YAML format: Use the following template to organize your
#' `.shrtcts.yaml`. Each shortcut is a YAML list item with the following
#' structure:
#'
#' ```yaml
#' - Name: Say Something Nice
#'   Description: A demo of cool things
#'   Binding: praise::praise
#'   Interactive: true
#' ```
#'
#' This format follows the format used by RStudio in the `addins.dcf` file. The
#' minimum required fields are `Name` and `Binding`. Use the
#' `example_shortcuts_yaml()` function to see a complete example YAML file.
#'
#' Note that unlike the `addins.dcf` file format, in `.shrtcts.yaml`, the
#' `Binding` field is an R function or arbitrary R code. If your shortcut calls
#' a function in another package, you can simply set `Binding` to the function
#' name, as in the example above. Otherwise, you can use a multi-line literal-
#' style YAML block to write your R code:
#'
#' ```yaml
#' - Name: Remind me where I am
#'   Binding: |
#'     current_directory <- getwd()
#'     message("Working directory: ", current_directory)
#'   Interactive: false
#' ```
#'
#' Note that when `Interactive` is `false`, no output will be shown unless you
#' explicitly call a `print()` or a similar function.
#'
#' Save your shortcuts YAML file to `.config/.shrtcts.yaml` or `.shrtcts.yaml`
#' in your home directory (i.e. [fs::path_home_r()] or [fs::path_home()]),
#' and run `add_rstudio_shortcuts()` to install your shortcuts. You'll need to
#' restart your R session for RStudio to learn your shortcuts.
#'
#' Once RStudio has learned about your shortcuts, you can create keyboard
#' shortcuts to trigger each action. Note that the order of the shortcuts in
#' your YAML file is important. \pkg{shrtcts} comes with are 100 "slots" for
#' RStudio addins. Changing the order of the shortcuts in the YAML file will
#' change which slot is used for each shortcut, which could break your keyboard
#' shortcuts. To avoid this, specifically set the id of any shortcut to a
#' number between 1 and 100, to ensure that keyboard shortcuts remain the same.
#'
#' ```
#' - Name: Make A Noise
#'   Binding: beepr::beep()
#'   id: 42
#' ```
#'
#' @section RStudio Keyboard Shortcuts: Once you've setup an RStudio Addin via
#' \pkg{shrtcts}, you can create a keyboard shortcut for the addin using the
#' _Tools_ > _Modify keyboard shortcuts_ menu.
#'
#' If you create a shortcut for an addin via \pkg{shrtcts}, it's a good idea to
#' set the `id` of the shortcut (see the section above).
#'
#' Keyboard shortcuts persist even if you update the list of shortcuts, but
#' re-installing the \pkg{shrtcts} package will break any previously-installed
#' shortcuts. As far as I know, there's no way to save and restore these
#' shortcuts, so use caution.
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
