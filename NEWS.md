# shrtcts (development version)

* Added `shortcut_run()` and `shortcut_get()`, which make it easier to get and
  run shortcuts by name (assigned name in the R code sense) when using
  `.shrtcts.R`. This in turn makes it possible to use `{shrtcts}` to store
  workflow shortcuts and to run these shortcuts in
  [Positron](https://positron.posit.co/). (#26)

* Use `roxygen2::tag_words()` instead of the deprecated `roxygen2::tag_words_line()`
  when roxygen2 v8.0.0 or later is loaded.

