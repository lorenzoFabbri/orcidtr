#' Search ORCID registry
#'
#' @description
#' Search for ORCID profiles using Apache Solr query syntax. This function
#' provides direct access to the ORCID search API with full query capabilities.
#'
#' @param query Character string. Solr query string (e.g., "keyword:ecology",
#'   "family-name:Smith AND given-names:John"). If NULL, returns empty results.
#' @param rows Integer. Number of results to return (default: 10, max: 1000).
#' @param start Integer. Starting position for pagination (default: 0).
#' @param token Character string or NULL. Optional API token. Most searches
#'   work without authentication.
#' @param ... Additional parameters passed to the API request.
#'
#' @return A data.table with columns:
#'   \describe{
#'     \item{orcid_id}{ORCID identifier}
#'     \item{given_names}{Given name(s)}
#'     \item{family_name}{Family name}
#'     \item{credit_name}{Credit/published name}
#'     \item{other_names}{Alternative names (list column)}
#'   }
#'   Returns empty data.table if no results found.
#'   The total number of matches is available as \code{attr(result, "found")}.
#'
#' @details
#' This function queries the ORCID search endpoint:
#' \code{https://pub.orcid.org/v3.0/search}
#'
#' **Query Field Examples:**
#' \itemize{
#'   \item \code{family-name:Smith}
#'   \item \code{given-names:John}
#'   \item \code{keyword:ecology}
#'   \item \code{affiliation-org-name:Harvard}
#'   \item \code{digital-object-ids:10.1371/*}
#'   \item \code{email:*@example.org}
#' }
#'
#' **Boolean Operators:**
#' Use AND, OR, NOT for complex queries:
#' \code{"family-name:Smith AND affiliation-org-name:Harvard"}
#'
#' @references
#' ORCID API Search Documentation: \url{https://info.orcid.org/documentation/integration-guide/searching-the-orcid-registry/}
#'
#' @seealso
#' \code{\link{orcid_search}} for a more user-friendly interface,
#' \code{\link{orcid_doi}} for DOI-specific searches
#'
#' @examples
#' \dontrun{
#' # Search by keyword
#' results <- orcid("keyword:ecology", rows = 20)
#' print(results)
#' attr(results, "found")  # Total number of matches
#'
#' # Search by name
#' results <- orcid("family-name:Fabbri AND given-names:Lorenzo")
#'
#' # Search by affiliation
#' results <- orcid("affiliation-org-name:Stanford")
#'
#' # Search by DOI
#' results <- orcid("digital-object-ids:10.1371/*")
#'
#' # Pagination
#' page1 <- orcid("keyword:genomics", rows = 10, start = 0)
#' page2 <- orcid("keyword:genomics", rows = 10, start = 10)
#' }
#'
#' @export
orcid <- function(query = NULL, rows = 10, start = 0, token = NULL, ...) {
  # Handle NULL query
  if (is.null(query) || query == "") {
    warning("No query provided, returning empty results", call. = FALSE)
    result <- data.table::data.table(
      orcid_id = character(0),
      given_names = character(0),
      family_name = character(0),
      credit_name = character(0),
      other_names = list()
    )
    attr(result, "found") <- 0L
    return(result)
  }

  # Validate parameters
  if (!is.numeric(rows) || rows < 1 || rows > 1000) {
    stop("rows must be between 1 and 1000", call. = FALSE)
  }
  if (!is.numeric(start) || start < 0) {
    stop("start must be a non-negative integer", call. = FALSE)
  }

  # Get token
  if (is.null(token)) {
    token <- Sys.getenv("ORCID_TOKEN", unset = "")
    if (token == "") {
      token <- NULL
    }
  }

  # Construct URL
  url <- paste0(orcid_base_url(), "/search")

  # Build request
  req <- httr2::request(url) |>
    httr2::req_headers(
      Accept = "application/json",
      `User-Agent` = paste0(
        "orcidtr/",
        utils::packageVersion("orcidtr"),
        " (R package; https://github.com/lorenzoFabbri/orcidtr)"
      )
    ) |>
    httr2::req_url_query(
      q = query,
      rows = rows,
      start = start
    )

  # Add authentication if token available
  if (!is.null(token) && nchar(token) > 0) {
    req <- req |>
      httr2::req_headers(Authorization = paste("Bearer", token))
  }

  # Perform request
  resp <- tryCatch(
    {
      req |>
        httr2::req_retry(max_tries = 3, max_seconds = 10) |>
        httr2::req_error(is_error = function(resp) FALSE) |>
        httr2::req_perform()
    },
    error = function(e) {
      stop(
        "Failed to connect to ORCID search API: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  # Check for HTTP errors
  status <- httr2::resp_status(resp)
  if (status >= 400) {
    stop(
      "ORCID search API request failed with status ",
      status,
      ": ",
      httr2::resp_status_desc(resp),
      call. = FALSE
    )
  }

  # Parse JSON response
  json_data <- tryCatch(
    {
      body <- httr2::resp_body_string(resp)
      jsonlite::fromJSON(body, simplifyVector = FALSE)
    },
    error = function(e) {
      stop(
        "Failed to parse ORCID search response: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  # Parse and return
  parse_search_results(json_data)
}


#' User-friendly ORCID search
#'
#' @description
#' Search for ORCID profiles using named parameters instead of Solr query
#' syntax. This function provides a more intuitive interface than \code{\link{orcid}}.
#'
#' @param given_name Character string. Given (first) name to search for.
#' @param family_name Character string. Family (last) name to search for.
#' @param affiliation_org Character string. Organization name.
#' @param email Character string. Email address (supports wildcards like *@example.org).
#' @param keywords Character vector. One or more keywords to search for.
#' @param digital_object_ids Character string. DOI or DOI pattern.
#' @param other_name Character string. Alternative name.
#' @param credit_name Character string. Credit/published name.
#' @param rows Integer. Number of results to return (default: 10).
#' @param start Integer. Starting position for pagination (default: 0).
#' @param token Character string or NULL. Optional API token.
#' @param ... Additional parameters passed to \code{\link{orcid}}.
#'
#' @return A data.table of search results (same structure as \code{\link{orcid}}).
#'   The total number of matches is available as \code{attr(result, "found")}.
#'
#' @details
#' This function constructs a Solr query from the provided parameters and
#' calls \code{\link{orcid}} internally. Multiple parameters are combined
#' with AND logic.
#'
#' @examples
#' \dontrun{
#' # Search by name
#' results <- orcid_search(
#'   family_name = "Fabbri",
#'   given_name = "Lorenzo"
#' )
#'
#' # Search by affiliation
#' results <- orcid_search(affiliation_org = "Stanford University")
#'
#' # Search by keywords
#' results <- orcid_search(keywords = c("machine learning", "genomics"))
#'
#' # Combine multiple criteria
#' results <- orcid_search(
#'   family_name = "Smith",
#'   affiliation_org = "Harvard",
#'   rows = 20
#' )
#' }
#'
#' @seealso
#' \code{\link{orcid}} for more flexible query syntax
#'
#' @export
orcid_search <- function(
  given_name = NULL,
  family_name = NULL,
  affiliation_org = NULL,
  email = NULL,
  keywords = NULL,
  digital_object_ids = NULL,
  other_name = NULL,
  credit_name = NULL,
  rows = 10,
  start = 0,
  token = NULL,
  ...
) {
  # Build query components
  query_parts <- character(0)

  if (!is.null(given_name)) {
    query_parts <- c(query_parts, paste0("given-names:", given_name))
  }
  if (!is.null(family_name)) {
    query_parts <- c(query_parts, paste0("family-name:", family_name))
  }
  if (!is.null(affiliation_org)) {
    query_parts <- c(
      query_parts,
      paste0("affiliation-org-name:", affiliation_org)
    )
  }
  if (!is.null(email)) {
    query_parts <- c(query_parts, paste0("email:", email))
  }
  if (!is.null(keywords)) {
    # Handle multiple keywords
    if (length(keywords) > 1) {
      kw_query <- paste0(
        "(",
        paste(paste0("keyword:", keywords), collapse = " OR "),
        ")"
      )
      query_parts <- c(query_parts, kw_query)
    } else {
      query_parts <- c(query_parts, paste0("keyword:", keywords))
    }
  }
  if (!is.null(digital_object_ids)) {
    query_parts <- c(
      query_parts,
      paste0("digital-object-ids:", digital_object_ids)
    )
  }
  if (!is.null(other_name)) {
    query_parts <- c(query_parts, paste0("other-names:", other_name))
  }
  if (!is.null(credit_name)) {
    query_parts <- c(query_parts, paste0("credit-name:", credit_name))
  }

  # Combine with AND
  if (length(query_parts) == 0) {
    warning(
      "No search criteria provided, returning empty results",
      call. = FALSE
    )
    result <- data.table::data.table(
      orcid_id = character(0),
      given_names = character(0),
      family_name = character(0),
      credit_name = character(0),
      other_names = list()
    )
    attr(result, "found") <- 0L
    return(result)
  }

  query <- paste(query_parts, collapse = " AND ")

  # Call orcid() with constructed query
  orcid(
    query = query,
    rows = rows,
    start = start,
    token = token,
    ...
  )
}


#' Search ORCID by DOI
#'
#' @description
#' Search for ORCID profiles associated with specific DOIs. This is a
#' convenience wrapper around \code{\link{orcid}} for DOI-based searches.
#'
#' @param dois Character vector. One or more DOIs to search for.
#' @param fuzzy Logical. Use fuzzy matching for DOI search (default: FALSE).
#'   Fuzzy matching allows partial DOI matches.
#' @param rows Integer. Number of results per DOI (default: 10).
#' @param token Character string or NULL. Optional API token.
#'
#' @return A named list where each element corresponds to a DOI and contains
#'   a data.table of search results. If only one DOI is provided, returns
#'   the data.table directly. Empty data.tables are returned for DOIs with
#'   no matches.
#'
#' @details
#' This function searches the \code{digital-object-ids} field in the ORCID
#' registry. When \code{fuzzy = TRUE}, wildcard matching is used to find
#' partial DOI matches.
#'
#' @examples
#' \dontrun{
#' # Search by single DOI
#' results <- orcid_doi("10.1371/journal.pone.0025995")
#' print(results)
#'
#' # Search by multiple DOIs
#' dois <- c("10.1038/nature12373", "10.1126/science.1260419")
#' results <- orcid_doi(dois)
#' names(results)
#'
#' # Fuzzy search (partial DOI)
#' results <- orcid_doi("10.1371/*", fuzzy = TRUE, rows = 20)
#' }
#'
#' @seealso
#' \code{\link{orcid}}, \code{\link{orcid_search}}
#'
#' @export
orcid_doi <- function(dois, fuzzy = FALSE, rows = 10, token = NULL) {
  # Validate input
  if (is.null(dois) || length(dois) == 0) {
    stop("At least one DOI must be provided", call. = FALSE)
  }

  # Function to search single DOI
  search_doi <- function(doi) {
    # Construct query
    if (fuzzy) {
      # Add wildcard if not present and fuzzy matching requested
      if (!grepl("\\*", doi)) {
        doi_query <- paste0('"', doi, '*"')
      } else {
        doi_query <- paste0('"', doi, '"')
      }
    } else {
      doi_query <- paste0('"', doi, '"')
    }

    query <- paste0("digital-object-ids:", doi_query)

    # Search
    tryCatch(
      {
        orcid(query = query, rows = rows, token = token)
      },
      error = function(e) {
        warning(
          "Search failed for DOI ",
          doi,
          ": ",
          conditionMessage(e),
          call. = FALSE
        )
        # Return empty result
        result <- data.table::data.table(
          orcid_id = character(0),
          given_names = character(0),
          family_name = character(0),
          credit_name = character(0),
          other_names = list()
        )
        attr(result, "found") <- 0L
        result
      }
    )
  }

  # Search all DOIs
  results <- lapply(dois, search_doi)
  names(results) <- dois

  # If single DOI, return data.table directly
  if (length(dois) == 1) {
    return(results[[1]])
  }

  # Otherwise return named list
  results
}
