# Column types of every table the package returns. Empty results use the same
# columns, so code that filters or binds results never meets a missing column.
affiliation_columns <- c(
  orcid = "character",
  put_code = "character",
  organization = "character",
  department = "character",
  role = "character",
  start_date = "character",
  end_date = "character",
  city = "character",
  region = "character",
  country = "character"
)

works_columns <- c(
  orcid = "character",
  put_code = "character",
  title = "character",
  type = "character",
  publication_date = "character",
  journal = "character",
  doi = "character",
  url = "character"
)

funding_columns <- c(
  orcid = "character",
  put_code = "character",
  title = "character",
  type = "character",
  organization = "character",
  start_date = "character",
  end_date = "character",
  amount = "character",
  currency = "character"
)

peer_review_columns <- c(
  orcid = "character",
  put_code = "character",
  reviewer_role = "character",
  review_type = "character",
  review_completion_date = "character",
  organization = "character"
)

research_resource_columns <- c(
  orcid = "character",
  put_code = "character",
  proposal_title = "character",
  start_date = "character",
  end_date = "character"
)

search_columns <- c(
  orcid_id = "character",
  given_names = "character",
  family_name = "character",
  credit_name = "character",
  other_names = "list"
)


#' Build an empty data.table with given column types
#'
#' @param columns Named character vector mapping column names to types.
#'
#' @return data.table with zero rows.
#' @keywords internal
#' @noRd
empty_table <- function(columns) {
  data.table::as.data.table(lapply(columns, function(type) vector(type, 0)))
}


#' Bind parsed rows, or return the empty table when there are none
#'
#' @param rows List of named lists, possibly containing NULL entries.
#' @param columns Named character vector of column types.
#'
#' @return data.table.
#' @keywords internal
#' @noRd
bind_rows_or_empty <- function(rows, columns) {
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (length(rows) == 0) {
    return(empty_table(columns))
  }
  data.table::rbindlist(rows, fill = TRUE)
}


#' Parse an affiliation-group response
#'
#' @description
#' Employments, educations, distinctions, invited positions, memberships,
#' qualifications and services share one structure: a list of
#' `affiliation-group` entries, each holding `summaries` keyed by type.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#' @param summary_key Character vector. Summary keys to look for in each item;
#'   the first one present is used.
#'
#' @return data.table with affiliation records.
#' @keywords internal
#' @noRd
parse_affiliation_group <- function(json_data, orcid_id, summary_key) {
  groups <- safe_extract(json_data, "affiliation-group")
  if (is_absent(groups) || !is.list(groups)) {
    return(empty_table(affiliation_columns))
  }

  rows <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "summaries")
    if (is_absent(summaries) || !is.list(summaries)) {
      return(NULL)
    }
    lapply(summaries, function(item) {
      summary <- NULL
      for (key in summary_key) {
        candidate <- safe_extract(item, key)
        if (!is_absent(candidate) && is.list(candidate)) {
          summary <- candidate
          break
        }
      }
      if (is.null(summary)) {
        return(NULL)
      }
      list(
        orcid = orcid_id,
        put_code = extract_chr(summary, "put-code"),
        organization = extract_chr(summary, "organization", "name"),
        department = extract_chr(summary, "department-name"),
        role = extract_chr(summary, "role-title"),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date")),
        city = extract_chr(summary, "organization", "address", "city"),
        region = extract_chr(summary, "organization", "address", "region"),
        country = extract_chr(summary, "organization", "address", "country")
      )
    })
  })

  bind_rows_or_empty(unlist(rows, recursive = FALSE), affiliation_columns)
}


#' Parse a grouped activity response
#'
#' @description
#' Works, fundings, peer reviews and research resources return a list of
#' `group` entries, each holding one or more summaries of the same item from
#' different sources.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param summary_key Character string. Key of the summary list in each group.
#' @param row_fn Function taking one summary and returning a named list.
#' @param columns Named character vector of column types.
#' @param first_only Logical. Keep only the first summary in each group.
#'
#' @return data.table.
#' @keywords internal
#' @noRd
parse_activity_group <- function(
  json_data,
  summary_key,
  row_fn,
  columns,
  first_only = FALSE
) {
  groups <- safe_extract(json_data, "group")
  if (is_absent(groups) || !is.list(groups)) {
    return(empty_table(columns))
  }

  rows <- lapply(groups, function(group) {
    summaries <- safe_extract(group, summary_key)
    if (is_absent(summaries) || !is.list(summaries)) {
      return(NULL)
    }
    if (first_only) {
      summaries <- summaries[1]
    }
    lapply(summaries, function(summary) {
      if (is_absent(summary) || !is.list(summary)) {
        return(NULL)
      }
      row_fn(summary)
    })
  })

  bind_rows_or_empty(unlist(rows, recursive = FALSE), columns)
}


