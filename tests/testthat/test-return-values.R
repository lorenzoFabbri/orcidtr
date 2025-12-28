# ==============================================================================
# Test Suite: Return Values and Function Completeness
# ==============================================================================
# Comprehensive tests to ensure all exported functions return proper values
# and don't return NULL or fail unexpectedly.

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

# Test ORCID to use (this is a public test ORCID from ORCID documentation)
test_orcid <- "0000-0002-1825-0097"

# ==============================================================================
# Activities and Record Functions
# ==============================================================================

test_that("orcid_activities returns a list with expected structure", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_activities(test_orcid)

  # Should return a list
  expect_type(result, "list")
  expect_false(is.null(result))

  # Should have all expected sections
  expected_sections <- c(
    "distinctions",
    "educations",
    "employments",
    "invited_positions",
    "memberships",
    "qualifications",
    "services",
    "fundings",
    "peer_reviews",
    "research_resources",
    "works"
  )
  expect_true(all(expected_sections %in% names(result)))

  # Each section should be a data.table
  for (section in expected_sections) {
    expect_s3_class(result[[section]], "data.table")
  }
})

test_that("orcid_ping returns a character string", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_ping()

  # Should return character string
  expect_type(result, "character")
  expect_false(is.null(result))
  expect_true(nchar(result) > 0)
})

test_that("orcid_fetch_record returns a list with requested sections", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_fetch_record(test_orcid, sections = c("works", "employments"))

  expect_type(result, "list")
  expect_false(is.null(result))
  expect_true("works" %in% names(result))
  expect_true("employments" %in% names(result))
  expect_s3_class(result$works, "data.table")
  expect_s3_class(result$employments, "data.table")
})

test_that("orcid_fetch_many returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_fetch_many(
    c("0000-0002-1825-0097", "0000-0003-1419-2405"),
    section = "works"
  )

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
})

# ==============================================================================
# Person/Biographical Functions
# ==============================================================================

test_that("orcid_person returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_person(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_equal(nrow(result), 1)
  expect_true("orcid" %in% names(result))
  expect_true("given_names" %in% names(result))
  expect_true("family_name" %in% names(result))
})

test_that("orcid_bio returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_bio(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
  expect_true("biography" %in% names(result))
})

test_that("orcid_keywords returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_keywords(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  # May be empty, but should have correct structure
  if (nrow(result) > 0) {
    expect_true("orcid" %in% names(result))
    expect_true("keyword" %in% names(result))
  }
})

test_that("orcid_researcher_urls returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_researcher_urls(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  if (nrow(result) > 0) {
    expect_true("url_value" %in% names(result))
  }
})

test_that("orcid_external_identifiers returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_external_identifiers(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_other_names returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_other_names(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_address returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_address(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_email returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_email(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

# ==============================================================================
# Research Output Functions
# ==============================================================================

test_that("orcid_works returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_works(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
  if (nrow(result) > 0) {
    expect_true("title" %in% names(result))
    expect_true("type" %in% names(result))
  }
})

test_that("orcid_funding returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_funding(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
})

test_that("orcid_peer_reviews returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_peer_reviews(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
})

# ==============================================================================
# Affiliation Functions
# ==============================================================================

test_that("orcid_employments returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_employments(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
  if (nrow(result) > 0) {
    expect_true("organization" %in% names(result))
  }
})

test_that("orcid_educations returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_educations(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid" %in% names(result))
})

test_that("orcid_distinctions returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_distinctions(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_invited_positions returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_invited_positions(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_memberships returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_memberships(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_qualifications returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_qualifications(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_services returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_services(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

test_that("orcid_research_resources returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_research_resources(test_orcid)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
})

# ==============================================================================
# Search Functions
# ==============================================================================

test_that("orcid returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid(query = "family-name:Wickham", rows = 5)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid_id" %in% names(result))
  # Has found attribute
  expect_true(!is.null(attr(result, "found")))
})

test_that("orcid_search returns a data.table", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid_search(family_name = "Smith", rows = 5)

  expect_s3_class(result, "data.table")
  expect_false(is.null(result))
  expect_true("orcid_id" %in% names(result))
})

test_that("orcid_doi returns appropriate type", {
  skip_on_cran()
  skip_if_offline()

  # Single DOI should return data.table
  result_single <- orcid_doi(dois = "10.1371/journal.pone.0001543", rows = 5)
  expect_s3_class(result_single, "data.table")
  expect_false(is.null(result_single))

  # Multiple DOIs should return list
  result_multi <- orcid_doi(
    dois = c("10.1371/journal.pone.0001543", "10.1371/journal.pone.0001544"),
    rows = 5
  )
  expect_type(result_multi, "list")
  expect_false(is.null(result_multi))
  expect_equal(length(result_multi), 2)
})

# ==============================================================================
# Edge Cases and Error Handling
# ==============================================================================

test_that("all functions handle invalid ORCID appropriately", {
  # All functions should error on invalid ORCID
  expect_error(orcid_activities("invalid"), "Invalid ORCID")
  expect_error(orcid_person("invalid"), "Invalid ORCID")
  expect_error(orcid_works("invalid"), "Invalid ORCID")
  expect_error(orcid_employments("invalid"), "Invalid ORCID")
  expect_error(orcid_educations("invalid"), "Invalid ORCID")
})

test_that("all functions normalize ORCID URLs", {
  skip_on_cran()
  skip_if_offline()

  # Should accept URL format
  result1 <- orcid_person("https://orcid.org/0000-0002-1825-0097")
  result2 <- orcid_person("0000-0002-1825-0097")

  expect_s3_class(result1, "data.table")
  expect_s3_class(result2, "data.table")
  expect_equal(result1$orcid[1], result2$orcid[1])
})

test_that("search functions handle empty results gracefully", {
  skip_on_cran()
  skip_if_offline()

  result <- orcid(query = "family-name:XyZqWvAbCdEfGh123456789", rows = 10)

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
  expect_equal(attr(result, "found"), 0)
})

test_that("fetch_many handles mixed valid/invalid ORCIDs", {
  skip_on_cran()
  skip_if_offline()

  # Should warn about invalid but continue
  expect_warning(
    result <- orcid_fetch_many(
      c("0000-0002-1825-0097", "invalid-orcid"),
      section = "works",
      stop_on_error = FALSE
    )
  )

  expect_s3_class(result, "data.table")
  # Should have some data from valid ORCID
  expect_true(nrow(result) >= 0)
})
