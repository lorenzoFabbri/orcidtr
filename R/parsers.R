#' Generic parser for affiliation-group structures
#'
#' @description
#' Shared logic for parsing affiliation-based records (employments, educations, affiliations).
#' Reduces code duplication across multiple parsers.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#' @param summary_key Character string. The summary key to extract (e.g., "employment-summary").
#'
#' @return data.table with affiliation records.
#' @keywords internal
#' @noRd
parse_affiliation_group <- function(json_data, orcid_id, summary_key) {
  groups <- safe_extract(json_data, "affiliation-group")

  # Empty structure template
  empty_structure <- data.table::data.table(
    orcid = character(0),
    put_code = character(0),
    organization = character(0),
    department = character(0),
    role = character(0),
    start_date = character(0),
    end_date = character(0),
    city = character(0),
    region = character(0),
    country = character(0)
  )

  if (is.null(groups) || length(groups) == 0) {
    return(empty_structure)
  }

  # Process each group
  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "summaries")
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(item) {
      summary <- safe_extract(item, summary_key)
      if (is.null(summary)) {
        return(NULL)
      }

      list(
        orcid = orcid_id,
        put_code = as.character(safe_extract(summary, "put-code")),
        organization = safe_extract(summary, "organization", "name"),
        department = safe_extract(summary, "department-name"),
        role = safe_extract(summary, "role-title"),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date")),
        city = safe_extract(summary, "organization", "address", "city"),
        region = safe_extract(summary, "organization", "address", "region"),
        country = safe_extract(summary, "organization", "address", "country")
      )
    })
  })

  # Flatten and convert to data.table
  records_flat <- unlist(records, recursive = FALSE)
  records_flat <- records_flat[!vapply(records_flat, is.null, logical(1))]

  if (length(records_flat) == 0) {
    return(empty_structure)
  }

  data.table::rbindlist(records_flat, fill = TRUE)
}


#' Parse employment records from ORCID API
#'
#' @description
#' Converts employment JSON response to normalized data.table.
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
#' @description
#' Converts education JSON response to normalized data.table.
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


#' Parse works (publications) from ORCID API
#'
#' @description
#' Converts works JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with work records.
#' @keywords internal
#' @noRd
parse_works <- function(json_data, orcid_id) {
  groups <- safe_extract(json_data, "group")

  if (is.null(groups) || length(groups) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      title = character(0),
      type = character(0),
      publication_date = character(0),
      journal = character(0),
      doi = character(0),
      url = character(0)
    ))
  }

  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "work-summary")
    if (is.null(summaries) || length(summaries) == 0) {
      return(NULL)
    }

    # Only take the first work-summary to avoid duplicates
    # Multiple work-summaries in a group represent the same work from different sources
    summary <- summaries[[1]]

    if (is.null(summary)) {
      return(NULL)
    }

    # Extract title
    title <- safe_extract(summary, "title", "title", "value")

    # Extract DOI from external IDs
    doi <- NA_character_
    ext_ids <- safe_extract(summary, "external-ids", "external-id")
    if (!is.null(ext_ids) && is.list(ext_ids)) {
      for (ext_id in ext_ids) {
        if (
          !is.null(ext_id) &&
            identical(safe_extract(ext_id, "external-id-type"), "doi")
        ) {
          doi <- safe_extract(ext_id, "external-id-value")
          break
        }
      }
    }

    # Extract URL
    url <- safe_extract(summary, "url", "value")

    list(
      orcid = orcid_id,
      put_code = as.character(safe_extract(summary, "put-code")),
      title = title,
      type = safe_extract(summary, "type"),
      publication_date = orcid_date_to_iso(safe_extract(
        summary,
        "publication-date"
      )),
      journal = safe_extract(summary, "journal-title", "value"),
      doi = doi,
      url = url
    )
  })

  records_flat <- records[!vapply(records, is.null, logical(1))]

  if (length(records_flat) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      title = character(0),
      type = character(0),
      publication_date = character(0),
      journal = character(0),
      doi = character(0),
      url = character(0)
    ))
  }

  data.table::rbindlist(records_flat, fill = TRUE)
}


