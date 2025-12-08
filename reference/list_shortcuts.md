# List Shortcuts and Their Current Key Bindings

Lists all shortcuts declared in `.shrtcts.R` or `.shrtcts.yml`. Also
lists the currently assigned RStudio keyboard shortcuts.

## Usage

``` r
list_shortcuts(path_shortcuts = NULL, path_addins_json = NULL)
```

## Arguments

- path_shortcuts:

  Path to `.shrtcts.R` or `.shrtcts.yml`. See
  [`locate_shortcuts_source()`](https://pkg.garrickadenbuie.com/shrtcts/reference/paths.md)
  for more detail.

- path_addins_json:

  Path to RStudio's `addins.json` keybindings config file. See
  [`locate_addins_json()`](https://pkg.garrickadenbuie.com/shrtcts/reference/paths.md)
  for more detail.

## Value

A data frame with the shortcut `name`, it's assigned `addin` placeholder
function, the `shrcts_keybinding` declared in the shrtcts source file,
and the `rstudio_keybinding` currently assigned to the shortcut in
RStudio.

## See also

[`add_rstudio_shortcuts()`](https://pkg.garrickadenbuie.com/shrtcts/reference/add_rstudio_shortcuts.md),
[paths](https://pkg.garrickadenbuie.com/shrtcts/reference/paths.md)

## Examples

``` r
if (
  interactive() &&
  requireNamespace("rstudioapi", quietly = TRUE) &&
  rstudioapi::hasFun("versionInfo")
 ) {
  list_shortcuts()
}
```
