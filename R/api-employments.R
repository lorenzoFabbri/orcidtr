#' Retrieve employment history from ORCID
#'
#' @description
#' Fetches employment records for a given ORCID identifier from the ORCID
#' public API. Returns a structured data.table with employment history including
#' organization names, roles, departments, and dates.
#'
#' @inheritParams orcid_works
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
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_educations}}, \code{\link{orcid_works}},
#' \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch employment history for a public ORCID
#' emp <- orcid_employments("0000-0002-1825-0097")
#' print(emp)
#'
#' # With an explicit token
#' emp <- orcid_employments("0000-0002-1825-0097", token = "your-token-here")
#' }
#'
#' @export
orcid_employments <- function(orcid_id, token = NULL) {
  fetch_and_parse("employments", orcid_id, parse_employments, token)
}