#' Parse funding records from ORCID API
#'
#' @description
#' Converts funding JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with funding records.
#' @keywords internal
#' @noRd
parse_funding <- function(json_data, orcid_id) {
  groups <- safe_extract(json_data, "group")

  if (is.null(groups) || length(groups) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      title = character(0),
      type = character(0),
      organization = character(0),
      start_date = character(0),
      end_date = character(0),
      amount = character(0),
      currency = character(0)
    ))
  }

  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "funding-summary")
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(summary) {
      if (is.null(summary)) {
        return(NULL)
      }

      # Extract amount info
      amount <- NA_character_
      currency <- NA_character_
      amount_obj <- safe_extract(summary, "amount")
      if (!is.null(amount_obj) && is.list(amount_obj)) {
        amount <- safe_extract(amount_obj, "value")
        currency <- safe_extract(amount_obj, "currency-code")
      }

      list(
        orcid = orcid_id,
        put_code = as.character(safe_extract(summary, "put-code")),
        title = safe_extract(summary, "title", "title", "value"),
        type = safe_extract(summary, "type"),
        organization = safe_extract(summary, "organization", "name"),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date")),
        amount = amount,
        currency = currency
      )
    })
  })

  records_flat <- unlist(records, recursive = FALSE)
  records_flat <- records_flat[!vapply(records_flat, is.null, logical(1))]

  if (length(records_flat) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      title = character(0),
      type = character(0),
      organization = character(0),
      start_date = character(0),
      end_date = character(0),
      amount = character(0),
      currency = character(0)
    ))
  }

  data.table::rbindlist(records_flat, fill = TRUE)
}


#' Parse peer review records from ORCID API
#'
#' @description
#' Converts peer review JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with peer review records.
#' @keywords internal
#' @noRd
parse_peer_reviews <- function(json_data, orcid_id) {
  groups <- safe_extract(json_data, "group")

  if (is.null(groups) || length(groups) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      reviewer_role = character(0),
      review_type = character(0),
      review_completion_date = character(0),
      organization = character(0)
    ))
  }

  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "peer-review-summary")
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(summary) {
      if (is.null(summary)) {
        return(NULL)
      }

      list(
        orcid = orcid_id,
        put_code = as.character(safe_extract(summary, "put-code")),
        reviewer_role = safe_extract(summary, "reviewer-role"),
        review_type = safe_extract(summary, "review-type"),
        review_completion_date = orcid_date_to_iso(
          safe_extract(summary, "completion-date")
        ),
        organization = safe_extract(summary, "convening-organization", "name")
      )
    })
  })

  records_flat <- unlist(records, recursive = FALSE)
  records_flat <- records_flat[!vapply(records_flat, is.null, logical(1))]

  if (length(records_flat) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      reviewer_role = character(0),
      review_type = character(0),
      review_completion_date = character(0),
      organization = character(0)
    ))
  }

  data.table::rbindlist(records_flat, fill = TRUE)
}


