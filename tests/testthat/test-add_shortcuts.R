test_that("is_likely_packaged_fn()", {
  expect_true(is_likely_packaged_fn("praise::praise"))
  expect_true(is_likely_packaged_fn("usethis:::restart_rstudio"))

  # only directly assigning the function is allowed
  expect_false(is_likely_packaged_fn("praise::praise()"))
  expect_false(is_likely_packaged_fn("usethis:::restart_rstudio()"))

  expect_false(is_likely_packaged_fn("function() praise::praise()"))
  expect_false(is_likely_packaged_fn("praise::praise\npraise::praise"))
})
