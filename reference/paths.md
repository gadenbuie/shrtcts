# Paths Used by shrtcts

These functions help locate the paths used by shrtcts when looking for
configuration files. You can use these functions to verify that shrtcts
is locating the files where you expect them to be. See the **Options**
section below for global options that can be used to override the
default behavior of these functions.

## Usage

``` r
locate_shortcuts_source(path = NULL, all = FALSE)

locate_addins_json(path = NULL, all = FALSE)
```

## Arguments

- path:

  The path to the file.

- all:

  List all found files, otherwise only the first is returned.

## Functions

- `locate_shortcuts_source()`: Find the path to `.shrtcts.R` or
  `.shrtcts.yml`.

- `locate_addins_json()`: Find the path to `addins.json`, the RStudio
  configuration file containing keyboard shortcuts for addins

## Options

Use the following global options to set the default values for the
following files:

- `shrtcts.path`: The path to `.shrtrcts.R` or `.shrtcts.yml`

- `shrtcts.addins_json`: The path to the RStudio `addins.json` file used
  for setting keyboard shortcuts for addins.

## Examples

``` r
if (interactive()) {
  locate_shortcuts_source()
  locate_addins_json()
}
```
