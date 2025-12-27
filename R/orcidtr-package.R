#' @keywords internal
"_PACKAGE"

#' @name orcidtr-package
#' @aliases orcidtr
#'
#' @title orcidtr: Retrieve Data from the ORCID Public API
#'
#' @description
#' The orcidtr package provides a modern, CRAN-compliant interface to the ORCID
#' public API. It allows you to retrieve employment history, education records,
#' publications, funding information, and peer review activities from ORCID
#' researcher profiles.
#'
#' @section Main Functions:
#' * `orcid_employments()`: Fetch employment history
#' * `orcid_educations()`: Fetch education records
#' * `orcid_works()`: Fetch publications and works
#' * `orcid_funding()`: Fetch funding records
#' * `orcid_peer_reviews()`: Fetch peer review activities
#' * `orcid_fetch_record()`: Fetch complete ORCID record
#' * `orcid_fetch_many()`: Batch fetch for multiple ORCIDs
#'
#' @section Authentication:
#' Most public data is accessible without authentication. To use an optional
#' API token, set the `ORCID_TOKEN` environment variable:
#'
#' \code{Sys.setenv(ORCID_TOKEN = "your-token-here")}
#'
#' @section Package Design:
#' * Uses native pipe (`|>`) operator
#' * Returns data.table objects
#' * Fully qualified function calls (no library imports in functions)
#' * No side effects or global state modifications
#' * Graceful error handling
#' * CRAN-compliant
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @examples
#' \dontrun{
#' # Fetch works for an ORCID
#' works <- orcid_works("0000-0002-1825-0097")
#'
#' # Fetch complete record
#' record <- orcid_fetch_record("0000-0002-1825-0097")
#'
#' # Batch fetch works for multiple ORCIDs
#' orcids <- c("0000-0002-1825-0097", "0000-0003-1419-2405")
#' all_works <- orcid_fetch_many(orcids, section = "works")
#' }
#'
#' @importFrom data.table data.table rbindlist
#' @importFrom httr2 request req_headers req_perform req_retry req_error resp_status resp_status_desc resp_body_string
#' @importFrom jsonlite fromJSON
## usethis namespace: start
## usethis namespace: end
NULL
