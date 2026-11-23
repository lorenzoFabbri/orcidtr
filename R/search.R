#' Search the ORCID registry with a Solr query
#'
#' @description
#' Sends an Apache Solr query to the ORCID expanded-search endpoint and returns
#' the matching iDs with their names.
#'
#' @param query Character string. Solr query, such as `"keyword:ecology"` or
#'   `"family-name:Smith AND given-names:John"`. `NULL` or `""` returns an
#'   empty result with a warning.
#' @param rows Integer. Number of results to return, from 1 to 1000. Default 10.
#' @param start Integer. Offset of the first result, for pagination. Default 0.
#' @inheritParams orcid_works
#'
#' @return A data.table with columns:
#'   \describe{
#'     \item{orcid_id}{ORCID identifier}
#'     \item{given_names}{Given name(s)}
#'     \item{family_name}{Family name}
#'     \item{credit_name}{Published name}
#'     \item{other_names}{List column; each element is a character vector of
#'       alternative names}
#'   }
#'   The total number of matches, which can exceed `rows`, is in
#'   \code{attr(result, "found")}. No matches give a zero-row table.
#'
#' @details
#' This function queries \code{https://pub.orcid.org/v3.0/expanded-search},
#' which returns names alongside each iD.
#'
#' Useful fields include `family-name`, `given-names`, `credit-name`,
#' `other-names`, `keyword`, `affiliation-org-name`, `email` and
#' `digital-object-ids`. Combine terms with `AND`, `OR` and `NOT`. Put a value
#' that contains spaces or a slash in double quotes: Solr reads an unquoted
#' second word as a separate term matched against every field, and an
#' unquoted `/` as the start of a regular expression. A trailing `*` inside the
#' quotes matches any suffix, so `digital-object-ids:"10.1371/*"` finds every
#' record with a PLOS DOI.
#'
#' @references
#' ORCID search tutorial:
#' \url{https://info.orcid.org/documentation/api-tutorials/api-tutorial-searching-the-orcid-registry/}
#'
#' @seealso
#' [orcid_search()] to build the query from named arguments, [orcid_doi()] to
#' search by DOI.
#'
#' @examples
#' \dontrun{
#' results <- orcid("keyword:ecology", rows = 20)
#' attr(results, "found")
#'
#' orcid("family-name:Carberry AND given-names:Josiah")
#' orcid('affiliation-org-name:"Stanford University"')
#' orcid('digital-object-ids:"10.1371/*"')
#'
#' # Pagination
#' page1 <- orcid("keyword:genomics", rows = 10, start = 0)
#' page2 <- orcid("keyword:genomics", rows = 10, start = 10)
#' }
#'
#' @export
orcid <- function(query = NULL, rows = 10, start = 0, token = NULL) {
  if (is.null(query) || identical(query, "")) {
    warning("No query provided, returning empty results", call. = FALSE)
    return(empty_search_result())
  }
  if (!is.character(query) || length(query) != 1 || is.na(query)) {
    stop("query must be a single character string", call. = FALSE)
  }
  if (!is_count(rows) || rows < 1 || rows > 1000) {
    stop("rows must be a whole number between 1 and 1000", call. = FALSE)
  }
  if (!is_count(start) || start < 0) {
    stop("start must be a non-negative whole number", call. = FALSE)
  }

  json_data <- orcid_get(
    paste0(orcid_base_url(), "/expanded-search"),
    query = list(q = query, rows = rows, start = start),
    token = token,
    what = "expanded-search"
  )

  parse_search_results(json_data)
}