#' Parse a flat list of person items
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param key Character string. Key of the item list.
#' @param row_fn Function taking one item and returning a named list.
#' @param columns Named character vector of column types.
#'
#' @return data.table.
#' @keywords internal
#' @noRd
parse_item_list <- function(json_data, key, row_fn, columns) {
  items <- safe_extract(json_data, key)
  if (is_absent(items) || !is.list(items)) {
    return(empty_table(columns))
  }
  rows <- lapply(items, function(item) {
    if (is_absent(item) || !is.list(item)) {
      return(NULL)
    }
    row_fn(item)
  })
  bind_rows_or_empty(rows, columns)
}


#' Parse employment records from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with employment records.
#' @keywords internal
#' @noRd
parse_employments <- function(json_data, orcid_id) {
  parse_affiliation_group(json_data, orcid_id, "employment-summary")
}


#' Parse education records from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with education records.
#' @keywords internal
#' @noRd
parse_educations <- function(json_data, orcid_id) {
  parse_affiliation_group(json_data, orcid_id, "education-summary")
}


#' Parse distinctions, invited positions, memberships, qualifications or
#' services from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with affiliation records.
#' @keywords internal
#' @noRd
parse_affiliations <- function(json_data, orcid_id) {
  parse_affiliation_group(
    json_data,
    orcid_id,
    c(
      "distinction-summary",
      "invited-position-summary",
      "membership-summary",
      "qualification-summary",
      "service-summary"
    )
  )
}


#' Parse works (publications) from ORCID API
#'
#' @description
#' Keeps the first `work-summary` of each group: the others describe the same
#' work as reported by other sources.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with work records.
#' @keywords internal
#' @noRd
parse_works <- function(json_data, orcid_id) {
  parse_activity_group(
    json_data,
    "work-summary",
    function(summary) {
      doi <- NA_character_
      ext_ids <- safe_extract(summary, "external-ids", "external-id")
      if (!is_absent(ext_ids) && is.list(ext_ids)) {
        for (ext_id in ext_ids) {
          if (identical(extract_chr(ext_id, "external-id-type"), "doi")) {
            doi <- extract_chr(ext_id, "external-id-value")
            break
          }
        }
      }
      list(
        orcid = orcid_id,
        put_code = extract_chr(summary, "put-code"),
        title = extract_chr(summary, "title", "title", "value"),
        type = extract_chr(summary, "type"),
        publication_date = orcid_date_to_iso(
          safe_extract(summary, "publication-date")
        ),
        journal = extract_chr(summary, "journal-title", "value"),
        doi = doi,
        url = extract_chr(summary, "url", "value")
      )
    },
    works_columns,
    first_only = TRUE
  )
}


#' Parse funding records from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with funding records.
#' @keywords internal
#' @noRd
parse_funding <- function(json_data, orcid_id) {
  parse_activity_group(
    json_data,
    "funding-summary",
    function(summary) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(summary, "put-code"),
        title = extract_chr(summary, "title", "title", "value"),
        type = extract_chr(summary, "type"),
        organization = extract_chr(summary, "organization", "name"),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date")),
        amount = extract_chr(summary, "amount", "value"),
        currency = extract_chr(summary, "amount", "currency-code")
      )
    },
    funding_columns
  )
}


#' Parse peer review records from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with peer review records.
#' @keywords internal
#' @noRd
parse_peer_reviews <- function(json_data, orcid_id) {
  parse_activity_group(
    json_data,
    "peer-review-summary",
    function(summary) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(summary, "put-code"),
        reviewer_role = extract_chr(summary, "reviewer-role"),
        review_type = extract_chr(summary, "review-type"),
        review_completion_date = orcid_date_to_iso(
          safe_extract(summary, "completion-date")
        ),
        organization = extract_chr(summary, "convening-organization", "name")
      )
    },
    peer_review_columns
  )
}


