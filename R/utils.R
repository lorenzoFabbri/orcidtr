#' Validate ORCID identifier format
#'
#' @description
#' Checks if a string is a valid ORCID identifier. Valid ORCIDs follow the
#' pattern XXXX-XXXX-XXXX-XXXX where X is a digit, and the last character
#' can be a digit or X.
#'
#' @param orcid_id Character string to validate.
#' @param stop_on_error Logical. If TRUE, stops with an error for invalid IDs.
#'   If FALSE, returns FALSE for invalid IDs.
#'
#' @return Logical. TRUE if valid, FALSE if invalid (when stop_on_error = FALSE).
#' @keywords internal
#' @noRd
#'
#' @examples
#' \dontrun{
#' validate_orcid("0000-0002-1825-0097") # TRUE
#' validate_orcid("0000-0002-1825-009X") # TRUE
#' validate_orcid("invalid") # Error
#' }
validate_orcid <- function(orcid_id, stop_on_error = TRUE) {
  if (is.null(orcid_id) || length(orcid_id) == 0) {
    if (stop_on_error) {
      stop("ORCID identifier cannot be NULL or empty", call. = FALSE)
    }
    return(FALSE)
  }

  if (length(orcid_id) > 1) {
    if (stop_on_error) {
      stop("validate_orcid expects a single ORCID identifier", call. = FALSE)
    }
    return(FALSE)
  }

  if (!is.character(orcid_id)) {
    if (stop_on_error) {
      stop("ORCID identifier must be a character string", call. = FALSE)
    }
    return(FALSE)
  }

  # ORCID pattern: XXXX-XXXX-XXXX-XXXX where last char can be X
  pattern <- "^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$"

  is_valid <- grepl(pattern, orcid_id)

  if (!is_valid && stop_on_error) {
    stop(
      "Invalid ORCID format: '",
      orcid_id,
      "'. ",
      "Expected format: XXXX-XXXX-XXXX-XXXX (e.g., 0000-0002-1825-0097)",
      call. = FALSE
    )
  }

  is_valid
}


#' Normalize ORCID identifier
#'
#' @description
#' Ensures ORCID identifier has proper formatting with dashes.
#' Handles ORCIDs provided with or without dashes, and with or without
#' the https://orcid.org/ prefix.
#'
#' @param orcid_id Character string. ORCID identifier.
#'
#' @return Character string with normalized ORCID (XXXX-XXXX-XXXX-XXXX format).
#' @keywords internal
#' @noRd
#'
#' @examples
#' \dontrun{
#' normalize_orcid("0000000218250097") # "0000-0002-1825-0097"
#' normalize_orcid("https://orcid.org/0000-0002-1825-0097") # "0000-0002-1825-0097"
#' }
normalize_orcid <- function(orcid_id) {
  if (is.null(orcid_id) || length(orcid_id) != 1) {
    stop("normalize_orcid expects a single ORCID identifier", call. = FALSE)
  }

  # Remove URL prefix if present
  orcid_id <- gsub("^https?://orcid\\.org/", "", orcid_id, ignore.case = TRUE)

  # Remove all dashes
  clean_id <- gsub("-", "", orcid_id)

  # Check length
  if (nchar(clean_id) != 16) {
    stop(
      "Invalid ORCID length: '",
      orcid_id,
      "'. ",
      "Expected 16 characters (digits or X)",
      call. = FALSE
    )
  }

  # Add dashes
  formatted <- paste(
    substr(clean_id, 1, 4),
    substr(clean_id, 5, 8),
    substr(clean_id, 9, 12),
    substr(clean_id, 13, 16),
    sep = "-"
  )

  # Validate result
  validate_orcid(formatted, stop_on_error = TRUE)

  formatted
}


#' Extract value from nested list safely
#'
#' @description
#' Safely extracts a value from a nested list structure, returning NA if
#' the path doesn't exist.
#'
#' @param x List. Nested list structure.
#' @param ... Character strings. Path to value.
#'
#' @return Extracted value or NA if path doesn't exist.
#' @keywords internal
#' @noRd
safe_extract <- function(x, ...) {
  path <- list(...)
  result <- x

  for (key in path) {
    if (is.null(result) || !is.list(result) || !key %in% names(result)) {
      return(NA)
    }
    result <- result[[key]]
  }

  if (is.null(result)) {
    return(NA)
  }

  result
}


#' Convert ORCID date to ISO format
#'
#' @description
#' Converts ORCID API date objects (with year, month, day components)
#' to ISO date strings.
#'
#' @param date_obj List. Date object from ORCID API with year, month, day.
#'
#' @return Character string in ISO format (YYYY-MM-DD) or NA.
#' @keywords internal
#' @noRd
orcid_date_to_iso <- function(date_obj) {
  if (is.null(date_obj) || !is.list(date_obj)) {
    return(NA_character_)
  }

  year <- safe_extract(date_obj, "year", "value")
  month <- safe_extract(date_obj, "month", "value")
  day <- safe_extract(date_obj, "day", "value")

  if (is.na(year)) {
    return(NA_character_)
  }

  # Format with padding
  year_str <- sprintf("%04d", as.integer(year))

  if (is.na(month)) {
    return(year_str)
  }

  month_str <- sprintf("%02d", as.integer(month))

  if (is.na(day)) {
    return(paste0(year_str, "-", month_str))
  }

  day_str <- sprintf("%02d", as.integer(day))
  paste0(year_str, "-", month_str, "-", day_str)
}


#' Check if environment variable is set
#'
#' @description
#' Utility to check if an environment variable is set and non-empty.
#'
#' @param var Character string. Name of environment variable.
#'
#' @return Logical. TRUE if set and non-empty, FALSE otherwise.
#' @keywords internal
#' @noRd
has_env_var <- function(var) {
  val <- Sys.getenv(var, unset = "")
  nchar(val) > 0
}
