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
  # Extract affiliation groups
  groups <- safe_extract(json_data, "affiliation-group")

  if (is.null(groups) || length(groups) == 0) {
    # Return empty data.table with correct structure
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

  # Process each group
  records <- lapply(groups, function(group) {
    summaries <- safe_extract(group, "summaries")
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(item) {
      summary <- safe_extract(item, "employment-summary")
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
  groups <- safe_extract(json_data, "affiliation-group")

  if (is.null(groups) || length(groups) == 0) {
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
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(item) {
      summary <- safe_extract(item, "education-summary")
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
    if (is.null(summaries)) {
      return(NULL)
    }

    lapply(summaries, function(summary) {
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
  })

  records_flat <- unlist(records, recursive = FALSE)
  records_flat <- records_flat[!vapply(records_flat, is.null, logical(1))]

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