#' Parse research resources from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with research resource records.
#' @keywords internal
#' @noRd
parse_research_resources <- function(json_data, orcid_id) {
  parse_activity_group(
    json_data,
    "research-resource-summary",
    function(summary) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(summary, "put-code"),
        proposal_title = extract_chr(
          summary,
          "proposal",
          "title",
          "title",
          "value"
        ),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date"))
      )
    },
    research_resource_columns
  )
}


#' Collapse one field of a list of items into a comma-separated string
#'
#' @param items List of items, or a missing value.
#' @param ... Character strings. Path to the field within each item.
#'
#' @return Character scalar, `NA` when no item has the field.
#' @keywords internal
#' @noRd
collapse_field <- function(items, ...) {
  if (is_absent(items) || !is.list(items)) {
    return(NA_character_)
  }
  values <- vapply(items, function(item) extract_chr(item, ...), character(1))
  values <- values[!is.na(values)]
  if (length(values) == 0) {
    return(NA_character_)
  }
  paste(values, collapse = ", ")
}


#' Parse person/biographical data from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return One-row data.table with person data.
#' @keywords internal
#' @noRd
parse_person <- function(json_data, orcid_id) {
  addresses <- safe_extract(json_data, "addresses", "address")
  country <- if (!is_absent(addresses) && is.list(addresses)) {
    extract_chr(addresses[[1]], "country", "value")
  } else {
    NA_character_
  }

  data.table::data.table(
    orcid = orcid_id,
    given_names = extract_chr(json_data, "name", "given-names", "value"),
    family_name = extract_chr(json_data, "name", "family-name", "value"),
    credit_name = extract_chr(json_data, "name", "credit-name", "value"),
    biography = extract_chr(json_data, "biography", "content"),
    keywords = collapse_field(
      safe_extract(json_data, "keywords", "keyword"),
      "content"
    ),
    researcher_urls = collapse_field(
      safe_extract(json_data, "researcher-urls", "researcher-url"),
      "url",
      "value"
    ),
    country = country
  )
}


#' Parse biography from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return One-row data.table with biography data.
#' @keywords internal
#' @noRd
parse_bio <- function(json_data, orcid_id) {
  data.table::data.table(
    orcid = orcid_id,
    biography = extract_chr(json_data, "content"),
    visibility = extract_chr(json_data, "visibility")
  )
}


#' Parse keywords from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with keywords.
#' @keywords internal
#' @noRd
parse_keywords <- function(json_data, orcid_id) {
  parse_item_list(
    json_data,
    "keyword",
    function(item) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(item, "put-code"),
        keyword = extract_chr(item, "content")
      )
    },
    c(orcid = "character", put_code = "character", keyword = "character")
  )
}


#' Parse researcher URLs from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with researcher URLs.
#' @keywords internal
#' @noRd
parse_researcher_urls <- function(json_data, orcid_id) {
  parse_item_list(
    json_data,
    "researcher-url",
    function(item) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(item, "put-code"),
        url_name = extract_chr(item, "url-name"),
        url_value = extract_chr(item, "url", "value")
      )
    },
    c(
      orcid = "character",
      put_code = "character",
      url_name = "character",
      url_value = "character"
    )
  )
}


#' Parse external identifiers from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with external identifiers.
#' @keywords internal
#' @noRd
parse_external_identifiers <- function(json_data, orcid_id) {
  parse_item_list(
    json_data,
    "external-identifier",
    function(item) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(item, "put-code"),
        external_id_type = extract_chr(item, "external-id-type"),
        external_id_value = extract_chr(item, "external-id-value"),
        external_id_url = extract_chr(item, "external-id-url", "value")
      )
    },
    c(
      orcid = "character",
      put_code = "character",
      external_id_type = "character",
      external_id_value = "character",
      external_id_url = "character"
    )
  )
}


#' Parse other names from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with other names.
#' @keywords internal
#' @noRd
parse_other_names <- function(json_data, orcid_id) {
  parse_item_list(
    json_data,
    "other-name",
    function(item) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(item, "put-code"),
        other_name = extract_chr(item, "content")
      )
    },
    c(orcid = "character", put_code = "character", other_name = "character")
  )
}


#' Parse address from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with address data.
#' @keywords internal
#' @noRd
parse_address <- function(json_data, orcid_id) {
  parse_item_list(
    json_data,
    "address",
    function(item) {
      list(
        orcid = orcid_id,
        put_code = extract_chr(item, "put-code"),
        country = extract_chr(item, "country", "value")
      )
    },
    c(orcid = "character", put_code = "character", country = "character")
  )
}