#' Parse affiliations (distinctions, invited positions, memberships, etc.)
#'
#' @description
#' Converts affiliation JSON response to normalized data.table.
#' Used for distinctions, invited-positions, memberships, qualifications, services.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with affiliation records.
#' @keywords internal
#' @noRd
parse_affiliations <- function(json_data, orcid_id) {
  groups <- safe_extract(json_data, "affiliation-group")

  # Check if groups is NA (not just NULL)
  if (
    is.null(groups) ||
      length(groups) == 0 ||
      (length(groups) == 1 && is.na(groups))
  ) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      organization = character(0),
      department = character(0),
      role = character(0),
      start_date = character(0),
      end_date = character(0),
      city = character(0),
      region = character(0),
      country = character(0)
    ))
  }

  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "summaries")
    if (is.null(summaries) || (length(summaries) == 1 && is.na(summaries))) {
      return(NULL)
    }

    lapply(summaries, function(item) {
      # Try different summary types
      summary <- safe_extract(item, "distinction-summary")
      if (is.null(summary) || (length(summary) == 1 && is.na(summary))) {
        summary <- safe_extract(item, "invited-position-summary")
      }
      if (is.null(summary) || (length(summary) == 1 && is.na(summary))) {
        summary <- safe_extract(item, "membership-summary")
      }
      if (is.null(summary) || (length(summary) == 1 && is.na(summary))) {
        summary <- safe_extract(item, "qualification-summary")
      }
      if (is.null(summary) || (length(summary) == 1 && is.na(summary))) {
        summary <- safe_extract(item, "service-summary")
      }
      if (is.null(summary) || (length(summary) == 1 && is.na(summary))) {
        return(NULL)
      }

      list(
        orcid = orcid_id,
        put_code = as.character(safe_extract(summary, "put-code")),
        organization = safe_extract(summary, "organization", "name"),
        department = safe_extract(summary, "department-name"),
        role = safe_extract(summary, "role-title"),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date")),
        city = safe_extract(summary, "organization", "address", "city"),
        region = safe_extract(summary, "organization", "address", "region"),
        country = safe_extract(summary, "organization", "address", "country")
      )
    })
  })

  records_flat <- unlist(records, recursive = FALSE)
  records_flat <- records_flat[!vapply(records_flat, is.null, logical(1))]

  if (length(records_flat) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      organization = character(0),
      department = character(0),
      role = character(0),
      start_date = character(0),
      end_date = character(0),
      city = character(0),
      region = character(0),
      country = character(0)
    ))
  }

  data.table::rbindlist(records_flat, fill = TRUE)
}


#' Parse research resources from ORCID API
#'
#' @description
#' Converts research resources JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with research resource records.
#' @keywords internal
#' @noRd
parse_research_resources <- function(json_data, orcid_id) {
  groups <- safe_extract(json_data, "group")

  if (is.null(groups) || length(groups) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      proposal_title = character(0),
      start_date = character(0),
      end_date = character(0)
    ))
  }

  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "research-resource-summary")
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(summary) {
      if (is.null(summary)) {
        return(NULL)
      }

      list(
        orcid = orcid_id,
        put_code = as.character(safe_extract(summary, "put-code")),
        proposal_title = safe_extract(
          summary,
          "proposal",
          "title",
          "title",
          "value"
        ),
        start_date = orcid_date_to_iso(safe_extract(summary, "start-date")),
        end_date = orcid_date_to_iso(safe_extract(summary, "end-date"))
      )
    })
  })

  records_flat <- unlist(records, recursive = FALSE)
  records_flat <- records_flat[!vapply(records_flat, is.null, logical(1))]

  if (length(records_flat) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      proposal_title = character(0),
      start_date = character(0),
      end_date = character(0)
    ))
  }

  data.table::rbindlist(records_flat, fill = TRUE)
}


