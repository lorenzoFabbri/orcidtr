#' Retrieve funding records from ORCID
#'
#' @description
#' Fetches funding records for a given ORCID identifier from the ORCID public API.
#' Returns a structured data.table with funding details including grant titles,
#' funding organizations, amounts, and dates.
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
#'     \item{put_code}{Unique identifier for this funding record}
#'     \item{title}{Title of the funded project}
#'     \item{type}{Type of funding (e.g., grant, contract, award)}
#'     \item{organization}{Name of the funding organization}
#'     \item{start_date}{Funding start date (ISO format)}
#'     \item{end_date}{Funding end date (ISO format)}
#'     \item{amount}{Funding amount (if available)}
#'     \item{currency}{Currency code (e.g., USD, EUR)}
#'   }
#'   Returns an empty data.table with the same structure if no funding
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/fundings}
#'
#' The function respects ORCID API rate limits and includes appropriate
#' User-Agent headers identifying the orcidtr package.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_works}}, \code{\link{orcid_employments}}, \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch funding records for a public ORCID
#' funding <- orcid_funding("0000-0002-1825-0097")
#' print(funding)
#'
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' funding <- orcid_funding("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_funding <- function(orcid_id, token = NULL) {
  # Normalize and validate ORCID
  orcid_id <- normalize_orcid(orcid_id)
  validate_orcid(orcid_id, stop_on_error = TRUE)

  # Make API request
  response <- orcid_request(
    endpoint = "fundings",
    orcid_id = orcid_id,
    token = token,
    base_url = orcid_base_url()
  )

  # Parse and return
  parse_funding(response, orcid_id)
}
