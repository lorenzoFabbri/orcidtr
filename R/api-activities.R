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