#' Parse person/biographical data from ORCID API
#'
#' @description
#' Converts person endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with person data.
#' @keywords internal
#' @noRd
parse_person <- function(json_data, orcid_id) {
  # Extract name
  name <- safe_extract(json_data, "name")
  given_names <- safe_extract(name, "given-names", "value")
  family_name <- safe_extract(name, "family-name", "value")
  credit_name <- safe_extract(name, "credit-name", "value")

  # Extract biography
  biography <- safe_extract(json_data, "biography", "content")

  # Extract keywords
  keywords_list <- safe_extract(json_data, "keywords", "keyword")
  keywords <- NA_character_
  if (!is.null(keywords_list) && length(keywords_list) > 0) {
    kw <- sapply(keywords_list, function(kw) safe_extract(kw, "content"))
    kw <- kw[!is.na(kw)]
    if (length(kw) > 0) {
      keywords <- paste(kw, collapse = ", ")
    }
  }

  # Extract researcher URLs
  urls_list <- safe_extract(json_data, "researcher-urls", "researcher-url")
  urls <- NA_character_
  if (!is.null(urls_list) && length(urls_list) > 0) {
    url_values <- sapply(urls_list, function(u) safe_extract(u, "url", "value"))
    url_values <- url_values[!is.na(url_values)]
    if (length(url_values) > 0) {
      urls <- paste(url_values, collapse = ", ")
    }
  }

  # Extract country
  addresses <- safe_extract(json_data, "addresses", "address")
  country <- NA_character_
  if (!is.null(addresses) && length(addresses) > 0) {
    country <- safe_extract(addresses[[1]], "country", "value")
  }

  data.table::data.table(
    orcid = orcid_id,
    given_names = given_names,
    family_name = family_name,
    credit_name = credit_name,
    biography = biography,
    keywords = keywords,
    researcher_urls = urls,
    country = country
  )
}


#' Parse biography from ORCID API
#'
#' @description
#' Converts biography endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with biography data.
#' @keywords internal
#' @noRd
parse_bio <- function(json_data, orcid_id) {
  biography <- safe_extract(json_data, "content")
  visibility <- safe_extract(json_data, "visibility")

  data.table::data.table(
    orcid = orcid_id,
    biography = biography,
    visibility = visibility
  )
}


#' Parse keywords from ORCID API
#'
#' @description
#' Converts keywords endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with keywords.
#' @keywords internal
#' @noRd
parse_keywords <- function(json_data, orcid_id) {
  keywords_list <- safe_extract(json_data, "keyword")

  if (is.null(keywords_list) || length(keywords_list) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      keyword = character(0)
    ))
  }

  records <- lapply(keywords_list, function(kw) {
    list(
      orcid = orcid_id,
      put_code = as.character(safe_extract(kw, "put-code")),
      keyword = safe_extract(kw, "content")
    )
  })

  data.table::rbindlist(records, fill = TRUE)
}


#' Parse researcher URLs from ORCID API
#'
#' @description
#' Converts researcher-urls endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with researcher URLs.
#' @keywords internal
#' @noRd
parse_researcher_urls <- function(json_data, orcid_id) {
  urls_list <- safe_extract(json_data, "researcher-url")

  if (is.null(urls_list) || length(urls_list) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      url_name = character(0),
      url_value = character(0)
    ))
  }

  records <- lapply(urls_list, function(url) {
    list(
      orcid = orcid_id,
      put_code = as.character(safe_extract(url, "put-code")),
      url_name = safe_extract(url, "url-name"),
      url_value = safe_extract(url, "url", "value")
    )
  })

  data.table::rbindlist(records, fill = TRUE)
}


#' Parse external identifiers from ORCID API
#'
#' @description
#' Converts external-identifiers endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with external identifiers.
#' @keywords internal
#' @noRd
parse_external_identifiers <- function(json_data, orcid_id) {
  ids_list <- safe_extract(json_data, "external-identifier")

  if (is.null(ids_list) || length(ids_list) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      external_id_type = character(0),
      external_id_value = character(0),
      external_id_url = character(0)
    ))
  }

  records <- lapply(ids_list, function(ext_id) {
    list(
      orcid = orcid_id,
      put_code = as.character(safe_extract(ext_id, "put-code")),
      external_id_type = safe_extract(ext_id, "external-id-type"),
      external_id_value = safe_extract(ext_id, "external-id-value"),
      external_id_url = safe_extract(ext_id, "external-id-url", "value")
    )
  })

  data.table::rbindlist(records, fill = TRUE)
}


