#' Retrieve activities summary from ORCID
#'
#' @description
#' Fetches a comprehensive summary of all activities for an ORCID identifier
#' in a single API call. This is more efficient than calling individual
#' endpoints when you need multiple activity types.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A named list with data.table elements for each activity section:
#'   \describe{
#'     \item{distinctions}{Distinctions/awards summary}
#'     \item{educations}{Education history summary}
#'     \item{employments}{Employment history summary}
#'     \item{invited_positions}{Invited positions summary}
#'     \item{memberships}{Professional memberships summary}
#'     \item{qualifications}{Qualifications/licenses summary}
#'     \item{services}{Service activities summary}
#'     \item{fundings}{Funding records summary}
#'     \item{peer_reviews}{Peer review activities summary}
#'     \item{research_resources}{Research resources summary}
#'     \item{works}{Works/publications summary}
#'   }
#'   Empty data.tables are returned for sections with no data.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/activities}
#'
#' This endpoint provides summary information for all activity types in a
#' single request, which is more efficient than making multiple individual
#' requests. However, the summaries contain less detail than the full
#' individual records.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_fetch_record}}, \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch all activities
#' activities <- orcid_activities("0000-0002-1825-0097")
#' names(activities)
#'
#' # Access specific sections
#' activities$works
#' activities$employments
#' activities$fundings
#' }
#'
#' @export
orcid_activities <- function(orcid_id, token = NULL) {
  fetch_and_parse("activities", orcid_id, parse_activities, token)
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

  # Build request with plain text response
  req <- httr2::request(url) |>
    httr2::req_headers(
      Accept = "text/plain",
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

  # Return body as text
  httr2::resp_body_string(resp)
}
