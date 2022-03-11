#' Paths Used by shrtcts
#'
#' These functions help locate the paths used by \pkg{shrtcts} when looking for
#' configuration files. You can use these functions to verify that \pkg{shrtcts}
#' is locating the files where you expect them to be. See the **Options**
#' section below for global options that can be used to override the default
#' behavior of these functions.
#'
#' @section Options:
#'
#'   Use the following global options to set the default values for the
#'   following files:
#'
#'   - `shrtcts.path`: The path to `.shrtrcts.R` or `.shrtcts.yml`
#'
#'   - `shrtcts.addins_json`: The path to the RStudio `addins.json` file used for
#'   setting keyboard shortcuts for addins.
#'
#' @examples
#' if (interactive()) {
#'   locate_shortcuts_source()
#'   locate_addins_json()
#' }
#'
#' @param path The path to the file.
#' @param all List all found files, otherwise only the first is returned.
#' @name paths
NULL


# shrtcts source file -----------------------------------------------------

#' @describeIn paths Find the path to `.shrtcts.R` or `.shrtcts.yml`.
#' @export
locate_shortcuts_source <- function(path = NULL, all = FALSE) {
  if (is.null(path)) {
    path <- getOption("shrtcts.path", NULL)
  } else {
    path <- fs::path_norm(path)
    if (!fs::file_exists(path)) {
      stop("shrtcts file does not exist: ", path, call. = FALSE)
    }
    options("shrtcts.path" = path)
  }
  path <- path %||% path_shortcuts_source() %||% cant_path_shortcuts_source()
  if (isTRUE(all)) {
    return(path)
  }
  if (length(path) > 1) {
    message("[shrtcts] Multiple {shrtcts} source files found, using ", path[[1]])
    path <- path[[1]]
  }
  path
}

#nocov start
path_shortcuts_source <- function() {
  try_dirs <- c(
    rappdirs::user_config_dir("shrtcts"),
    fs::path_home_r(c(".config", "")),
    fs::path_home(c(".config", ""))
  )
  try_dirs <- unique(try_dirs)
  dir <- try_dirs[fs::dir_exists(try_dirs)]
  if (!length(dir)) cant_path_shortcuts_source()

  path_r <- fs::dir_ls(dir, regexp = "[.]shrtcts[.][rR]$", all = TRUE)
  path_yaml <- fs::dir_ls(dir, regexp = "[.]shrtcts[.]ya?ml$", all = TRUE)
  paths <- c(path_r, path_yaml)

  if (!length(paths)) {
    cant_path_shortcuts_source()
  }

  unname(paths)
}

maybe_create_shortcuts_file <- function(dir = rappdirs::user_config_dir("shrtcts")) {
  dir <- dir[1]
  path <- fs::path(dir, ".shrtcts.R")
  if (fs::file_exists(path)) return()
  if (interactive()) {
    msg <- sprintf("Would you like to create a new shrtcts file at '%s'", path)
    if (isTRUE(utils::askYesNo(msg))) {
      fs::dir_create(fs::path_dir(path), recurse = TRUE)
      fs::file_touch(path)
      return(path)
    }
  }
  cant_path_shortcuts_source()
}

cant_path_shortcuts_source <- function() {
  stop(
    "Could not find .shrtcts.R or .shrtcts.yaml in ",
    rappdirs::user_config_dir("shrtcts"), ", ",
    fs::path_home_r(".config"),
    " or ",
    fs::path_home_r(),
    call. = FALSE
  )
}
#nocov end

# addins.json -------------------------------------------------------------

#' @describeIn paths Find the path to `addins.json`, the RStudio configuration
#'   file containing keyboard shortcuts for addins
#' @export
locate_addins_json <- function(path = NULL, all = FALSE) {
  if (is.null(path)) {
    path <- getOption("shrtcts.addins_json", NULL)
  } else {
    path <- fs::path_norm(path)
    if (!fs::file_exists(path)) {
      stop("`addins.json` file does not exist at: ", path, call. = FALSE)
    }
  }
  if (is.null(path)) {
    path <- path_addins_json()
  }
  if (isTRUE(all)) {
    return(path)
  }
  if (length(path) > 1) {
    message("[shrtcts] Multiple 'addins.json' files found, using ", path[[1]])
    path <- path[[1]]
  }
  path
}

#nocov start
path_addins_json <- function() {
  try_dirs <- c(
    fs::path_home_r(".config", "rstudio", "keybindings"),
    fs::path_home_r("AppData", "Roaming", "rstudio", "keybindings"),
    fs::path_home(".config", "rstudio", "keybindings"),
    fs::path_home("AppData", "Roaming", "rstudio", "keybindings")
  )
  try_dirs <- unique(try_dirs)
  dir <- try_dirs[fs::dir_exists(try_dirs)]
  if (!length(dir)) cant_path_addins_json()

  paths <- fs::dir_ls(dir, regexp = "addins[.]json$", all = TRUE)

  if (!length(paths)) cant_path_addins_json()

  unname(paths)
}

cant_path_addins_json <- function() {
  stop(
    "Could not find addins.json in the usual places. ",
    "You may need to manually create a new keyboard shortcut (use RStudio's ",
    "Tools menu) first.",
    call. = FALSE
  )
}
#nocov end
