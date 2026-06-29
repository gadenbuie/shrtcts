# Changelog

## shrtcts (development version)

- Added
  [`shortcut_run()`](https://pkg.garrickadenbuie.com/shrtcts/reference/shortcut_run.md)
  and
  [`shortcut_get()`](https://pkg.garrickadenbuie.com/shrtcts/reference/shortcut_run.md),
  which make it easier to get and run shortcuts by name (assigned name
  in the R code sense) when using `.shrtcts.R`. This in turn makes it
  possible to use [shrtcts](https://pkg.garrickadenbuie.com/shrtcts) to
  store workflow shortcuts and to run these shortcuts in
  [Positron](https://positron.posit.co/).
  ([\#26](https://github.com/gadenbuie/shrtcts/issues/26))

- Use
  [`roxygen2::tag_words()`](https://roxygen2.r-lib.org/reference/tag_parsers.html)
  instead of the deprecated
  [`roxygen2::tag_words_line()`](https://roxygen2.r-lib.org/reference/tag_parsers.html)
  when roxygen2 v8.0.0 or later is loaded.
