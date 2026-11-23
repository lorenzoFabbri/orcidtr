#' Retrieve works (publications) from ORCID
#'
#' @description
#' Fetches work records (publications, datasets, preprints, etc.) for a given
#' ORCID identifier from the ORCID public API. Returns a structured data.table
#' with work details including titles, types, DOIs, and publication dates.
#'
#' @param orcid_id Character string. An ORCID iD such as
#'   `"0000-0002-1825-0097"`. The dashes and an `https://orcid.org/` prefix are
#'   optional.
#' @param token Character string or `NULL`. Optional `/read-public` access
#'   token. The public API needs none: it returns the same public data either
#'   way, and a token only raises the daily read quota. See the Authentication
#'   section of [orcidtr-package].
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this work record}
#'     \item{title}{Title of the work}
#'     \item{type}{Type of work. Common values include: "journal-article",
#'       "conference-paper", "conference-poster", "book", "book-chapter",
#'       "dissertation", "data-set", "preprint", "report", "working-paper",
#'       "other". Use this field to distinguish between different publication
#'       types.}
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
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_employments}}, \code{\link{orcid_funding}},
#' \code{\link{orcid_fetch_record}}
#'
#' @examples
#' \dontrun{
#' # Fetch works for a public ORCID
#' works <- orcid_works("0000-0002-1825-0097")
#' print(works)
#'
#' # Filter by type to distinguish between different publication types
#' journal_articles <- works[type == "journal-article"]
#' conference_posters <- works[type == "conference-poster"]
#' datasets <- works[type == "data-set"]
#' preprints <- works[type == "preprint"]
#'
#' # With an explicit token
#' works <- orcid_works("0000-0002-1825-0097", token = "your-token-here")
#' }
#'
#' @export
orcid_works <- function(orcid_id, token = NULL) {
  fetch_and_parse("works", orcid_id, parse_works, token)
}
