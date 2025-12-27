#' Internal HTTP request handler for ORCID API
#'
#' @description
#' Makes authenticated HTTP requests to the ORCID public API with proper
#' headers, error handling, and JSON parsing.
#'
#' @param endpoint Character string. API endpoint path (e.g., "employments").
#' @param orcid_id Character string. Valid ORCID identifier.
#' @param token Character string or NULL. Optional API token. If NULL,
#'   checks ORCID_TOKEN environment variable.
#' @param base_url Character string. Base URL for ORCID API.
#'
#' @return Parsed JSON response as an R list.
#' @keywords internal
#' @noRd
orcid_request <- function(
  endpoint,
  orcid_id,
  token = NULL,
  base_url = "https://pub.orcid.org/v3.0"
) {
  # Get token from environment if not provided
  if (is.null(token)) {
    token <- Sys.getenv("ORCID_TOKEN", unset = "")
    if (token == "") {
      token <- NULL
    }
  }

  # Construct full URL
  url <- paste0(base_url, "/", orcid_id, "/", endpoint)

  # Build request
  req <- httr2::request(url) |>
    httr2::req_headers(
      Accept = "application/json",
      `User-Agent` = paste0(
        "orcidtr/",
        utils::packageVersion("orcidtr"),
        " (R package; https://github.com/lorenzoFabbri/orcidtr)"
      )
    )

  # Add authentication if token is available
  if (!is.null(token) && nchar(token) > 0) {
    req <- req |>
      httr2::req_headers(Authorization = paste("Bearer", token))
  }

  # Perform request with error handling
  resp <- tryCatch(
    {
      req |>
        httr2::req_retry(max_tries = 3, max_seconds = 10) |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform()
    },
    error = function(e) {
      stop(
        "Failed to connect to ORCID API: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  # Check for HTTP errors
  status <- httr2::resp_status(resp)

  if (status == 404) {
    stop(
      "ORCID record not found or endpoint does not exist: ",
      orcid_id,
      "/",
      endpoint,
      call. = FALSE
    )
  }

  if (status == 401) {
    stop(
      "Authentication failed. Check your ORCID_TOKEN environment variable.",
      call. = FALSE
    )
  }

  if (status == 429) {
    stop(
      "Rate limit exceeded. Please wait before making more requests.",
      call. = FALSE
    )
  }

  if (status >= 400) {
    stop(
      "ORCID API request failed with status ",
      status,
      ": ",
      httr2::resp_status_desc(resp),
      call. = FALSE
    )
  }

  # Parse JSON response
  tryCatch(
    {
      body <- httr2::resp_body_string(resp)
      jsonlite::fromJSON(body, simplifyVector = FALSE)
    },
    error = function(e) {
      stop(
        "Failed to parse ORCID API response: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
}


#' Get ORCID API base URL
#'
#' @description
#' Returns the base URL for the ORCID public API. Can be overridden
#' with ORCID_API_URL environment variable for testing.
#'
#' @return Character string with base URL.
#' @keywords internal
#' @noRd
orcid_base_url <- function() {
  url <- Sys.getenv("ORCID_API_URL", unset = "")
  if (url == "") {
    return("https://pub.orcid.org/v3.0")
  }
  url
}
