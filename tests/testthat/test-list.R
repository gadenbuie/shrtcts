# test_that()

describe("list_shortcuts()", {
  it("returns a data frame of shortcuts", {
    shortcuts_list <- list_shortcuts(
      system.file("ex-shrtcts.R", package = "shrtcts"),
      system.file("ex-addins.json", package = "shrtcts")
    )

    expect_known_output(shortcuts_list, "shortcuts_list.txt")
    expect_s3_class(shortcuts_list, "data.frame")
  })

  tmp_addins <- fs::path_temp("addins.json")
  writeLines("{}", tmp_addins)
  on.exit(fs::file_delete(tmp_addins))

  it("returns all NA whe no rstudio keyboard shortcuts", {
    ls_sh <- list_shortcuts(
      system.file("ex-shrtcts.R", package = "shrtcts"),
      tmp_addins
    )
    expect_true(all(is.na(ls_sh$rstudio_keybinding)))
  })

  tmp_shrtcts <- fs::path_temp("shrtcts.R")
  writeLines("#'\n#'", tmp_shrtcts)
  on.exit(fs::file_delete(tmp_shrtcts), add = TRUE)

  it("returns NULL with a message when no shortcuts", {
    ls_sh <- expect_message(list_shortcuts(tmp_shrtcts, tmp_addins))
    expect_null(ls_sh)
  })
})