#' Search the ORCID registry by named fields
#'
#' @description
#' Builds a Solr query from named arguments and passes it to [orcid()].
#'
#' @param given_name Character string. Given name.
#' @param family_name Character string. Family name.
#' @param affiliation_org Character string. Organization name.
#' @param email Character string. Email address; wildcards such as
#'   `"*@example.org"` are allowed.
#' @param keywords Character vector. One or more keywords; a record matches if
#'   it has any of them.
#' @param digital_object_ids Character string. DOI, or a DOI prefix ending in
#'   `*`.
#' @param other_name Character string. Alternative name.
#' @param credit_name Character string. Published name.
#' @inheritParams orcid
#'
#' @return A data.table with the same columns as [orcid()], and the total
#'   number of matches in \code{attr(result, "found")}.
#'
#' @details
#' Each argument becomes one `field:value` term, and the terms are combined
#' with `AND`. Values containing spaces or slashes are wrapped in double
#' quotes, so `affiliation_org = "Stanford University"` matches that phrase
#' rather than any record mentioning "University". Calling the function with
#' no criteria returns an empty result with a warning.
#'
#' @examples
#' \dontrun{
#' orcid_search(family_name = "Carberry", given_name = "Josiah")
#' orcid_search(affiliation_org = "Stanford University")
#' orcid_search(keywords = c("machine learning", "genomics"))
#' orcid_search(family_name = "Smith", affiliation_org = "Harvard", rows = 20)
#' }
#'
#' @seealso [orcid()] for arbitrary Solr queries.
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
  token = NULL
) {
  fields <- list(
    "given-names" = given_name,
    "family-name" = family_name,
    "affiliation-org-name" = affiliation_org,
    "email" = email,
    "digital-object-ids" = digital_object_ids,
    "other-names" = other_name,
    "credit-name" = credit_name
  )
  fields <- fields[!vapply(fields, is.null, logical(1))]

  query_parts <- character(0)
  if (length(fields) > 0) {
    query_parts <- paste0(names(fields), ":", vapply(fields, solr_value, ""))
  }

  if (!is.null(keywords)) {
    kw <- paste0("keyword:", vapply(keywords, solr_value, ""))
    query_parts <- c(
      query_parts,
      if (length(kw) > 1) paste0("(", paste(kw, collapse = " OR "), ")") else kw
    )
  }

  if (length(query_parts) == 0) {
    warning(
      "No search criteria provided, returning empty results",
      call. = FALSE
    )
    return(empty_search_result())
  }

  orcid(
    query = paste(query_parts, collapse = " AND "),
    rows = rows,
    start = start,
    token = token
  )
}


#' Search the ORCID registry by DOI
#'
#' @description
#' Finds the ORCID records that list a given DOI among their works.
#'
#' @param dois Character vector. One or more DOIs.
#' @param fuzzy Logical. If `TRUE`, each DOI is treated as a prefix: a `*` is
#'   appended unless one is already present. Default `FALSE`.
#' @param rows Integer. Number of results per DOI. Default 10.
#' @inheritParams orcid_works
#'
#' @return For one DOI, a data.table with the same columns as [orcid()]. For
#'   several, a list of such tables named by DOI. A DOI whose search fails
#'   gives a zero-row table and a warning.
#'
#' @examples
#' \dontrun{
#' orcid_doi("10.1371/journal.pone.0025995")
#'
#' results <- orcid_doi(c("10.1038/nature12373", "10.1126/science.1260419"))
#' names(results)
#'
#' # Every record with a PLOS ONE DOI
#' orcid_doi("10.1371/journal.pone", fuzzy = TRUE, rows = 20)
#' }
#'
#' @seealso [orcid()], [orcid_search()]
#'
#' @export
orcid_doi <- function(dois, fuzzy = FALSE, rows = 10, token = NULL) {
  if (is.null(dois) || length(dois) == 0) {
    stop("At least one DOI must be provided", call. = FALSE)
  }

  search_doi <- function(doi) {
    if (fuzzy && !grepl("*", doi, fixed = TRUE)) {
      doi <- paste0(doi, "*")
    }
    query <- paste0('digital-object-ids:"', doi, '"')
    tryCatch(
      orcid(query = query, rows = rows, token = token),
      error = function(e) {
        warning(
          "Search failed for DOI ",
          doi,
          ": ",
          conditionMessage(e),
          call. = FALSE
        )
        empty_search_result()
      }
    )
  }

  results <- lapply(dois, search_doi)
  names(results) <- dois

  if (length(dois) == 1) {
    return(results[[1]])
  }
  results
}


#' Quote a Solr field value when it needs quoting
#'
#' @description
#' Wraps a value in double quotes when it contains whitespace or a slash and is
#' not quoted already. Inner double quotes are escaped.
#'
#' @param x Character string.
#'
#' @return Character string.
#' @keywords internal
#' @noRd
solr_value <- function(x) {
  if (!is.character(x) || length(x) != 1 || is.na(x)) {
    stop("Search values must be single character strings", call. = FALSE)
  }
  if (grepl('^".*"$', x) || !grepl("[[:space:]/]", x)) {
    return(x)
  }
  paste0('"', gsub('"', '\\\\"', x), '"')
}


#' Test whether a value is a single non-negative whole number
#'
#' @param x Value to test.
#'
#' @return Logical scalar.
#' @keywords internal
#' @noRd
is_count <- function(x) {
  is.numeric(x) && length(x) == 1 && !is.na(x) && x == round(x)
}
