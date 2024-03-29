run_shortcut <- function(n) {
  path <- suppressMessages(
    locate_shortcuts_source() %||% cant_path_shortcuts_source
  )

  shortcuts <- parse_shortcuts(path)
  if (!length(shortcuts)) {
    return(invisible())
  }
  this_shortcut <- shortcut_by_id(shortcuts, n)
  if (
    isTRUE(this_shortcut[["Interactive"]]) &&
    is_likely_packaged_fn(this_shortcut[["function"]]) &&
    can_send_to_console()
  ) {
    rstudioapi::sendToConsole(
      code = paste0(this_shortcut[["function"]], "()"),
      execute = TRUE,
      focus = TRUE
    )
    return(invisible())
  }
  shortcut <- eval(parse(text = this_shortcut[["function"]]))
  if (is.function(shortcut)) {
    shortcut()
  } else {
    shortcut
  }
}

shortcut_by_id <- function(shortcuts, id) {
  ids <- vapply(shortcuts, `[[`, integer(1), "id")
  this_id <- which(id == ids)
  if (!length(this_id)) {
    stop("No shortcut registered with id ", id, call. = FALSE)
  }
  if (length(this_id) > 1) {
    warning(
      "Multiple shortcuts registered with id ",
      id,
      ", using first.",
      call. = FALSE,
      immediate. = TRUE
    )
  }
  shortcuts[[this_id[[1]]]]
}

can_send_to_console <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) return(FALSE)
  rstudioapi::hasFun("sendToConsole")
}

#nocov start
shortcut_01 <- function() run_shortcut(n = 1)
shortcut_02 <- function() run_shortcut(n = 2)
shortcut_03 <- function() run_shortcut(n = 3)
shortcut_04 <- function() run_shortcut(n = 4)
shortcut_05 <- function() run_shortcut(n = 5)
shortcut_06 <- function() run_shortcut(n = 6)
shortcut_07 <- function() run_shortcut(n = 7)
shortcut_08 <- function() run_shortcut(n = 8)
shortcut_09 <- function() run_shortcut(n = 9)
shortcut_10 <- function() run_shortcut(n = 10)
shortcut_11 <- function() run_shortcut(n = 11)
shortcut_12 <- function() run_shortcut(n = 12)
shortcut_13 <- function() run_shortcut(n = 13)
shortcut_14 <- function() run_shortcut(n = 14)
shortcut_15 <- function() run_shortcut(n = 15)
shortcut_16 <- function() run_shortcut(n = 16)
shortcut_17 <- function() run_shortcut(n = 17)
shortcut_18 <- function() run_shortcut(n = 18)
shortcut_19 <- function() run_shortcut(n = 19)
shortcut_20 <- function() run_shortcut(n = 20)
shortcut_21 <- function() run_shortcut(n = 21)
shortcut_22 <- function() run_shortcut(n = 22)
shortcut_23 <- function() run_shortcut(n = 23)
shortcut_24 <- function() run_shortcut(n = 24)
shortcut_25 <- function() run_shortcut(n = 25)
shortcut_26 <- function() run_shortcut(n = 26)
shortcut_27 <- function() run_shortcut(n = 27)
shortcut_28 <- function() run_shortcut(n = 28)
shortcut_29 <- function() run_shortcut(n = 29)
shortcut_30 <- function() run_shortcut(n = 30)
shortcut_31 <- function() run_shortcut(n = 31)
shortcut_32 <- function() run_shortcut(n = 32)
shortcut_33 <- function() run_shortcut(n = 33)
shortcut_34 <- function() run_shortcut(n = 34)
shortcut_35 <- function() run_shortcut(n = 35)
shortcut_36 <- function() run_shortcut(n = 36)
shortcut_37 <- function() run_shortcut(n = 37)
shortcut_38 <- function() run_shortcut(n = 38)
shortcut_39 <- function() run_shortcut(n = 39)
shortcut_40 <- function() run_shortcut(n = 40)
shortcut_41 <- function() run_shortcut(n = 41)
shortcut_42 <- function() run_shortcut(n = 42)
shortcut_43 <- function() run_shortcut(n = 43)
shortcut_44 <- function() run_shortcut(n = 44)
shortcut_45 <- function() run_shortcut(n = 45)
shortcut_46 <- function() run_shortcut(n = 46)
shortcut_47 <- function() run_shortcut(n = 47)
shortcut_48 <- function() run_shortcut(n = 48)
shortcut_49 <- function() run_shortcut(n = 49)
shortcut_50 <- function() run_shortcut(n = 50)
shortcut_51 <- function() run_shortcut(n = 51)
shortcut_52 <- function() run_shortcut(n = 52)
shortcut_53 <- function() run_shortcut(n = 53)
shortcut_54 <- function() run_shortcut(n = 54)
shortcut_55 <- function() run_shortcut(n = 55)
shortcut_56 <- function() run_shortcut(n = 56)
shortcut_57 <- function() run_shortcut(n = 57)
shortcut_58 <- function() run_shortcut(n = 58)
shortcut_59 <- function() run_shortcut(n = 59)
shortcut_60 <- function() run_shortcut(n = 60)
shortcut_61 <- function() run_shortcut(n = 61)
shortcut_62 <- function() run_shortcut(n = 62)
shortcut_63 <- function() run_shortcut(n = 63)
shortcut_64 <- function() run_shortcut(n = 64)
shortcut_65 <- function() run_shortcut(n = 65)
shortcut_66 <- function() run_shortcut(n = 66)
shortcut_67 <- function() run_shortcut(n = 67)
shortcut_68 <- function() run_shortcut(n = 68)
shortcut_69 <- function() run_shortcut(n = 69)
shortcut_70 <- function() run_shortcut(n = 70)
shortcut_71 <- function() run_shortcut(n = 71)
shortcut_72 <- function() run_shortcut(n = 72)
shortcut_73 <- function() run_shortcut(n = 73)
shortcut_74 <- function() run_shortcut(n = 74)
shortcut_75 <- function() run_shortcut(n = 75)
shortcut_76 <- function() run_shortcut(n = 76)
shortcut_77 <- function() run_shortcut(n = 77)
shortcut_78 <- function() run_shortcut(n = 78)
shortcut_79 <- function() run_shortcut(n = 79)
shortcut_80 <- function() run_shortcut(n = 80)
shortcut_81 <- function() run_shortcut(n = 81)
shortcut_82 <- function() run_shortcut(n = 82)
shortcut_83 <- function() run_shortcut(n = 83)
shortcut_84 <- function() run_shortcut(n = 84)
shortcut_85 <- function() run_shortcut(n = 85)
shortcut_86 <- function() run_shortcut(n = 86)
shortcut_87 <- function() run_shortcut(n = 87)
shortcut_88 <- function() run_shortcut(n = 88)
shortcut_89 <- function() run_shortcut(n = 89)
shortcut_90 <- function() run_shortcut(n = 90)
shortcut_91 <- function() run_shortcut(n = 91)
shortcut_92 <- function() run_shortcut(n = 92)
shortcut_93 <- function() run_shortcut(n = 93)
shortcut_94 <- function() run_shortcut(n = 94)
shortcut_95 <- function() run_shortcut(n = 95)
shortcut_96 <- function() run_shortcut(n = 96)
shortcut_97 <- function() run_shortcut(n = 97)
shortcut_98 <- function() run_shortcut(n = 98)
shortcut_99 <- function() run_shortcut(n = 99)
shortcut_100 <- function() run_shortcut(n = 100)
#nocov end
