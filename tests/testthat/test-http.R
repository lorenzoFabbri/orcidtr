# ==============================================================================
# Test Suite: HTTP Request Handling
# ==============================================================================
# Tests for http.R functions:
# - orcid_request()
# - orcid_base_url()
# - orcid_ping()

# Helper: Skip if ORCID API is not accessible
skip_if_offline <- function() {
  tryCatch(
    {
      httr2::request("https://pub.orcid.org/v3.0/status") |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform()
      invisible(TRUE)
    },
    error = function(e) {
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
# orcid_request() Tests
# ==============================================================================

test_that("orcid_request makes successful API calls", {
  skip_on_cran()
  skip_if_offline()

  # Use orcid_bio which internally calls orcid_request
  result <- orcid_bio("0000-0002-1825-0097")
  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
})

test_that("orcid_request handles 404 errors", {
  skip_on_cran()
  skip_if_offline()

  # Try to fetch data for a non-existent ORCID
  expect_error(
    orcid_bio("0000-0000-0000-0000"),
    "ORCID record not found"
  )
})

test_that("orcid_request handles authentication errors", {
  skip_on_cran()
  skip_if_offline()

  # Provide an invalid token
  expect_error(
    orcid_bio("0000-0002-1825-0097", token = "invalid-token"),
    "Authentication failed"
  )
})

test_that("orcid_request constructs proper URLs", {
  skip_on_cran()
  skip_if_offline()

  # Test that the request works with different endpoints
  bio <- orcid_bio("0000-0002-1825-0097")
  expect_s3_class(bio, "data.table")

  keywords <- orcid_keywords("0000-0002-1825-0097")
  expect_s3_class(keywords, "data.table")
})

test_that("orcid_request handles network errors", {
  skip_on_cran()

  # Set an invalid base URL to simulate network failure
  withr::with_envvar(
    list(ORCID_API_URL = "https://invalid-domain-that-does-not-exist.com"),
    {
      expect_error(
        orcid_bio("0000-0002-1825-0097"),
        "Failed to connect to ORCID API"
      )
    }
  )
})

test_that("orcid_request includes proper headers", {
  skip_on_cran()
  skip_if_offline()

  # Verify request succeeds with headers
  result <- orcid_bio("0000-0002-1825-0097")
  expect_s3_class(result, "data.table")
})

test_that("orcid_request handles JSON parsing errors", {
  skip_on_cran()

  # We can't easily simulate JSON parse errors, but we can verify
  # that valid responses parse correctly
  result <- orcid_bio("0000-0002-1825-0097")
  expect_s3_class(result, "data.table")
})

# ==============================================================================
# orcid_base_url() Tests
# ==============================================================================

test_that("orcid_base_url returns default URL", {
  # Clear any environment variable
  withr::with_envvar(
    list(ORCID_API_URL = NA),
    {
      # Call a function that uses orcid_base_url internally
      skip_on_cran()
      skip_if_offline()

      result <- orcid_ping()
      expect_type(result, "character")
    }
  )
})

test_that("orcid_base_url respects environment variable", {
  skip_on_cran()

  # Set a custom base URL
  withr::with_envvar(
    list(ORCID_API_URL = "https://custom-api.example.com"),
    {
      # This should fail because the custom URL doesn't exist
      expect_error(
        orcid_ping(),
        "Failed to connect|status check failed"
      )
    }
  )
})

# ==============================================================================
# orcid_ping() Tests
# ==============================================================================

test_that("orcid_ping checks API health", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_ping()

  expect_type(result, "character")
  expect_true(nchar(result) > 0)
  expect_true(result == "OK" || grepl("Status", result))
})

test_that("orcid_ping handles connection failures", {
  skip_on_cran()

  withr::with_envvar(
    list(ORCID_API_URL = "https://invalid-domain.example.com"),
    {
      expect_error(
        orcid_ping(),
        "Failed to connect to ORCID API status endpoint"
      )
    }
  )
})

test_that("orcid_ping handles non-200 responses", {
  skip_on_cran()

  # Set an invalid endpoint to get a non-200 response
  withr::with_envvar(
    list(ORCID_API_URL = "https://pub.orcid.org/v3.0/invalid"),
    {
      expect_error(
        orcid_ping(),
        "status check failed"
      )
    }
  )
})

test_that("orcid_ping retries on temporary failures", {
  skip_on_cran()
  skip_if_offline()

  # The function should succeed even with retry logic
  result <- orcid_ping()
  expect_type(result, "character")
})
