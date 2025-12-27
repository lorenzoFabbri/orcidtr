test_that("validate_orcid accepts valid ORCID identifiers", {
  expect_true(validate_orcid("0000-0002-1825-0097", stop_on_error = FALSE))
  expect_true(validate_orcid("0000-0003-1419-2405", stop_on_error = FALSE))
  expect_true(validate_orcid("0000-0002-1825-009X", stop_on_error = FALSE))
})

test_that("validate_orcid rejects invalid ORCID identifiers", {
  expect_false(validate_orcid("invalid", stop_on_error = FALSE))
  expect_false(validate_orcid("0000-0002-1825", stop_on_error = FALSE))
  expect_false(validate_orcid("0000-0002-1825-00971", stop_on_error = FALSE))
  expect_false(validate_orcid("", stop_on_error = FALSE))
})

test_that("validate_orcid stops on error when requested", {
  expect_error(
    validate_orcid("invalid", stop_on_error = TRUE),
    "Invalid ORCID format"
  )
  expect_error(
    validate_orcid(NULL, stop_on_error = TRUE),
    "cannot be NULL"
  )
})

test_that("normalize_orcid handles different formats", {
  expect_equal(
    normalize_orcid("0000000218250097"),
    "0000-0002-1825-0097"
  )
  expect_equal(
    normalize_orcid("0000-0002-1825-0097"),
    "0000-0002-1825-0097"
  )
  expect_equal(
    normalize_orcid("https://orcid.org/0000-0002-1825-0097"),
    "0000-0002-1825-0097"
  )
  expect_equal(
    normalize_orcid("http://orcid.org/0000-0002-1825-0097"),
    "0000-0002-1825-0097"
  )
})

test_that("normalize_orcid handles X in checksum", {
  expect_equal(
    normalize_orcid("0000-0002-1825-009X"),
    "0000-0002-1825-009X"
  )
})

test_that("normalize_orcid rejects invalid ORCIDs", {
  expect_error(normalize_orcid("invalid"), "Invalid ORCID")
  expect_error(normalize_orcid("0000-0002"), "Invalid ORCID length")
})

test_that("safe_extract returns NA for missing paths", {
  x <- list(a = list(b = list(c = "value")))
  expect_equal(safe_extract(x, "a", "b", "c"), "value")
  expect_true(is.na(safe_extract(x, "a", "b", "d")))
  expect_true(is.na(safe_extract(x, "z", "y")))
  expect_true(is.na(safe_extract(NULL, "a")))
})

test_that("orcid_date_to_iso handles complete dates", {
  date_obj <- list(
    year = list(value = "2020"),
    month = list(value = "3"),
    day = list(value = "15")
  )
  expect_equal(orcid_date_to_iso(date_obj), "2020-03-15")
})

test_that("orcid_date_to_iso handles partial dates", {
  year_only <- list(year = list(value = "2020"))
  expect_equal(orcid_date_to_iso(year_only), "2020")

  year_month <- list(
    year = list(value = "2020"),
    month = list(value = "3")
  )
  expect_equal(orcid_date_to_iso(year_month), "2020-03")
})

test_that("orcid_date_to_iso handles NULL and invalid input", {
  expect_true(is.na(orcid_date_to_iso(NULL)))
  expect_true(is.na(orcid_date_to_iso(list())))
  expect_true(is.na(orcid_date_to_iso("not-a-list")))
})

test_that("has_env_var detects environment variables", {
  old_val <- Sys.getenv("TEST_VAR", unset = "")

  Sys.setenv(TEST_VAR = "value")
  expect_true(has_env_var("TEST_VAR"))

  Sys.unsetenv("TEST_VAR")
  expect_false(has_env_var("TEST_VAR"))

  # Restore
  if (old_val != "") {
    Sys.setenv(TEST_VAR = old_val)
  }
})
