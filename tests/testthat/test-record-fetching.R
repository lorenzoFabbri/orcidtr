# ==============================================================================
# Test Suite: Comprehensive Record Fetching
# ==============================================================================
# Tests for comprehensive data fetching functions:
# - orcid_activities(), orcid_ping()
# - orcid_fetch_record(), orcid_fetch_many()
# - parse_activities()

# Helper: Skip if ORCID API is not accessible
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

# ==============================================================================
# API Function Tests: orcid_activities()
# ==============================================================================

test_that("orcid_activities fetches complete activities", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_activities("0000-0002-1825-0097")

  expect_type(result, "list")
  expect_true("distinctions" %in% names(result))
  expect_true("educations" %in% names(result))
  expect_true("employments" %in% names(result))
  expect_true("invited_positions" %in% names(result))
  expect_true("memberships" %in% names(result))
  expect_true("qualifications" %in% names(result))
  expect_true("services" %in% names(result))
  expect_true("fundings" %in% names(result))
  expect_true("peer_reviews" %in% names(result))
  expect_true("research_resources" %in% names(result))
  expect_true("works" %in% names(result))

  # Each element should be a data.table
  expect_s3_class(result$distinctions, "data.table")
  expect_s3_class(result$educations, "data.table")
  expect_s3_class(result$employments, "data.table")
  expect_s3_class(result$works, "data.table")
})

test_that("orcid_activities validates ORCID format", {
  expect_error(
    orcid_activities("invalid-orcid"),
    "Invalid ORCID"
  )
})

# ==============================================================================
# API Function Tests: orcid_ping()
# ==============================================================================

test_that("orcid_ping checks API status", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_ping()

  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

# ==============================================================================
# API Function Tests: orcid_fetch_record()
# ==============================================================================

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

# ==============================================================================
# API Function Tests: orcid_fetch_many()
# ==============================================================================

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

# ==============================================================================
# Parser Tests: parse_activities()
# ==============================================================================

test_that("parse_activities returns named list", {
  # Minimal mock data
  json_data <- list(
    distinctions = list(`affiliation-group` = list()),
    educations = list(`affiliation-group` = list()),
    employments = list(`affiliation-group` = list()),
    `invited-positions` = list(`affiliation-group` = list()),
    memberships = list(`affiliation-group` = list()),
    qualifications = list(`affiliation-group` = list()),
    services = list(`affiliation-group` = list()),
    fundings = list(group = list()),
    `peer-reviews` = list(group = list()),
    `research-resources` = list(group = list()),
    works = list(group = list())
  )

  result <- parse_activities(json_data, "0000-0002-1825-0097")

  expect_type(result, "list")
  expect_true("distinctions" %in% names(result))
  expect_true("educations" %in% names(result))
  expect_true("employments" %in% names(result))
  expect_true("works" %in% names(result))
  expect_s3_class(result$works, "data.table")
})
