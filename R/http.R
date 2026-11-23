#' Perform a GET request against the ORCID public API
#'
#' @description
#' Shared transport for every exported function: sets the headers, sends the
#' token only when one is passed, retries transient failures, maps HTTP errors
#' to readable messages and parses the JSON body.
#'
#' @param url Character string. Full request URL.
#' @param query Named list or NULL. Query parameters to append to the URL.
#' @param token Character string or NULL. Optional `/read-public` access token.
#' @param what Character string. Resource named in error messages.
#'
#' @return Parsed JSON response as an R list.
#' @keywords internal
#' @noRd
orcid_get <- function(url, query = NULL, token = NULL, what = url) {
  req <- httr2::request(url) |>
    httr2::req_headers(
      Accept = "application/json",
      `User-Agent` = paste0(
        "orcidtr/",
        utils::packageVersion("orcidtr"),
        " (R package; https://github.com/lorenzoFabbri/orcidtr)"
      )
    )

  if (length(query) > 0) {
    req <- httr2::req_url_query(req, !!!query)
  }

  # The token is never read from the environment: the public API rejects an
  # invalid token with a 401 even though it needs none, so a stale credential
  # in .Renviron would break every call.
  if (!is.null(token) && nzchar(token)) {
    req <- httr2::req_headers(req, Authorization = paste("Bearer", token))
  }

  resp <- tryCatch(
    req |>
      httr2::req_retry(max_tries = 3, max_seconds = 10) |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform(),
    error = function(e) {
      stop(
        "Failed to connect to ORCID API: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  status <- httr2::resp_status(resp)

  if (status == 404) {
    stop(
      "ORCID record not found or endpoint does not exist: ",
      what,
      call. = FALSE
    )
  }
  if (status == 401) {
    stop(
      "Authentication failed. The public API needs no token; ",
      "the one supplied is invalid or was issued for another API.",
      call. = FALSE
    )
  }
  if (status %in% c(429, 503)) {
    stop(
      "ORCID API returned status ",
      status,
      ": the request rate or the daily usage quota was exceeded, ",
      "or the service is unavailable. Wait before retrying.",
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

  tryCatch(
    jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE),
    error = function(e) {
      stop(
        "Failed to parse ORCID API response: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
}


#' Request one section of an ORCID record
#'
#' @param endpoint Character string. Record section, e.g. "employments".
#' @param orcid_id Character string. Normalized ORCID identifier.
#' @param token Character string or NULL. Optional API token.
#' @param base_url Character string. Base URL for the ORCID API.
#'
#' @return Parsed JSON response as an R list.
#' @keywords internal
#' @noRd
orcid_request <- function(
  endpoint,
  orcid_id,
  token = NULL,
  base_url = orcid_base_url()
) {
  path <- paste0(orcid_id, "/", endpoint)
  orcid_get(paste0(base_url, "/", path), token = token, what = path)
}


#' Get ORCID API base URL
#'
#' @description
#' Returns the base URL for the ORCID public API. The `ORCID_API_URL`
#' environment variable overrides it, which the tests use to point requests at
#' an unreachable host.
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
#' Queries the ORCID status endpoint to check that the public API is reachable
#' and healthy.
#'
#' @return `"OK"` when the API reports itself healthy, otherwise a string
#'   giving the reported status.
#'
#' @details
#' This function queries \code{https://pub.orcid.org/v3.0/status}.
#'
#' @examples
#' \dontrun{
#' orcid_ping()
#' }
#'
#' @export
orcid_ping <- function() {
  json_data <- orcid_get(paste0(orcid_base_url(), "/status"), what = "status")

  tomcat_up <- safe_extract(json_data, "tomcatUp")
  if (isTRUE(tomcat_up)) {
    "OK"
  } else {
    paste("Status:", tomcat_up)
  }
}
