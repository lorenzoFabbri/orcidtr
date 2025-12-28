# ==============================================================================
# Test Suite: Biographical Data Functions
# ==============================================================================
# Tests for person/biographical data API functions and their parsers:
# - orcid_person(), orcid_bio(), orcid_keywords(), orcid_researcher_urls()
# - orcid_external_identifiers(), orcid_other_names(), orcid_address(), orcid_email()
# - parse_person(), parse_bio(), parse_keywords(), parse_researcher_urls()
# - parse_external_identifiers(), parse_other_names(), parse_address(), parse_email()

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
# API Function Tests: orcid_person()
# ==============================================================================

test_that("orcid_person fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_person("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("given_names" %in% names(result))
  expect_true("family_name" %in% names(result))
})

test_that("orcid_person validates ORCID format", {
  expect_error(
    orcid_person("invalid-orcid"),
    "Invalid ORCID"
  )
})

# ==============================================================================
# API Function Tests: orcid_bio()
# ==============================================================================

test_that("orcid_bio fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_bio("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("biography" %in% names(result))
})

# ==============================================================================
# API Function Tests: orcid_keywords()
# ==============================================================================

test_that("orcid_keywords fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_keywords("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty if user has no keywords
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("keyword" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_researcher_urls()
# ==============================================================================

test_that("orcid_researcher_urls fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_researcher_urls("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty if user has no URLs
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("url_value" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_external_identifiers()
# ==============================================================================

test_that("orcid_external_identifiers fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_external_identifiers("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("external_id_type" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_other_names()
# ==============================================================================

test_that("orcid_other_names fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_other_names("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("other_name" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_address()
# ==============================================================================

test_that("orcid_address fetches real data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_address("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # May be empty
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("country" %in% names(result))
  }
})

# ==============================================================================
# API Function Tests: orcid_email()
# ==============================================================================

test_that("orcid_email fetches data", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_email("0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  # Email may not be public
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("email" %in% names(result))
  }
})

# ==============================================================================
# Parser Tests: parse_person()
# ==============================================================================

test_that("parse_person handles empty response", {
  json_data <- list()
  result <- parse_person(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_true("orcid" %in% names(result))
})

test_that("parse_person extracts complete person data", {
  json_data <- list(
    name = list(
      `given-names` = list(value = "John"),
      `family-name` = list(value = "Doe"),
      `credit-name` = list(value = "J. Doe")
    ),
    biography = list(content = "Researcher in computational biology"),
    keywords = list(
      keyword = list(
        list(content = "Machine Learning"),
        list(content = "Bioinformatics")
      )
    ),
    `researcher-urls` = list(
      `researcher-url` = list(
        list(url = list(value = "https://example.com"))
      )
    ),
    addresses = list(
      address = list(
        list(country = list(value = "US"))
      )
    )
  )

  result <- parse_person(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(result$given_names[1], "John")
  expect_equal(result$family_name[1], "Doe")
  expect_equal(result$credit_name[1], "J. Doe")
  expect_equal(result$biography[1], "Researcher in computational biology")
  expect_true(grepl("Machine Learning", result$keywords[1]))
})

# ==============================================================================
# Parser Tests: parse_bio()
# ==============================================================================

test_that("parse_bio handles empty response", {
  json_data <- list()
  result <- parse_bio(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
})

# ==============================================================================
# Parser Tests: parse_keywords()
# ==============================================================================

test_that("parse_keywords handles empty response", {
  json_data <- list(keyword = list())
  result <- parse_keywords(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
  expect_true("keyword" %in% names(result))
})

test_that("parse_keywords extracts keywords correctly", {
  json_data <- list(
    keyword = list(
      list(
        `put-code` = 123,
        content = "Machine Learning"
      ),
      list(
        `put-code` = 456,
        content = "Bioinformatics"
      )
    )
  )

  result <- parse_keywords(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 2)
  expect_equal(result$keyword[1], "Machine Learning")
  expect_equal(result$keyword[2], "Bioinformatics")
})

# ==============================================================================
# Parser Tests: parse_researcher_urls()
# ==============================================================================

test_that("parse_researcher_urls handles empty response", {
  json_data <- list(`researcher-url` = list())
  result <- parse_researcher_urls(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

# ==============================================================================
# Parser Tests: parse_external_identifiers()
# ==============================================================================

test_that("parse_external_identifiers handles empty response", {
  json_data <- list(`external-identifier` = list())
  result <- parse_external_identifiers(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

# ==============================================================================
# Parser Tests: parse_other_names()
# ==============================================================================

test_that("parse_other_names handles empty response", {
  json_data <- list(`other-name` = list())
  result <- parse_other_names(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

# ==============================================================================
# Parser Tests: parse_address()
# ==============================================================================

test_that("parse_address handles empty response", {
  json_data <- list(address = list())
  result <- parse_address(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

# ==============================================================================
# Parser Tests: parse_email()
# ==============================================================================

test_that("parse_email handles empty response", {
  json_data <- list(email = list())
  result <- parse_email(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})
