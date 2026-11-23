#' @keywords internal
"_PACKAGE"

#' @name orcidtr-package
#' @aliases orcidtr
#'
#' @title orcidtr: Retrieve Data from the ORCID Public API
#'
#' @description
#' orcidtr reads public data from ORCID records through the ORCID public API
#' (version 3.0) and returns each section as a data.table: affiliations such
#' as employments and educations, works, funding, peer reviews and
#' biographical data. It can also search the ORCID registry.
#'
#' @section Main functions:
#' * [orcid_works()], [orcid_employments()], [orcid_educations()],
#'   [orcid_funding()] and [orcid_peer_reviews()] fetch one section each.
#' * [orcid_fetch_record()] fetches several sections of one record.
#' * [orcid_fetch_many()] fetches one section for many records.
#' * [orcid()], [orcid_search()] and [orcid_doi()] search the registry.
#'
#' @section Authentication:
#' The public API needs no authentication, and no function reads a token from
#' the environment. A `/read-public` token, obtained by registering a public
#' API client with ORCID, gives access to the same public data; it raises the
#' daily read quota but not the request rate. Data with limited visibility is
#' served only by the Member API, which this package does not use. Pass a
#' token explicitly:
#'
#' \code{orcid_works("0000-0002-1825-0097", token = "your-token-here")}
#'
#' The current limits are on the ORCID API limits page linked below.
#'
#' @references
#' ORCID API tutorials:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' ORCID API limits:
#' \url{https://info.orcid.org/ufaqs/what-are-the-api-limits/}
#'
#' @examples
#' \dontrun{
#' works <- orcid_works("0000-0002-1825-0097")
#' record <- orcid_fetch_record("0000-0002-1825-0097")
#'
#' orcids <- c("0000-0002-1825-0097", "0000-0003-1419-2405")
#' all_works <- orcid_fetch_many(orcids, section = "works")
#' }
#'
#' @importFrom data.table data.table rbindlist
#' @importFrom httr2 request req_headers req_perform req_retry req_error
#'   resp_status resp_status_desc resp_body_string
#' @importFrom jsonlite fromJSON
## usethis namespace: start
## usethis namespace: end
NULL