#' Parse email from ORCID API
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with email addresses.
#' @keywords internal
#' @noRd
parse_email <- function(json_data, orcid_id) {
  parse_item_list(
    json_data,
    "email",
    function(item) {
      list(
        orcid = orcid_id,
        email = extract_chr(item, "email"),
        verified = isTRUE(safe_extract(item, "verified")),
        primary = isTRUE(safe_extract(item, "primary"))
      )
    },
    c(
      orcid = "character",
      email = "character",
      verified = "logical",
      primary = "logical"
    )
  )
}


#' Parse activities summary from ORCID API
#'
#' @description
#' Applies the section parsers to each part of the `/activities` response. A
#' section missing from the response yields that section's empty table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return Named list with a data.table for each activity type.
#' @keywords internal
#' @noRd
parse_activities <- function(json_data, orcid_id) {
  sections <- list(
    distinctions = list("distinctions", parse_affiliations),
    educations = list("educations", parse_educations),
    employments = list("employments", parse_employments),
    invited_positions = list("invited-positions", parse_affiliations),
    memberships = list("memberships", parse_affiliations),
    qualifications = list("qualifications", parse_affiliations),
    services = list("services", parse_affiliations),
    fundings = list("fundings", parse_funding),
    peer_reviews = list("peer-reviews", parse_peer_reviews),
    research_resources = list("research-resources", parse_research_resources),
    works = list("works", parse_works)
  )

  lapply(sections, function(section) {
    section_data <- safe_extract(json_data, section[[1]])
    if (!is.list(section_data)) {
      section_data <- list()
    }
    section[[2]](section_data, orcid_id)
  })
}


#' Build an empty search result
#'
#' @param found Integer. Total number of matches to record.
#'
#' @return Zero-row data.table with a `found` attribute.
#' @keywords internal
#' @noRd
empty_search_result <- function(found = 0L) {
  result <- empty_table(search_columns)
  attr(result, "found") <- as.integer(found)
  result
}


#' Parse search results from ORCID API
#'
#' @description
#' Reads the `expanded-result` list returned by `/expanded-search`, falling
#' back to the `result` list of the basic `/search` endpoint.
#'
#' @param json_data List. Parsed JSON response from ORCID search API.
#'
#' @return data.table with columns orcid_id, given_names, family_name,
#'   credit_name and other_names. The `found` attribute holds the total number
#'   of matches.
#' @keywords internal
#' @noRd
parse_search_results <- function(json_data) {
  num_found <- safe_extract(json_data, "num-found")
  if (is_absent(num_found)) {
    num_found <- 0L
  }

  results <- safe_extract(json_data, "expanded-result")
  if (is_absent(results)) {
    results <- safe_extract(json_data, "result")
  }
  if (is_absent(results) || !is.list(results)) {
    return(empty_search_result(num_found))
  }

  # A name field arrives as a string, or as a list whose first non-empty
  # element is the value.
  first_value <- function(value) {
    if (is_absent(value)) {
      return(NA_character_)
    }
    if (is.list(value)) {
      for (element in value) {
        if (!is_absent(element)) {
          return(as.character(element[[1]]))
        }
      }
      return(NA_character_)
    }
    as.character(value[[1]])
  }

  parsed <- lapply(results, function(item) {
    orcid_id <- extract_chr(item, "orcid-identifier", "path")
    if (is.na(orcid_id)) {
      orcid_id <- first_value(item[["orcid-id"]])
    }
    other_names <- item[["other-name"]]
    if (is.null(other_names)) {
      other_names <- item[["other-names"]]
    }
    if (is_absent(other_names)) {
      other_names <- character(0)
    }
    list(
      orcid_id = orcid_id,
      given_names = first_value(item[["given-names"]]),
      family_name = first_value(item[["family-names"]]),
      credit_name = first_value(item[["credit-name"]]),
      other_names = unlist(other_names, use.names = FALSE)
    )
  })

  result <- data.table::data.table(
    orcid_id = vapply(parsed, `[[`, character(1), "orcid_id"),
    given_names = vapply(parsed, `[[`, character(1), "given_names"),
    family_name = vapply(parsed, `[[`, character(1), "family_name"),
    credit_name = vapply(parsed, `[[`, character(1), "credit_name"),
    other_names = lapply(parsed, `[[`, "other_names")
  )
  attr(result, "found") <- as.integer(num_found)
  result
}
