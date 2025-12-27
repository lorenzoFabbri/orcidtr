#' Retrieve complete ORCID record
#'
#' @description
#' Fetches all public data for a given ORCID identifier, including employments,
#' education, works, funding, and peer reviews. Returns a named list of
#' data.table objects.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'   Most public data is accessible without authentication.
#' @param sections Character vector. Sections to fetch. Default is all available
#'   sections: c("employments", "educations", "works", "funding", "peer-reviews").
#'   You can specify a subset to fetch only specific sections.
#'
#' @return A named list with the following elements (each a data.table):
#'   \describe{
#'     \item{employments}{Employment history (see \code{\link{orcid_employments}})}
#'     \item{educations}{Education history (see \code{\link{orcid_educations}})}
#'     \item{works}{Works/publications (see \code{\link{orcid_works}})}
#'     \item{funding}{Funding records (see \code{\link{orcid_funding}})}
#'     \item{peer_reviews}{Peer review activities (see \code{\link{orcid_peer_reviews}})}
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
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_fetch_many}}, \code{\link{orcid_employments}}, \code{\link{orcid_works}}
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
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' record <- orcid_fetch_record("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_fetch_record <- function(
  orcid_id,
  token = NULL,
  sections = c("employments", "educations", "works", "funding", "peer-reviews")
) {
  # Normalize and validate ORCID
  orcid_id <- normalize_orcid(orcid_id)
  validate_orcid(orcid_id, stop_on_error = TRUE)

  # Validate sections
  valid_sections <- c(
    "employments",
    "educations",
    "works",
    "funding",
    "peer-reviews"
  )
  invalid <- setdiff(sections, valid_sections)
  if (length(invalid) > 0) {
    stop(
      "Invalid section(s): ",
      paste(invalid, collapse = ", "),
      ". ",
      "Valid sections are: ",
      paste(valid_sections, collapse = ", "),
      call. = FALSE
    )
  }

  # Initialize result list
  result <- list()

  # Fetch each requested section
  if ("employments" %in% sections) {
    result$employments <- tryCatch(
      orcid_employments(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch employments: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("educations" %in% sections) {
    result$educations <- tryCatch(
      orcid_educations(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch educations: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("works" %in% sections) {
    result$works <- tryCatch(
      orcid_works(orcid_id, token = token),
      error = function(e) {
        warning("Failed to fetch works: ", conditionMessage(e), call. = FALSE)
        data.table::data.table()
      }
    )
  }

  if ("funding" %in% sections) {
    result$funding <- tryCatch(
      orcid_funding(orcid_id, token = token),
      error = function(e) {
        warning("Failed to fetch funding: ", conditionMessage(e), call. = FALSE)
        data.table::data.table()
      }
    )
  }

  if ("peer-reviews" %in% sections) {
    result$peer_reviews <- tryCatch(
      orcid_peer_reviews(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch peer reviews: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  result
}


#' Retrieve records for multiple ORCID identifiers
#'
#' @description
#' Fetches data for multiple ORCID identifiers. This is a convenience function
#' that loops over a vector of ORCID iDs and fetches the specified section(s)
#' for each. Results are combined into a single data.table.
#'
#' @param orcid_ids Character vector. Valid ORCID identifiers in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param section Character string. Section to fetch. One of: "employments",
#'   "educations", "works", "funding", or "peer-reviews".
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#' @param stop_on_error Logical. If TRUE, stops on the first error. If FALSE
#'   (default), continues processing and returns results for successful requests,
#'   issuing warnings for failures.
#'
#' @return A data.table combining results from all successful requests. The
#'   orcid column identifies which ORCID each row belongs to.
#'
#' @details
#' This function makes one API request per ORCID identifier. Be mindful of
#' rate limits when fetching data for many ORCIDs.
#'
#' The function validates each ORCID identifier and normalizes formats before
#' making requests.
#'
#' For rate limit compliance, consider adding delays between large batches
#' or using authenticated requests which typically have higher rate limits.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_fetch_record}}, \code{\link{orcid_works}}, \code{\link{orcid_employments}}
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
  # Validate section
  valid_sections <- c(
    "employments",
    "educations",
    "works",
    "funding",
    "peer-reviews"
  )
  if (!section %in% valid_sections) {
    stop(
      "Invalid section: '",
      section,
      "'. ",
      "Valid sections are: ",
      paste(valid_sections, collapse = ", "),
      call. = FALSE
    )
  }

  if (length(orcid_ids) == 0) {
    stop("orcid_ids cannot be empty", call. = FALSE)
  }

  # Normalize all ORCIDs first
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
    character(1)
  )

  # Remove invalid ORCIDs
  orcid_ids <- orcid_ids[!is.na(orcid_ids)]

  if (length(orcid_ids) == 0) {
    stop("No valid ORCID identifiers provided", call. = FALSE)
  }

  # Select appropriate function
  fetch_fn <- switch(
    section,
    "employments" = orcid_employments,
    "educations" = orcid_educations,
    "works" = orcid_works,
    "funding" = orcid_funding,
    "peer-reviews" = orcid_peer_reviews
  )

  # Fetch data for each ORCID
  results <- lapply(orcid_ids, function(orcid_id) {
    tryCatch(
      {
        fetch_fn(orcid_id, token = token)
      },
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

  # Remove NULL results (failed requests)
  results <- results[!vapply(results, is.null, logical(1))]

  if (length(results) == 0) {
    warning("No data retrieved for any ORCID", call. = FALSE)
    return(data.table::data.table())
  }

  # Combine results
  data.table::rbindlist(results, fill = TRUE)
}
