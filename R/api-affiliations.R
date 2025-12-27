#' Retrieve distinctions from ORCID
#'
#' @description
#' Fetches distinction records (awards, honors, recognitions) for an ORCID
#' identifier. Returns structured data similar to employments and educations.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this distinction record}
#'     \item{organization}{Name of the awarding organization}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Award or distinction title}
#'     \item{start_date}{Award/distinction date (ISO format)}
#'     \item{end_date}{End date (ISO format, if applicable)}
#'     \item{city}{City of organization}
#'     \item{region}{State/region of organization}
#'     \item{country}{Country of organization}
#'   }
#'   Returns an empty data.table with the same structure if no distinction
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/distinctions}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_employments}}, \code{\link{orcid_educations}}, \code{\link{orcid_activities}}
#'
#' @examples
#' \dontrun{
#' # Fetch distinctions
#' distinctions <- orcid_distinctions("0000-0002-1825-0097")
#' print(distinctions)
#' }
#'
#' @export
orcid_distinctions <- function(orcid_id, token = NULL) {
  fetch_and_parse(
    "distinctions",
    orcid_id,
    parse_affiliations,
    token,
    "distinction"
  )
}


#' Retrieve invited positions from ORCID
#'
#' @description
#' Fetches invited position records for an ORCID identifier, such as
#' visiting professorships, guest lectureships, etc.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this invited position record}
#'     \item{organization}{Name of the hosting organization}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Position title}
#'     \item{start_date}{Position start date (ISO format)}
#'     \item{end_date}{Position end date (ISO format)}
#'     \item{city}{City of organization}
#'     \item{region}{State/region of organization}
#'     \item{country}{Country of organization}
#'   }
#'   Returns an empty data.table with the same structure if no invited position
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/invited-positions}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_employments}}, \code{\link{orcid_activities}}
#'
#' @examples
#' \dontrun{
#' # Fetch invited positions
#' positions <- orcid_invited_positions("0000-0002-1825-0097")
#' print(positions)
#' }
#'
#' @export
orcid_invited_positions <- function(orcid_id, token = NULL) {
  fetch_and_parse(
    "invited-positions",
    orcid_id,
    parse_affiliations,
    token,
    "invited-position"
  )
}


#' Retrieve memberships from ORCID
#'
#' @description
#' Fetches professional membership records for an ORCID identifier, such as
#' memberships in professional societies, organizations, etc.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this membership record}
#'     \item{organization}{Name of the organization}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Membership role or title}
#'     \item{start_date}{Membership start date (ISO format)}
#'     \item{end_date}{Membership end date (ISO format)}
#'     \item{city}{City of organization}
#'     \item{region}{State/region of organization}
#'     \item{country}{Country of organization}
#'   }
#'   Returns an empty data.table with the same structure if no membership
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/memberships}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_employments}}, \code{\link{orcid_activities}}
#'
#' @examples
#' \dontrun{
#' # Fetch memberships
#' memberships <- orcid_memberships("0000-0002-1825-0097")
#' print(memberships)
#' }
#'
#' @export
orcid_memberships <- function(orcid_id, token = NULL) {
  fetch_and_parse(
    "memberships",
    orcid_id,
    parse_affiliations,
    token,
    "membership"
  )
}


#' Retrieve qualifications from ORCID
#'
#' @description
#' Fetches professional qualification records for an ORCID identifier, such as
#' licenses, certifications, etc.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this qualification record}
#'     \item{organization}{Name of the issuing organization}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Qualification title}
#'     \item{start_date}{Qualification date (ISO format)}
#'     \item{end_date}{Expiration date (ISO format, if applicable)}
#'     \item{city}{City of organization}
#'     \item{region}{State/region of organization}
#'     \item{country}{Country of organization}
#'   }
#'   Returns an empty data.table with the same structure if no qualification
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/qualifications}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_educations}}, \code{\link{orcid_activities}}
#'
#' @examples
#' \dontrun{
#' # Fetch qualifications
#' qualifications <- orcid_qualifications("0000-0002-1825-0097")
#' print(qualifications)
#' }
#'
#' @export
orcid_qualifications <- function(orcid_id, token = NULL) {
  fetch_and_parse(
    "qualifications",
    orcid_id,
    parse_affiliations,
    token,
    "qualification"
  )
}


#' Retrieve services from ORCID
#'
#' @description
#' Fetches service activity records for an ORCID identifier, such as
#' committee memberships, editorial board positions, peer review activities, etc.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this service record}
#'     \item{organization}{Name of the organization}
#'     \item{department}{Department name (if available)}
#'     \item{role}{Service role or title}
#'     \item{start_date}{Service start date (ISO format)}
#'     \item{end_date}{Service end date (ISO format)}
#'     \item{city}{City of organization}
#'     \item{region}{State/region of organization}
#'     \item{country}{Country of organization}
#'   }
#'   Returns an empty data.table with the same structure if no service
#'   records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/services}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_peer_reviews}}, \code{\link{orcid_activities}}
#'
#' @examples
#' \dontrun{
#' # Fetch services
#' services <- orcid_services("0000-0002-1825-0097")
#' print(services)
#' }
#'
#' @export
orcid_services <- function(orcid_id, token = NULL) {
  fetch_and_parse("services", orcid_id, parse_affiliations, token, "service")
}


#' Retrieve research resources from ORCID
#'
#' @description
#' Fetches research resource records for an ORCID identifier, such as
#' facilities, equipment, databases, collections, etc.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this resource record}
#'     \item{title}{Resource title/name}
#'     \item{hosts}{Hosting organizations (comma-separated)}
#'     \item{start_date}{Resource start date (ISO format)}
#'     \item{end_date}{Resource end date (ISO format)}
#'   }
#'   Returns an empty data.table with the same structure if no research
#'   resource records are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/research-resources}
#'
#' Note: Research resources have a different structure than other affiliations,
#' with a focus on the resource itself rather than organizational affiliations.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_works}}, \code{\link{orcid_activities}}
#'
#' @examples
#' \dontrun{
#' # Fetch research resources
#' resources <- orcid_research_resources("0000-0002-1825-0097")
#' print(resources)
#' }
#'
#' @export
orcid_research_resources <- function(orcid_id, token = NULL) {
  fetch_and_parse(
    "research-resources",
    orcid_id,
    parse_research_resources,
    token
  )
}
