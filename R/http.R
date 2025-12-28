#' Internal HTTP request handler for ORCID API
#'
#' @description
#' Makes HTTP requests to the ORCID public API with proper headers, error
#' handling, and JSON parsing. Authentication is optional - the public API
#' works without any token for reading public data.
#'
#' @param endpoint Character string. API endpoint path (e.g., "employments").
#' @param orcid_id Character string. Valid ORCID identifier.
#' @param token Character string or NULL. Optional API token for higher rate
#'   limits or accessing private data (if granted). If NULL, no authentication
#'   is used. The public API does not require authentication.
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
  # For public API, don't automatically use ORCID_TOKEN from environment
  # Public API endpoints don't require authentication and sending an invalid
  # token will cause a 401 error. Only use token if explicitly provided.
  # Note: Member API (api.orcid.org) would require authentication.

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

  # Add authentication if token is explicitly provided
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
      "Authentication failed. ",
      "The public API does not require authentication. ",
      "If you provided a token, it may be invalid or for the member API.",
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


#' Check ORCID API status
#'
#' @description
#' Checks the health and availability of the ORCID public API. Useful for
#' diagnostics and ensuring the API is accessible before making requests.
#'
#' @return Character string with API status message (typically "OK" if healthy)
#'
#' @details
#' This function queries the ORCID API status endpoint:
#' \code{https://pub.orcid.org/v3.0/status}
#'
#' @examples
#' \dontrun{
#' # Check API status
#' status <- orcid_ping()
#' print(status)
#' }
#'
#' @export
orcid_ping <- function() {
  # Construct URL
  url <- paste0(orcid_base_url(), "/status")

  # Build request with JSON response
  req <- httr2::request(url) |>
    httr2::req_headers(
      Accept = "application/json",
      `User-Agent` = paste0(
        "orcidtr/",
        utils::packageVersion("orcidtr"),
        " (R package; https://github.com/lorenzoFabbri/orcidtr)"
      )
    )

  # Perform request
  resp <- tryCatch(
    {
      req |>
        httr2::req_retry(max_tries = 3, max_seconds = 10) |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform()
    },
    error = function(e) {
      stop(
        "Failed to connect to ORCID API status endpoint: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  # Check status
  status <- httr2::resp_status(resp)
  if (status != 200) {
    stop("ORCID API status check failed with status ", status, call. = FALSE)
  }

  # Parse JSON response
  json_data <- tryCatch(
    {
      body <- httr2::resp_body_string(resp)
      jsonlite::fromJSON(body, simplifyVector = FALSE)
    },
    error = function(e) {
      stop(
        "Failed to parse ORCID API status response: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  # Extract tomcatUp status
  tomcat_up <- safe_extract(json_data, "tomcatUp")
  if (isTRUE(tomcat_up)) {
    return("OK")
  } else {
    return(paste("Status:", tomcat_up))
  }
}
