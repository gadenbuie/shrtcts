# Get and run shortcuts by name

If you're using an `.R` file to store your shortcuts, and if your
shortcuts use named functions, you can get and run the shortcut
functions with these helpers.

For example, if your `~/.shrtcts.R` file includes a `cow_say_praise()`
function

    # ~/.shrtcts.R

    praise <- function() {
      # your shortcuts, when run this way, can reference other functions
      praise::praise()
    }

    #' Have a cow say something nice
    cow_say_praise <- function() {
      cowsay::say(praise())
    }

you can use

    shortcut_run("cow_say_praise")

to run the shortcut, or you can use

    happy_cow <- shortcut_get("cow_say_praise")

to get the shortcut function to run yourself.

With these helper functions, your `~/.shrtcts.R` file is more portable
and becomes a place you can store utility or workflow functions.

### Using shortcuts in Positron

`shortcut_run()` enables you to use your shortcuts in Positron. You can
assign a keyboard shortcut to a specific shortcut function by running
the *Preferences: Open Default Keyboard Shortcuts (JSON)* command. Then
add an entry like the following:

    {
      "key": "cmd+k cmd+p",
      "name": "Have a cow say something nice",
      "command": "workbench.action.executeCode.console",
      "args": {
        "langId": "r",
        "code": "shrtcts::shortcut_run('cow_say_praise')",
        "focus": true
      }
    },

When you press `Cmd + K` followed by `Cmd + P`, Positron will run the
`cow_say_praise` shortcut in your R console. Replace
`workbench.action.executeCode.console` with
`workbench.action.executeCode.silently` to run the shortcut silently in
the background. You can also use the `"when"` key to control when the
keyboard shortcut is valid, e.g. `"when": "editorTextFocus"`.

## Usage

``` r
shortcut_run(.name, ..., .path_shortcuts = NULL)

shortcut_get(.name, .path_shortcuts = NULL)
```

## Arguments

- .name:

  Name of the function of the shortcut (not from the roxygen2 comments
  but from the name to which the function is assigned).

- ...:

  Additional arguments passed to the shortcut function when run.

- .path_shortcuts:

  The path to your `.shrcts.R` file. Must be an R script; the YAML
  shortcuts syntax is not supported.

## Functions

- `shortcut_run()`: Run a shortcut by assigned name

- `shortcut_get()`: Get a shortcut by assigned name

## Examples

``` r
# Create a small example .shrtcts.R file.
set.seed(42)
tmp_shortcuts <- tempfile(fileext = ".R")
writeLines("
praise <- function() {
  # your shortcuts, when run this way, can reference other functions
  praise::praise()
}

#' Have a cow say something nice
cow_say_praise <- function() {
  cowsay::say(praise())
}
", tmp_shortcuts)

# Run the `cow_say_praise` shortcut by name
shortcut_run("cow_say_praise", .path_shortcuts = tmp_shortcuts)
#> 
#>  __________________ 
#> < You are kickass! >
#>  ------------------ 
#>       \
#>        \
#> 
#>         ^__^ 
#>         (oo)\ ________ 
#>         (__)\         )\ /\ 
#>              ||------w|
#>              ||      ||

# Get the `cow_say_praise` shortcut
cow_praise <- shortcut_get("cow_say_praise", tmp_shortcuts)
cow_praise()
#> 
#>  ___________________ 
#> < You are ultimate! >
#>  ------------------- 
#>       \
#>        \
#> 
#>         ^__^ 
#>         (oo)\ ________ 
#>         (__)\         )\ /\ 
#>              ||------w|
#>              ||      ||
```
