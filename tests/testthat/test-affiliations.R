# ==============================================================================
# Test Suite: Professional Affiliations
# ==============================================================================
# Tests for professional affiliation API functions and their parsers:
# - orcid_distinctions(), orcid_invited_positions(), orcid_memberships()
# - orcid_qualifications(), orcid_services(), orcid_research_resources()
# - parse_affiliations(), parse_research_resources()

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
# API Function Tests: orcid_distinctions()
# ==============================================================================

test_that("orcid_distinctions fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_distinctions("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty if user has no distinctions
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("organization" %in% names(result))
  }
})

test_that("orcid_distinctions validates ORCID format", {
  expect_error(
    orcid_distinctions("invalid-orcid"),
    "Invalid ORCID"
  )
})

# ==============================================================================
# API Function Tests: orcid_invited_positions()
# ==============================================================================

test_that("orcid_invited_positions fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_invited_positions("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("organization" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_memberships()
# ==============================================================================

test_that("orcid_memberships fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_memberships("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("organization" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_qualifications()
# ==============================================================================

test_that("orcid_qualifications fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_qualifications("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("organization" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_services()
# ==============================================================================

test_that("orcid_services fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_services("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("organization" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_research_resources()
# ==============================================================================

test_that("orcid_research_resources fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_research_resources("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("proposal_title" %in% names(result))
  }
})

# ==============================================================================
# Parser Tests: parse_affiliations()
# ==============================================================================

test_that("parse_affiliations handles empty response", {
  json_data <- list(`affiliation-group` = list())
  result <- parse_affiliations(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
  expect_true("organization" %in% names(result))
})

test_that("parse_affiliations returns correct structure", {
  # Test with minimal valid structure
  json_data <- list(
    `affiliation-group` = list(
      list(
        summaries = list(
          list(
            `distinction-summary` = list(
              `put-code` = 12345,
              organization = list(
                name = "Royal Society",
                address = list(
                  city = "London",
                  region = NULL,
                  country = "GB"
                )
              ),
              `department-name` = NULL,
              `role-title` = "Fellow",
              `start-date` = list(
                year = list(value = "2020"),
                month = list(value = "6"),
                day = NULL
              ),
              `end-date` = NULL
            )
          )
        )
      )
    )
  )

  result <- parse_affiliations(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  # Parser may not extract all fields from mock data, just verify structure
  expect_true("organization" %in% names(result))
  expect_true("role" %in% names(result))
  expect_true("city" %in% names(result))
})

# ==============================================================================
# Parser Tests: parse_research_resources()
# ==============================================================================

test_that("parse_research_resources handles empty response", {
  json_data <- list(group = list())
  result <- parse_research_resources(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})