#' Parse other names from ORCID API
#'
#' @description
#' Converts other-names endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with other names.
#' @keywords internal
#' @noRd
parse_other_names <- function(json_data, orcid_id) {
  names_list <- safe_extract(json_data, "other-name")

  if (is.null(names_list) || length(names_list) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      other_name = character(0)
    ))
  }

  records <- lapply(names_list, function(name) {
    list(
      orcid = orcid_id,
      put_code = as.character(safe_extract(name, "put-code")),
      other_name = safe_extract(name, "content")
    )
  })

  data.table::rbindlist(records, fill = TRUE)
}


#' Parse address from ORCID API
#'
#' @description
#' Converts address endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with address data.
#' @keywords internal
#' @noRd
parse_address <- function(json_data, orcid_id) {
  addresses <- safe_extract(json_data, "address")

  if (is.null(addresses) || length(addresses) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      put_code = character(0),
      country = character(0)
    ))
  }

  records <- lapply(addresses, function(addr) {
    list(
      orcid = orcid_id,
      put_code = as.character(safe_extract(addr, "put-code")),
      country = safe_extract(addr, "country", "value")
    )
  })

  data.table::rbindlist(records, fill = TRUE)
}


#' Parse email from ORCID API
#'
#' @description
#' Converts email endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return data.table with email addresses.
#' @keywords internal
#' @noRd
parse_email <- function(json_data, orcid_id) {
  emails <- safe_extract(json_data, "email")

  if (is.null(emails) || length(emails) == 0) {
    return(data.table::data.table(
      orcid = character(0),
      email = character(0),
      verified = logical(0),
      primary = logical(0)
    ))
  }

  records <- lapply(emails, function(email) {
    list(
      orcid = orcid_id,
      email = safe_extract(email, "email"),
      verified = isTRUE(safe_extract(email, "verified")),
      primary = isTRUE(safe_extract(email, "primary"))
    )
  })

  data.table::rbindlist(records, fill = TRUE)
}


