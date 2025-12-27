#' Retrieve peer review activities from ORCID
#'
#' @description
#' Fetches peer review records for a given ORCID identifier from the ORCID
#' public API. Returns a structured data.table with peer review activities
#' including reviewer roles, review types, and organizations.
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
#'     \item{put_code}{Unique identifier for this peer review record}
#'     \item{reviewer_role}{Role of the reviewer (e.g., reviewer, editor)}
#'     \item{review_type}{Type of review (e.g., review, evaluation)}
#'     \item{review_completion_date}{Date the review was completed (ISO format)}
#'     \item{organization}{Name of the convening organization (e.g., journal, conference)}
#'   }
#'   Returns an empty data.table with the same structure if no peer review
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/peer-reviews}
#'
#' Peer review activities can include journal article reviews, conference paper
#' reviews, grant reviews, and other forms of scholarly evaluation.
#'
#' The function respects ORCID API rate limits and includes appropriate
#' User-Agent headers identifying the orcidtr package.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_works}}, \code{\link{orcid_funding}}, \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch peer review records for a public ORCID
#' reviews <- orcid_peer_reviews("0000-0002-1825-0097")
#' print(reviews)
#'
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' reviews <- orcid_peer_reviews("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_peer_reviews <- function(orcid_id, token = NULL) {
  # Normalize and validate ORCID
  orcid_id <- normalize_orcid(orcid_id)
  validate_orcid(orcid_id, stop_on_error = TRUE)

  # Make API request
  response <- orcid_request(
    endpoint = "peer-reviews",
    orcid_id = orcid_id,
    token = token,
    base_url = orcid_base_url()
  )

  # Parse and return
  parse_peer_reviews(response, orcid_id)
}
