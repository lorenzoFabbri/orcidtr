#' Retrieve complete ORCID record
#'
#' @description
#' Fetches all public data for a given ORCID identifier, including employments,
#' education, works, funding, and peer reviews. Returns a named list of
#' data.table objects.
#'
#' @inheritParams orcid_works
#' @param sections Character vector. Sections to fetch. Default is the most
#'   commonly used sections: c("employments", "educations", "works", "funding",
#'   "peer-reviews"). Available sections are:
#'   \itemize{
#'     \item Affiliations: "employments", "educations", "distinctions",
#'       "invited-positions", "memberships", "qualifications", "services",
#'       "research-resources"
#'     \item Activities: "works", "funding", "peer-reviews"
#'     \item Biographical: "person", "bio", "keywords", "researcher-urls",
#'       "external-identifiers", "other-names", "address", "email"
#'   }
#'   You can specify a subset to fetch only specific sections.
#'
#' @return A named list with the following possible elements (each a
#'   data.table):
#'   \describe{
#'     \item{employments}{Employment history}
#'     \item{educations}{Education history}
#'     \item{distinctions}{Distinctions and honors}
#'     \item{invited_positions}{Invited positions}
#'     \item{memberships}{Professional memberships}
#'     \item{qualifications}{Qualifications}
#'     \item{services}{Service activities}
#'     \item{research_resources}{Research resources}
#'     \item{works}{Works/publications}
#'     \item{funding}{Funding records}
#'     \item{peer_reviews}{Peer review activities}
#'     \item{person}{Complete person data}
#'     \item{bio}{Biography}
#'     \item{keywords}{Keywords}
#'     \item{researcher_urls}{Researcher URLs}
#'     \item{external_identifiers}{External identifiers}
#'     \item{other_names}{Other names}
#'     \item{address}{Address information}
#'     \item{email}{Email addresses}
#'   }
#'   Empty data.tables are returned for sections with no data.
#'
#' @details
#' This is a convenience function that calls individual API functions for each
#' section. Each section requires a separate API request.
#'
#' To minimize API calls, specify only the sections you need using the
#' \code{sections} parameter.
#'
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_fetch_many}}, \code{\link{orcid_employments}},
#' \code{\link{orcid_works}}
#'
#' @examples
#' \dontrun{
#' # Fetch complete record for a public ORCID
#' record <- orcid_fetch_record("0000-0002-1825-0097")
#' names(record)
#' record$works
#' record$employments
#'
#' # Fetch only works and funding
#' record <- orcid_fetch_record(
#'   "0000-0002-1825-0097",
#'   sections = c("works", "funding")
#' )
#'
#' # With an explicit token
#' record <- orcid_fetch_record("0000-0002-1825-0097", token =
#' "your-token-here")
#' }
#'
#' @export
orcid_fetch_record <- function(
  orcid_id,
  token = NULL,
  sections = c("employments", "educations", "works", "funding", "peer-reviews")
) {
  orcid_id <- normalize_orcid(orcid_id)
  check_sections(sections, names(record_sections))

  result <- lapply(sections, function(section) {
    fetch_fn <- match.fun(record_sections[[section]])
    tryCatch(
      fetch_fn(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch ",
          section,
          ": ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  })
  names(result) <- gsub("-", "_", sections, fixed = TRUE)
  result
}


#' Retrieve records for multiple ORCID identifiers
#'
#' @description
#' Fetches data for multiple ORCID identifiers. This is a convenience function
#' that loops over a vector of ORCID iDs and fetches the specified section(s)
#' for each. Results are combined into a single data.table.
#'
#' @inheritParams orcid_works
#' @param orcid_ids Character vector of ORCID iDs, in any form accepted by
#'   `orcid_id`.
#' @param section Character string. Section to fetch. One of: "employments",
#'   "educations", "distinctions", "invited-positions", "memberships",
#'   "qualifications", "services", "research-resources", "works", "funding",
#'   or "peer-reviews".
#' @param stop_on_error Logical. If `TRUE`, stop at the first invalid iD or
#'   failed request. If `FALSE` (default), warn and carry on with the rest.
#'
#' @return A data.table combining results from all successful requests. The
#'   orcid column identifies which ORCID each row belongs to.
#'
#' @details
#' The function sends one request per iD, one after another. Without a token,
#' ORCID allows 25,000 reads a day from one IP address, so batches larger than
#' that need a `/read-public` token or have to be spread over several days.
#'
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_fetch_record}}, \code{\link{orcid_works}},
#' \code{\link{orcid_employments}}
#'
#' @examples
#' \dontrun{
#' # Fetch works for multiple ORCIDs
#' orcids <- c("0000-0002-1825-0097", "0000-0003-1419-2405")
#' works <- orcid_fetch_many(orcids, section = "works")
#' print(works)
#'
#' # Fetch employments for multiple ORCIDs
#' employments <- orcid_fetch_many(orcids, section = "employments")
#'
#' # Stop on first error
#' works <- orcid_fetch_many(orcids, section = "works", stop_on_error = TRUE)
#' }
#'
#' @export
orcid_fetch_many <- function(
  orcid_ids,
  section = "works",
  token = NULL,
  stop_on_error = FALSE
) {
  if (!is.character(section) || length(section) != 1) {
    stop("section must be a single character string", call. = FALSE)
  }
  check_sections(section, batch_sections)

  if (length(orcid_ids) == 0) {
    stop("orcid_ids cannot be empty", call. = FALSE)
  }

  orcid_ids <- vapply(
    orcid_ids,
    function(id) {
      tryCatch(
        normalize_orcid(id),
        error = function(e) {
          if (stop_on_error) {
            stop(conditionMessage(e), call. = FALSE)
          }
          warning(
            "Invalid ORCID: ",
            id,
            " - ",
            conditionMessage(e),
            call. = FALSE
          )
          NA_character_
        }
      )
    },
    character(1),
    USE.NAMES = FALSE
  )
  orcid_ids <- orcid_ids[!is.na(orcid_ids)]

  if (length(orcid_ids) == 0) {
    stop("No valid ORCID identifiers provided", call. = FALSE)
  }

  fetch_fn <- match.fun(record_sections[[section]])

  results <- lapply(orcid_ids, function(orcid_id) {
    tryCatch(
      fetch_fn(orcid_id, token = token),
      error = function(e) {
        msg <- paste0(
          "Failed to fetch ",
          section,
          " for ",
          orcid_id,
          ": ",
          conditionMessage(e)
        )
        if (stop_on_error) {
          stop(msg, call. = FALSE)
        }
        warning(msg, call. = FALSE)
        NULL
      }
    )
  })
  results <- results[!vapply(results, is.null, logical(1))]

  if (length(results) == 0) {
    warning("No data retrieved for any ORCID", call. = FALSE)
    return(data.table::data.table())
  }

  data.table::rbindlist(results, fill = TRUE)
}


# Section names accepted by orcid_fetch_record(), mapped to the function that
# fetches each. Functions are named rather than referenced because the files
# that define them are collated after this one.
record_sections <- c(
  "employments" = "orcid_employments",
  "educations" = "orcid_educations",
  "distinctions" = "orcid_distinctions",
  "invited-positions" = "orcid_invited_positions",
  "memberships" = "orcid_memberships",
  "qualifications" = "orcid_qualifications",
  "services" = "orcid_services",
  "research-resources" = "orcid_research_resources",
  "works" = "orcid_works",
  "funding" = "orcid_funding",
  "peer-reviews" = "orcid_peer_reviews",
  "person" = "orcid_person",
  "bio" = "orcid_bio",
  "keywords" = "orcid_keywords",
  "researcher-urls" = "orcid_researcher_urls",
  "external-identifiers" = "orcid_external_identifiers",
  "other-names" = "orcid_other_names",
  "address" = "orcid_address",
  "email" = "orcid_email"
)

# orcid_fetch_many() binds rows across records, so it accepts only the
# sections that return one row per item.
batch_sections <- names(record_sections)[1:11]


#' Stop if any requested section is unknown
#'
#' @param sections Character vector of requested sections.
#' @param valid Character vector of accepted sections.
#'
#' @return `NULL`, invisibly.
#' @keywords internal
#' @noRd
check_sections <- function(sections, valid) {
  invalid <- setdiff(sections, valid)
  if (length(invalid) > 0) {
    stop(
      "Invalid section(s): ",
      paste(invalid, collapse = ", "),
      ". Valid sections are: ",
      paste(valid, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(NULL)
}
