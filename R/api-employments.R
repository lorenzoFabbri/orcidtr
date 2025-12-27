#' Retrieve employment history from ORCID
#'
#' @description
#' Fetches employment records for a given ORCID identifier from the ORCID
#' public API. Returns a structured data.table with employment history including
#' organization names, roles, departments, and dates.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'   Most public data is accessible without authentication.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this employment record}
#'     \item{organization}{Name of the employing organization}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Job title or role}
#'     \item{start_date}{Employment start date (ISO format)}
#'     \item{end_date}{Employment end date (ISO format, NA if current)}
#'     \item{city}{City of organization}
#'     \item{region}{State/region of organization}
#'     \item{country}{Country of organization}
#'   }
#'   Returns an empty data.table with the same structure if no employment
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/employments}
#'
#' The function respects ORCID API rate limits and includes appropriate
#' User-Agent headers identifying the orcidtr package.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_educations}}, \code{\link{orcid_works}}, \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch employment history for a public ORCID
#' emp <- orcid_employments("0000-0002-1825-0097")
#' print(emp)
#'
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' emp <- orcid_employments("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_employments <- function(orcid_id, token = NULL) {
  # Normalize and validate ORCID
  orcid_id <- normalize_orcid(orcid_id)
  validate_orcid(orcid_id, stop_on_error = TRUE)

  # Make API request
  response <- orcid_request(
    endpoint = "employments",
    orcid_id = orcid_id,
    token = token,
    base_url = orcid_base_url()
  )

  # Parse and return
  parse_employments(response, orcid_id)
}
