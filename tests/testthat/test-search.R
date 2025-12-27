# These tests require network access and should be skipped on CRAN
skip_if_offline <- function() {
  tryCatch(
    {
      httr2::request("https://pub.orcid.org") |>
        httr2::req_perform()
      invisible(TRUE)
    },
    error = function(e) {
      skip("ORCID API not accessible")
    }
  )
}

test_that("orcid searches by family name", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid(
    query = "family-name:Wickham",
    rows = 5
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid_id" %in% names(result))
  expect_true("family_name" %in% names(result))
  expect_true(nrow(result) <= 5)
  expect_true(attr(result, "found") >= nrow(result))
})

test_that("orcid searches with multiple criteria", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid(
    query = "family-name:Smith AND given-names:John",
    rows = 10
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid_id" %in% names(result))
})

test_that("orcid handles no results", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid(
    query = "family-name:XyZqWvAbCdEfGh123456789",
    rows = 10
  )

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
  expect_equal(attr(result, "found"), 0)
})

test_that("orcid_search works with named parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_search(
    family_name = "Wickham",
    rows = 5
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid_id" %in% names(result))
  expect_true(nrow(result) <= 5)
})

test_that("orcid_search combines multiple parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_search(
    family_name = "Smith",
    given_names = "John",
    rows = 5
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid_id" %in% names(result))
})

test_that("orcid_search validates parameters", {
  expect_warning(
    orcid_search(rows = 0),
    "No search criteria provided"
  )
})

test_that("orcid_doi searches by DOI", {
  skip_on_cran()
  skip_if_offline()

  # Using a known DOI - this might not find results but should not error
  result <- orcid_doi(
    doi = "10.1371/journal.pone.0001543",
    rows = 5
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid_id" %in% names(result))
})

test_that("orcid_doi handles multiple DOIs", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_doi(
    doi = c("10.1371/journal.pone.0001543", "10.1371/journal.pone.0001544"),
    rows = 10
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid_id" %in% names(result))
})

test_that("orcid_doi validates DOI parameter", {
  expect_error(
    orcid_doi(doi = character(0)),
    "At least one DOI must be provided"
  )
})
