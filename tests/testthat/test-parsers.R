# ==============================================================================
# Test Suite: Parser Functions
# ==============================================================================
# Tests for parsers.R functions that convert JSON to data.tables

# ==============================================================================
# parse_affiliation_group() Tests
# ==============================================================================

test_that("parse_affiliation_group handles empty groups", {
  json_data <- list()
  result <- orcidtr:::parse_affiliation_group(
    json_data,
    "0000-0002-1825-0097",
    "employment-summary"
  )

  expect_s3_class(result, "data.table")
  expect_true("orcid" %in% names(result))
  expect_true("organization" %in% names(result))
})

test_that("parse_affiliation_group handles NULL groups", {
  json_data <- list("affiliation-group" = NULL)
  result <- orcidtr:::parse_affiliation_group(
    json_data,
    "0000-0002-1825-0097",
    "employment-summary"
  )

  expect_s3_class(result, "data.table")
})

test_that("parse_affiliation_group parses valid employment data", {
  json_data <- list(
    "affiliation-group" = list(
      list(
        summaries = list(
          list(
            "employment-summary" = list(
              "put-code" = 12345,
              organization = list(
                name = "Test University",
                address = list(
                  city = "TestCity",
                  region = "TestRegion",
                  country = "US"
                )
              ),
              "department-name" = "Computer Science",
              "role-title" = "Professor",
              "start-date" = list(
                year = list(value = "2020"),
                month = list(value = "01"),
                day = list(value = "01")
              ),
              "end-date" = NULL
            )
          )
        )
      )
    )
  )

  result <- orcidtr:::parse_affiliation_group(
    json_data,
    "0000-0002-1825-0097",
    "employment-summary"
  )

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$orcid[1], "0000-0002-1825-0097")
  expect_equal(result$organization[1], "Test University")
  expect_equal(result$department[1], "Computer Science")
  expect_equal(result$role[1], "Professor")
})

# ==============================================================================
# parse_employments() Tests
# ==============================================================================

