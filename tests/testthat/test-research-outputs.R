# ==============================================================================
# Test Suite: Research Outputs (Employment, Education, Works, Funding, Peer Reviews)
# ==============================================================================
# Tests for research output and career history API functions and their parsers:
# - orcid_employments(), orcid_educations()
# - orcid_works(), orcid_funding(), orcid_peer_reviews()
# - parse_employments(), parse_educations()
# - parse_works(), parse_funding(), parse_peer_reviews()

# Helper: Skip if ORCID API is not accessible
skip_if_offline <- function() {
  # The public API does not require authentication
  tryCatch(
    {
      httr2::request("https://pub.orcid.org/v3.0/status") |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform()
      invisible(TRUE)
    },
    error = function(e) {
      # Only skip if we can't connect at all (network error)
      if (
        grepl(
          "Failed to connect|Could not resolve|timeout",
          conditionMessage(e),
          ignore.case = TRUE
        )
      ) {
        skip("ORCID API not accessible")
      }
      invisible(TRUE)
    }
  )
}

# ==============================================================================
# API Function Tests: orcid_employments()
# ==============================================================================

test_that("orcid_employments validates ORCID format", {
  expect_error(
    orcid_employments("invalid-orcid"),
    "Invalid ORCID"
  )

  expect_error(
    orcid_employments(""),
    "Invalid ORCID"
  )

  expect_error(
    orcid_employments(NULL),
    "ORCID"
  )
})

test_that("orcid_employments fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_employments("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("organization" %in% names(result))
})

# ==============================================================================
# API Function Tests: orcid_educations()
# ==============================================================================

test_that("orcid_educations validates ORCID format", {
  expect_error(
    orcid_educations("invalid-orcid"),
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

# ==============================================================================
# API Function Tests: orcid_works()
# ==============================================================================

test_that("orcid_works validates ORCID format", {
  expect_error(
    orcid_works("invalid-orcid"),
    "Invalid ORCID"
  )
})

test_that("orcid_works fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_works("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("title" %in% names(result))
})

# ==============================================================================
# API Function Tests: orcid_funding()
# ==============================================================================

test_that("orcid_funding validates ORCID format", {
  expect_error(
    orcid_funding("invalid-orcid"),
    "Invalid ORCID"
  )
})

test_that("orcid_funding fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_funding("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
})

# ==============================================================================
# API Function Tests: orcid_peer_reviews()
# ==============================================================================

test_that("orcid_peer_reviews validates ORCID format", {
  expect_error(
    orcid_peer_reviews("invalid-orcid"),
    "Invalid ORCID"
  )
})

test_that("orcid_peer_reviews fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_peer_reviews("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
})

# ==============================================================================
# Parser Tests: parse_employments()
# ==============================================================================

test_that("parse_employments handles empty response", {
  json_data <- list(`affiliation-group` = list())
  result <- parse_employments(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
  expect_true("organization" %in% names(result))
})

test_that("parse_employments extracts employment data correctly", {
  json_data <- list(
    `affiliation-group` = list(
      list(
        summaries = list(
          list(
            `employment-summary` = list(
              `put-code` = 12345,
              organization = list(
                name = "Test University",
                address = list(
                  city = "Boston",
                  region = "MA",
                  country = "US"
                )
              ),
              `department-name` = "Computer Science",
              `role-title` = "Professor",
              `start-date` = list(
                year = list(value = "2020"),
                month = list(value = "1"),
                day = list(value = "1")
              ),
              `end-date` = NULL
            )
          )
        )
      )
    )
  )

  result <- parse_employments(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$organization[1], "Test University")
  expect_equal(result$department[1], "Computer Science")
  expect_equal(result$role[1], "Professor")
  expect_equal(result$city[1], "Boston")
  expect_equal(result$start_date[1], "2020-01-01")
})

# ==============================================================================
# Parser Tests: parse_educations()
# ==============================================================================

test_that("parse_educations handles empty response", {
  json_data <- list(`affiliation-group` = list())
  result <- parse_educations(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

# ==============================================================================
# Parser Tests: parse_works()
# ==============================================================================

test_that("parse_works handles empty response", {
  json_data <- list(group = list())
  result <- parse_works(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
  expect_true("title" %in% names(result))
})

test_that("parse_works extracts work data correctly", {
  json_data <- list(
    group = list(
      list(
        `work-summary` = list(
          list(
            `put-code` = 67890,
            title = list(
              title = list(value = "Test Article")
            ),
            type = "journal-article",
            `journal-title` = list(value = "Nature"),
            `publication-date` = list(
              year = list(value = "2021"),
              month = list(value = "6")
            ),
            `external-ids` = list(
              `external-id` = list(
                list(
                  `external-id-type` = "doi",
                  `external-id-value` = "10.1000/test"
                )
              )
            ),
            url = list(value = "https://example.com/paper")
          )
        )
      )
    )
  )

  result <- parse_works(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$title[1], "Test Article")
  expect_equal(result$type[1], "journal-article")
  expect_equal(result$journal[1], "Nature")
  expect_equal(result$doi[1], "10.1000/test")
  expect_equal(result$publication_date[1], "2021-06")
})

# ==============================================================================
# Parser Tests: parse_funding()
# ==============================================================================

test_that("parse_funding handles empty response", {
  json_data <- list(group = list())
  result <- parse_funding(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

# ==============================================================================
# Parser Tests: parse_peer_reviews()
# ==============================================================================

test_that("parse_peer_reviews handles empty response", {
  json_data <- list(group = list())
  result <- parse_peer_reviews(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})
