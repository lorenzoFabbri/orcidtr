#' Retrieve education history from ORCID
#'
#' @description
#' Fetches education records for a given ORCID identifier from the ORCID
#' public API. Returns a structured data.table with education history including
#' institutions, degrees, departments, and dates.
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
#'     \item{put_code}{Unique identifier for this education record}
#'     \item{organization}{Name of the educational institution}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Degree or program name}
#'     \item{start_date}{Education start date (ISO format)}
#'     \item{end_date}{Education end date (ISO format)}
#'     \item{city}{City of institution}
#'     \item{region}{State/region of institution}
#'     \item{country}{Country of institution}
#'   }
#'   Returns an empty data.table with the same structure if no education
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/educations}
#'
#' The function respects ORCID API rate limits and includes appropriate
#' User-Agent headers identifying the orcidtr package.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_employments}}, \code{\link{orcid_works}}, \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch education history for a public ORCID
#' edu <- orcid_educations("0000-0002-1825-0097")
#' print(edu)
#'
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' edu <- orcid_educations("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_educations <- function(orcid_id, token = NULL) {
  fetch_and_parse("educations", orcid_id, parse_educations, token)
}
