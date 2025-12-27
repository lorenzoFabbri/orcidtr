#' Retrieve works (publications) from ORCID
#'
#' @description
#' Fetches work records (publications, datasets, preprints, etc.) for a given
#' ORCID identifier from the ORCID public API. Returns a structured data.table
#' with work details including titles, types, DOIs, and publication dates.
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
#'     \item{put_code}{Unique identifier for this work record}
#'     \item{title}{Title of the work}
#'     \item{type}{Type of work (e.g., journal-article, dataset, preprint)}
#'     \item{publication_date}{Publication date (ISO format)}
#'     \item{journal}{Journal or venue name (if available)}
#'     \item{doi}{Digital Object Identifier (if available)}
#'     \item{url}{URL to the work (if available)}
#'   }
#'   Returns an empty data.table with the same structure if no works are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/works}
#'
#' Works can include journal articles, books, datasets, conference papers,
#' preprints, posters, and other scholarly outputs. The type field indicates
#' the specific category of each work.
#'
#' The function respects ORCID API rate limits and includes appropriate
#' User-Agent headers identifying the orcidtr package.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_employments}}, \code{\link{orcid_funding}}, \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch works for a public ORCID
#' works <- orcid_works("0000-0002-1825-0097")
#' print(works)
#'
#' # Filter by type
#' articles <- works[type == "journal-article"]
#' datasets <- works[type == "data-set"]
#'
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' works <- orcid_works("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_works <- function(orcid_id, token = NULL) {
  # Normalize and validate ORCID
  orcid_id <- normalize_orcid(orcid_id)
  validate_orcid(orcid_id, stop_on_error = TRUE)

  # Make API request
  response <- orcid_request(
    endpoint = "works",
    orcid_id = orcid_id,
    token = token,
    base_url = orcid_base_url()
  )

  # Parse and return
  parse_works(response, orcid_id)
}
