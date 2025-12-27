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

test_that("parse_educations handles empty response", {
  json_data <- list(`affiliation-group` = list())
  result <- parse_educations(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

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

test_that("parse_funding handles empty response", {
  json_data <- list(group = list())
  result <- parse_funding(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})

test_that("parse_peer_reviews handles empty response", {
  json_data <- list(group = list())
  result <- parse_peer_reviews(json_data, "0000-0002-1825-0097")

  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 0)
})
