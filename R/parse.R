parse_shortcuts <- function(path) {
  switch(
    fs::path_ext(path),
    R = ,
    r = parse_shortcuts_r(path),
    yaml = ,
    yml = parse_shortcuts_yaml(path),
    stop("Unknown s")
  )
}

#' @importFrom roxygen2 roxy_tag_parse
#' @export
roxy_tag_parse.roxy_tag_id <- function(x) {
  roxygen2::tag_value(x)
}

#' @export
roxy_tag_parse.roxy_tag_shortcut <- function(x) {
  roxygen2::tag_value(x)
}

#' @export
roxy_tag_parse.roxy_tag_interactive <- function(x) {
  roxygen2::tag_words_line(x)
}

parse_shortcuts_r <- function(path) {
  x <- roxygen2::parse_file(path)

  no_call <- vapply(x, function(sh) is.null(sh$call), logical(1))

  x <- x[!no_call]

  x <- lapply(x, function(sh) {
    title <- roxygen2::block_get_tag_value(sh, "title")
    if (is.null(title)) {
      stop("All shortcuts must have a title or an @title tag", call. = FALSE)
    }
    description <- roxygen2::block_get_tag_value(sh, "description") %||% ""
    interactive <- roxygen2::block_has_tags(sh, "interactive") %||% FALSE
    id <- roxygen2::block_get_tag_value(sh, "id")
    shortcut <- list(
      Name = title,
      Description = description,
      `function` = discard_function_name(sh$call),
      Interactive = interactive
    )
    if (!is.null(id)) shortcut$id <- id
    keybinding <- roxygen2::block_get_tag_value(sh, "shortcut")
    if (!is.null(keybinding)) shortcut$shortcut <- keybinding
    shortcut
  })

  x <- add_shortcut_ids(x)
  x <- lapply(x, function(sh) {
    sh$Binding <- sprintf("shortcut_%02d", sh$id)
    sh
  })
  structure(x, class = c("shrtcts_r", "shrtcts", "list"))
}

discard_function_name <- function(x) {
  if (is.character(x)) {
    x <- trimws(x)
    if (
      !is_likely_packaged_fn(x) &&
        !grepl("function", strsplit(x, "\n")[[1]][[1]])
    ) {
      x <- paste0("function() {\n", x, "\n}")
    }
    x <- parse(text = x)[[1]]
  }
  if (class(x) %in% c("<-", "=")) {
    x <- x[[3]]
  }
  x <- paste(
    deparse(x, 500, backtick = TRUE, nlines = -1, ),
    collapse = "\n"
  )
  gsub("\t", "  ", x)
}

parse_shortcuts_yaml <- function(path) {
  x <- yaml::read_yaml(path)
  x <- add_shortcut_ids(x)
  x <- lapply(x, function(shortcut) {
    stopifnot("name" %in% tolower(names(shortcut)))
    stopifnot("binding" %in% tolower(names(shortcut)))
    for (name in c("Name", "Binding", "Description", "Interactive")) {
      if (tolower(name) %in% names(shortcut) && !name %in% names(shortcut)) {
        names(shortcut)[which(tolower(name) == names(shortcut))] <- name
      }
    }
    shortcut[["function"]] <- discard_function_name(shortcut$Binding)
    shortcut$Binding <- sprintf("shortcut_%02d", shortcut$id)
    if (!"Description" %in% names(shortcut)) {
      shortcut[["Description"]] <- ""
    }
    if (!"Interactive" %in% names(shortcut)) {
      shortcut[["Interactive"]] <- TRUE
    }
    if ("shortcut" %in% tolower(names(shortcut))) {
      names(shortcut)[
        which(tolower(names(shortcut)) == "shortcut")
      ] <- "shortcut"
    }
    shortcut
  })
  structure(x, class = c("shrtcts_yaml", "shrtcts", "list"))
}

is_shrtcts <- function(x) inherits(x, "shrtcts")
is_shrtcts_r <- function(x) inherits(x, "shrtcts_r")
is_shrtcts_yaml <- function(x) inherits(x, "shrtcts_yaml")

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
    bad <- unique(declared_ids[declared_ids > 100])
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
