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
#' @return A named list with the following possible elements (each a data.table):
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
    # Affiliations
    "employments",
    "educations",
    "distinctions",
    "invited-positions",
    "memberships",
    "qualifications",
    "services",
    "research-resources",
    # Works and activities
    "works",
    "funding",
    "peer-reviews",
    # Person/biographical
    "person",
    "bio",
    "keywords",
    "researcher-urls",
    "external-identifiers",
    "other-names",
    "address",
    "email"
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

  # Professional activities
  if ("distinctions" %in% sections) {
    result$distinctions <- tryCatch(
      orcid_distinctions(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch distinctions: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("invited-positions" %in% sections) {
    result$invited_positions <- tryCatch(
      orcid_invited_positions(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch invited positions: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("memberships" %in% sections) {
    result$memberships <- tryCatch(
      orcid_memberships(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch memberships: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("qualifications" %in% sections) {
    result$qualifications <- tryCatch(
      orcid_qualifications(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch qualifications: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("services" %in% sections) {
    result$services <- tryCatch(
      orcid_services(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch services: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("research-resources" %in% sections) {
    result$research_resources <- tryCatch(
      orcid_research_resources(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch research resources: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  # Biographical data
  if ("person" %in% sections) {
    result$person <- tryCatch(
      orcid_person(orcid_id, token = token),
      error = function(e) {
        warning("Failed to fetch person: ", conditionMessage(e), call. = FALSE)
        data.table::data.table()
      }
    )
  }

  if ("bio" %in% sections) {
    result$bio <- tryCatch(
      orcid_bio(orcid_id, token = token),
      error = function(e) {
        warning("Failed to fetch bio: ", conditionMessage(e), call. = FALSE)
        data.table::data.table()
      }
    )
  }

  if ("keywords" %in% sections) {
    result$keywords <- tryCatch(
      orcid_keywords(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch keywords: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("researcher-urls" %in% sections) {
    result$researcher_urls <- tryCatch(
      orcid_researcher_urls(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch researcher URLs: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("external-identifiers" %in% sections) {
    result$external_identifiers <- tryCatch(
      orcid_external_identifiers(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch external identifiers: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("other-names" %in% sections) {
    result$other_names <- tryCatch(
      orcid_other_names(orcid_id, token = token),
      error = function(e) {
        warning(
          "Failed to fetch other names: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table()
      }
    )
  }

  if ("address" %in% sections) {
    result$address <- tryCatch(
      orcid_address(orcid_id, token = token),
      error = function(e) {
        warning("Failed to fetch address: ", conditionMessage(e), call. = FALSE)
        data.table::data.table()
      }
    )
  }

  if ("email" %in% sections) {
    result$email <- tryCatch(
      orcid_email(orcid_id, token = token),
      error = function(e) {
        warning("Failed to fetch email: ", conditionMessage(e), call. = FALSE)
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
#'   "educations", "distinctions", "invited-positions", "memberships",
#'   "qualifications", "services", "research-resources", "works", "funding",
#'   or "peer-reviews".
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
    "distinctions",
    "invited-positions",
    "memberships",
    "qualifications",
    "services",
    "research-resources",
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
    "distinctions" = orcid_distinctions,
    "invited-positions" = orcid_invited_positions,
    "memberships" = orcid_memberships,
    "qualifications" = orcid_qualifications,
    "services" = orcid_services,
    "research-resources" = orcid_research_resources,
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
