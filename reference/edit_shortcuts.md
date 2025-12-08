# Open the shrtcts Source File

This helper function locates and opens (or returns the path to) the
`.shrtcts.R` or `.shrtcts.yml` file.

## Usage

``` r
edit_shortcuts(open = TRUE, path = NULL)
```

## Arguments

- open:

  If `TRUE` and the shrtcts source file is found (see
  [paths](https://pkg.garrickadenbuie.com/shrtcts/reference/paths.md)),
  then the file is opened via
  [`file.edit()`](https://rdrr.io/r/utils/file.edit.html). Otherwise,
  the path is returned.

- path:

  The path to your `.shtrcts.yaml` file. If `NULL`, shrtcts will look in
  your R or OS home directory (via
  [`fs::path_home_r()`](https://fs.r-lib.org/reference/path_expand.html)
  or
  [`fs::path_home()`](https://fs.r-lib.org/reference/path_expand.html)).
  You can set this path via the global option `"shrtcts.path"`. For more
  information, see the help documentation on
  [paths](https://pkg.garrickadenbuie.com/shrtcts/reference/paths.md).

## Value

The path to the `.shrtcts.R` or `.shrtcts.yml` source file (invisibly if
the file is opened).