test_that("parse_employments uses correct summary key", {
  json_data <- list()
  result <- orcidtr:::parse_employments(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

# ==============================================================================
# parse_educations() Tests
# ==============================================================================

test_that("parse_educations uses correct summary key", {
  json_data <- list()
  result <- orcidtr:::parse_educations(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

# ==============================================================================
# parse_works() Tests
# ==============================================================================

test_that("parse_works handles empty works", {
  json_data <- list()
  result <- orcidtr:::parse_works(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_works parses valid work data", {
  json_data <- list(
    group = list(
      list(
        "work-summary" = list(
          list(
            "put-code" = 54321,
            title = list(
              title = list(value = "Test Publication")
            ),
            "journal-title" = list(value = "Test Journal"),
            type = "journal-article",
            "publication-date" = list(
              year = list(value = "2023"),
              month = list(value = "05"),
              day = list(value = "15")
            ),
            "external-ids" = list(
              "external-id" = list(
                list(
                  "external-id-type" = "doi",
                  "external-id-value" = "10.1234/test"
                )
              )
            )
          )
        )
      )
    )
  )

  result <- orcidtr:::parse_works(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$orcid[1], "0000-0002-1825-0097")
  expect_equal(result$title[1], "Test Publication")
  expect_equal(result$type[1], "journal-article")
})

# ==============================================================================
# parse_funding() Tests
# ==============================================================================

test_that("parse_funding handles empty funding", {
  json_data <- list()
  result <- orcidtr:::parse_funding(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_funding parses valid funding data", {
  json_data <- list(
    group = list(
      list(
        "funding-summary" = list(
          list(
            "put-code" = 11111,
            title = list(
              title = list(value = "Test Grant")
            ),
            type = "grant",
            organization = list(
              name = "Test Foundation"
            ),
            "start-date" = list(year = list(value = "2021")),
            "end-date" = list(year = list(value = "2024"))
          )
        )
      )
    )
  )

  result <- orcidtr:::parse_funding(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$title[1], "Test Grant")
})

# ==============================================================================
# parse_peer_reviews() Tests
# ==============================================================================

test_that("parse_peer_reviews handles empty reviews", {
  json_data <- list()
  result <- orcidtr:::parse_peer_reviews(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

# ==============================================================================
# parse_affiliations() Tests
# ==============================================================================

test_that("parse_affiliations handles empty affiliations", {
  json_data <- list()
  result <- orcidtr:::parse_affiliations(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

# ==============================================================================
# parse_person() Tests
# ==============================================================================

test_that("parse_person handles empty person data", {
  json_data <- list()
  result <- orcidtr:::parse_person(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$orcid[1], "0000-0002-1825-0097")
})

test_that("parse_person extracts name and biography", {
  json_data <- list(
    name = list(
      "given-names" = list(value = "John"),
      "family-name" = list(value = "Doe"),
      "credit-name" = list(value = "J. Doe")
    ),
    biography = list(
      content = "Test biography"
    )
  )

  result <- orcidtr:::parse_person(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(result$given_names[1], "John")
  expect_equal(result$family_name[1], "Doe")
  expect_equal(result$credit_name[1], "J. Doe")
  expect_equal(result$biography[1], "Test biography")
})

# ==============================================================================
# parse_bio() Tests
# ==============================================================================

test_that("parse_bio handles empty biography", {
  json_data <- list()
  result <- orcidtr:::parse_bio(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
})

test_that("parse_bio extracts biography content", {
  json_data <- list(
    content = "This is a test biography",
    visibility = "public"
  )

  result <- orcidtr:::parse_bio(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(result$biography[1], "This is a test biography")
  expect_equal(result$visibility[1], "public")
})

# ==============================================================================
# parse_keywords() Tests
# ==============================================================================

test_that("parse_keywords handles empty keywords", {
  json_data <- list()
  result <- orcidtr:::parse_keywords(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_keywords extracts multiple keywords", {
  json_data <- list(
    keyword = list(
      list(content = "machine learning"),
      list(content = "data science"),
      list(content = "statistics")
    )
  )

  result <- orcidtr:::parse_keywords(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 3)
  expect_true("machine learning" %in% result$keyword)
  expect_true("data science" %in% result$keyword)
})

# ==============================================================================
# parse_researcher_urls() Tests
# ==============================================================================

test_that("parse_researcher_urls handles empty URLs", {
  json_data <- list()
  result <- orcidtr:::parse_researcher_urls(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_researcher_urls extracts URLs", {
  json_data <- list(
    "researcher-url" = list(
      list(
        "url-name" = "Personal Website",
        url = list(value = "https://example.com")
      ),
      list(
        "url-name" = "GitHub",
        url = list(value = "https://github.com/user")
      )
    )
  )

  result <- orcidtr:::parse_researcher_urls(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 2)
  expect_true("Personal Website" %in% result$url_name)
})

# ==============================================================================
# parse_external_identifiers() Tests
# ==============================================================================

test_that("parse_external_identifiers handles empty identifiers", {
  json_data <- list()
  result <- orcidtr:::parse_external_identifiers(
    json_data,
    "0000-0002-1825-0097"
  )

  expect_s3_class(result, "data.table")
})

test_that("parse_external_identifiers extracts identifiers", {
  json_data <- list(
    "external-identifier" = list(
      list(
        "external-id-type" = "Scopus Author ID",
        "external-id-value" = "123456"
      )
    )
  )

  result <- orcidtr:::parse_external_identifiers(
    json_data,
    "0000-0002-1825-0097"
  )

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$external_id_type[1], "Scopus Author ID")
  expect_equal(result$external_id_value[1], "123456")
})

# ==============================================================================
# parse_other_names() Tests
# ==============================================================================

test_that("parse_other_names handles empty names", {
  json_data <- list()
  result <- orcidtr:::parse_other_names(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_other_names extracts other names", {
  json_data <- list(
    "other-name" = list(
      list(content = "J. Doe"),
      list(content = "John A. Doe")
    )
  )

  result <- orcidtr:::parse_other_names(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 2)
  expect_true("J. Doe" %in% result$other_name)
})

# ==============================================================================
# parse_address() Tests
# ==============================================================================

test_that("parse_address handles empty address", {
  json_data <- list()
  result <- orcidtr:::parse_address(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_address extracts country", {
  json_data <- list(
    address = list(
      list(country = list(value = "US"))
    )
  )

  result <- orcidtr:::parse_address(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$country[1], "US")
})

# ==============================================================================
# parse_email() Tests
# ==============================================================================

test_that("parse_email handles empty email", {
  json_data <- list()
  result <- orcidtr:::parse_email(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
})

test_that("parse_email extracts email addresses", {
  json_data <- list(
    email = list(
      list(
        email = "test@example.com",
        primary = TRUE,
        verified = TRUE
      )
    )
  )

  result <- orcidtr:::parse_email(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$email[1], "test@example.com")
})

# ==============================================================================
# parse_activities() Tests
# ==============================================================================

test_that("parse_activities handles empty activities", {
  json_data <- list()
  result <- orcidtr:::parse_activities(json_data, "0000-0002-1825-0097")

  expect_type(result, "list")
  expect_true("distinctions" %in% names(result))
  expect_true("works" %in% names(result))
  expect_s3_class(result$works, "data.table")
})

# ==============================================================================
# parse_search_results() Tests
# ==============================================================================

test_that("parse_search_results handles empty results", {
  json_data <- list(result = list())
  result <- orcidtr:::parse_search_results(json_data)

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

test_that("parse_search_results extracts search results", {
  json_data <- list(
    result = list(
      list(
        "orcid-identifier" = list(
          path = "0000-0002-1825-0097"
        )
      )
    )
  )

  result <- orcidtr:::parse_search_results(json_data)

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  expect_equal(result$orcid[1], "0000-0002-1825-0097")
})

test_that("parse_search_results handles NULL result field", {
  json_data <- list(result = NULL)
  result <- orcidtr:::parse_search_results(json_data)

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})