#' Parse activities summary from ORCID API
#'
#' @description
#' Converts activities endpoint JSON response to normalized named list.
#'
#' @param json_data List. Parsed JSON response from ORCID API.
#' @param orcid_id Character string. ORCID identifier (for reference).
#'
#' @return Named list with data.table for each activity type.
#' @keywords internal
#' @noRd
parse_activities <- function(json_data, orcid_id) {
  result <- list()

  # Parse distinctions
  distinctions_data <- safe_extract(json_data, "distinctions")
  result$distinctions <- if (!is.null(distinctions_data)) {
    parse_affiliations(distinctions_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse educations
  educations_data <- safe_extract(json_data, "educations")
  result$educations <- if (!is.null(educations_data)) {
    parse_educations(educations_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse employments
  employments_data <- safe_extract(json_data, "employments")
  result$employments <- if (!is.null(employments_data)) {
    parse_employments(employments_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse invited positions
  invited_data <- safe_extract(json_data, "invited-positions")
  result$invited_positions <- if (!is.null(invited_data)) {
    parse_affiliations(invited_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse memberships
  memberships_data <- safe_extract(json_data, "memberships")
  result$memberships <- if (!is.null(memberships_data)) {
    parse_affiliations(memberships_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse qualifications
  qualifications_data <- safe_extract(json_data, "qualifications")
  result$qualifications <- if (!is.null(qualifications_data)) {
    parse_affiliations(qualifications_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse services
  services_data <- safe_extract(json_data, "services")
  result$services <- if (!is.null(services_data)) {
    parse_affiliations(services_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse fundings
  fundings_data <- safe_extract(json_data, "fundings")
  result$fundings <- if (!is.null(fundings_data)) {
    parse_funding(fundings_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse peer reviews
  peer_reviews_data <- safe_extract(json_data, "peer-reviews")
  result$peer_reviews <- if (!is.null(peer_reviews_data)) {
    parse_peer_reviews(peer_reviews_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse research resources
  resources_data <- safe_extract(json_data, "research-resources")
  result$research_resources <- if (!is.null(resources_data)) {
    parse_research_resources(resources_data, orcid_id)
  } else {
    data.table::data.table()
  }

  # Parse works
  works_data <- safe_extract(json_data, "works")
  result$works <- if (!is.null(works_data)) {
    parse_works(works_data, orcid_id)
  } else {
    data.table::data.table()
  }

  result
}


#' Parse search results from ORCID API
#'
#' @description
#' Converts search endpoint JSON response to normalized data.table.
#'
#' @param json_data List. Parsed JSON response from ORCID search API.
#'
#' @return data.table with search results columns:
#'   orcid_id, given_names, family_name, credit_name, other_names.
#'   The 'found' attribute contains the total number of matches.
#' @keywords internal
#' @noRd
parse_search_results <- function(json_data) {
  # Extract total number of results
  num_found <- safe_extract(json_data, "num-found")
  if (is.null(num_found)) {
    num_found <- 0L
  }

  # Extract results array - use expanded-result for v3.0 API
  results <- safe_extract(json_data, "expanded-result")

  # Fall back to "result" if expanded-result doesn't exist (older API versions)
  if (is.null(results) || (length(results) == 1 && is.na(results))) {
    results <- safe_extract(json_data, "result")
  }

  # Handle empty results (safe_extract returns NA for null)
  if (
    is.null(results) ||
      length(results) == 0 ||
      (length(results) == 1 && is.na(results))
  ) {
    result <- data.table::data.table(
      orcid_id = character(0),
      given_names = character(0),
      family_name = character(0),
      credit_name = character(0),
      other_names = list()
    )
    attr(result, "found") <- as.integer(num_found)
    return(result)
  }

  # Parse each result
  parsed <- lapply(results, function(item) {
    # Extract ORCID identifier - handle both formats
    orcid_path <- safe_extract(item, "orcid-identifier", "path")
    if (is.null(orcid_path) || is.na(orcid_path)) {
      # Try direct orcid-id field (expanded-search format)
      orcid_path <- item[["orcid-id"]]
    }
    orcid_id <- if (!is.null(orcid_path) && !is.na(orcid_path)) {
      orcid_path
    } else {
      NA_character_
    }

    # Helper function to safely extract and convert to character
    extract_name_field <- function(field_name) {
      val <- item[[field_name]]
      if (is.null(val)) {
        return(NA_character_)
      }
      if (length(val) == 0) {
        return(NA_character_)
      }
      if (is.list(val)) {
        # If it's a list, try to get the first non-null element
        for (i in seq_along(val)) {
          if (!is.null(val[[i]]) && length(val[[i]]) > 0) {
            return(as.character(val[[i]]))
          }
        }
        return(NA_character_)
      }
      # Direct value
      return(as.character(val))
    }

    # Extract name fields
    given_names <- extract_name_field("given-names")
    family_name <- extract_name_field("family-names")
    credit_name <- extract_name_field("credit-name")

    # Extract other names
    other_names_val <- item[["other-names"]]
    if (is.null(other_names_val)) {
      # Try alternate field name
      other_names_val <- item[["other-name"]]
    }
    other_names <- if (
      !is.null(other_names_val) && length(other_names_val) > 0
    ) {
      if (is.list(other_names_val)) other_names_val else list(other_names_val)
    } else {
      list(character(0))
    }

    list(
      orcid_id = orcid_id,
      given_names = given_names,
      family_name = family_name,
      credit_name = credit_name,
      other_names = other_names
    )
  })

  # Combine into data.table
  result <- data.table::data.table(
    orcid_id = sapply(parsed, function(x) x$orcid_id),
    given_names = sapply(parsed, function(x) x$given_names),
    family_name = sapply(parsed, function(x) x$family_name),
    credit_name = sapply(parsed, function(x) x$credit_name),
    other_names = lapply(parsed, function(x) x$other_names)
  )

  # Add found attribute
  attr(result, "found") <- as.integer(num_found)

  result
}
