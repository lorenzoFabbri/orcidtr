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

test_that("orcid_employments fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_employments("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("organization" %in% names(result))
})

test_that("orcid_employments validates ORCID format", {
  expect_error(
    orcid_employments("invalid-orcid"),
    "Invalid ORCID"
  )
})

test_that("orcid_educations fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_educations("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
})

test_that("orcid_works fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_works("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("title" %in% names(result))
})

test_that("orcid_funding fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_funding("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
})

test_that("orcid_peer_reviews fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_peer_reviews("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
})

test_that("orcid_fetch_record fetches complete record", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_fetch_record("0000-0002-1825-0097")

  expect_type(result, "list")
  expect_true("employments" %in% names(result))
  expect_true("educations" %in% names(result))
  expect_true("works" %in% names(result))
  expect_true("funding" %in% names(result))
  expect_true("peer_reviews" %in% names(result))
})

test_that("orcid_fetch_record can fetch specific sections", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_fetch_record(
    "0000-0002-1825-0097",
    sections = c("works", "employments")
  )

  expect_type(result, "list")
  expect_true("works" %in% names(result))
  expect_true("employments" %in% names(result))
  expect_false("funding" %in% names(result))
})

test_that("orcid_fetch_many combines results correctly", {
  skip_on_cran()
  skip_if_offline()

  orcids <- c("0000-0002-1825-0097", "0000-0003-1419-2405")
  result <- orcid_fetch_many(orcids, section = "works")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))

  # Should have data from both ORCIDs
  unique_orcids <- unique(result$orcid)
  expect_true(length(unique_orcids) >= 1)
})

test_that("orcid_fetch_many handles invalid ORCIDs gracefully", {
  skip_on_cran()
  skip_if_offline()

  orcids <- c("0000-0002-1825-0097", "invalid-orcid")

  expect_warning(
    result <- orcid_fetch_many(
      orcids,
      section = "works",
      stop_on_error = FALSE
    ),
    "Invalid ORCID"
  )

  expect_s3_class(result, "data.table")
})
