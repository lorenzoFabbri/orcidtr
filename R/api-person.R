#' Retrieve complete person data from ORCID
#'
#' @description
#' Fetches comprehensive personal information including name, biography,
#' keywords, researcher URLs, and other public profile data from an ORCID record.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'   Most public data is accessible without authentication.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{given_names}{Given (first) name}
#'     \item{family_name}{Family (last) name}
#'     \item{credit_name}{Published/credit name (if provided)}
#'     \item{biography}{Biography text}
#'     \item{keywords}{Comma-separated research keywords}
#'     \item{researcher_urls}{Comma-separated professional URLs}
#'     \item{country}{Country of residence}
#'   }
#'   Returns a data.table with NA values for missing fields.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/person}
#'
#' This endpoint provides the most comprehensive biographical information in a
#' single request, including name, biography, keywords, URLs, addresses, emails,
#' and external identifiers.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_bio}}, \code{\link{orcid_keywords}}, \code{\link{orcid_researcher_urls}}
#'
#' @examples
#' \dontrun{
#' # Fetch complete person data
#' person <- orcid_person("0000-0002-1825-0097")
#' print(person)
#'
#' # Access specific fields
#' person$biography
#' person$keywords
#'
#' # With authentication
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' person <- orcid_person("0000-0002-1825-0097")
#' }
#'
#' @export
orcid_person <- function(orcid_id, token = NULL) {
  fetch_and_parse("person", orcid_id, parse_person, token)
}


#' Retrieve biography from ORCID
#'
#' @description
#' Fetches just the biography/about text for an ORCID record. This is a
#' simplified alternative to \code{\link{orcid_person}} when you only need
#' the biography text.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{biography}{Biography text}
#'     \item{visibility}{Visibility setting (public, limited, private)}
#'   }
#'   Returns a data.table with NA biography if not available.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/biography}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch biography only
#' bio <- orcid_bio("0000-0002-1825-0097")
#' print(bio$biography)
#' }
#'
#' @export
orcid_bio <- function(orcid_id, token = NULL) {
  fetch_and_parse("biography", orcid_id, parse_bio, token)
}


#' Retrieve keywords from ORCID
#'
#' @description
#' Fetches research keywords associated with an ORCID record. Keywords help
#' identify research areas and interests.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this keyword}
#'     \item{keyword}{Keyword text}
#'   }
#'   Returns an empty data.table with the same structure if no keywords
#'   are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/keywords}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch keywords
#' keywords <- orcid_keywords("0000-0002-1825-0097")
#' print(keywords)
#' }
#'
#' @export
orcid_keywords <- function(orcid_id, token = NULL) {
  fetch_and_parse("keywords", orcid_id, parse_keywords, token)
}


#' Retrieve researcher URLs from ORCID
#'
#' @description
#' Fetches professional and personal URLs associated with an ORCID record,
#' such as personal websites, institutional profiles, social media, etc.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this URL}
#'     \item{url_name}{Name/label for the URL}
#'     \item{url_value}{The actual URL}
#'   }
#'   Returns an empty data.table with the same structure if no URLs
#'   are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/researcher-urls}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}, \code{\link{orcid_external_identifiers}}
#'
#' @examples
#' \dontrun{
#' # Fetch researcher URLs
#' urls <- orcid_researcher_urls("0000-0002-1825-0097")
#' print(urls)
#' }
#'
#' @export
orcid_researcher_urls <- function(orcid_id, token = NULL) {
  fetch_and_parse("researcher-urls", orcid_id, parse_researcher_urls, token)
}


#' Retrieve external identifiers from ORCID
#'
#' @description
#' Fetches external identifier mappings for an ORCID record, such as Scopus
#' Author ID, ResearcherID, Loop profile, and other researcher identification
#' systems.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this external ID}
#'     \item{external_id_type}{Type of external identifier (e.g., "Scopus Author ID")}
#'     \item{external_id_value}{The identifier value}
#'     \item{external_id_url}{URL to the external profile (if available)}
#'   }
#'   Returns an empty data.table with the same structure if no external
#'   identifiers are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/external-identifiers}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch external identifiers
#' ext_ids <- orcid_external_identifiers("0000-0002-1825-0097")
#' print(ext_ids)
#' }
#'
#' @export
orcid_external_identifiers <- function(orcid_id, token = NULL) {
  fetch_and_parse(
    "external-identifiers",
    orcid_id,
    parse_external_identifiers,
    token
  )
}


#' Retrieve other names from ORCID
#'
#' @description
#' Fetches alternative names (also known as, published as, etc.) associated
#' with an ORCID record.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this name}
#'     \item{other_name}{Alternative name}
#'   }
#'   Returns an empty data.table with the same structure if no other names
#'   are found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/other-names}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch other names
#' other_names <- orcid_other_names("0000-0002-1825-0097")
#' print(other_names)
#' }
#'
#' @export
orcid_other_names <- function(orcid_id, token = NULL) {
  fetch_and_parse("other-names", orcid_id, parse_other_names, token)
}


#' Retrieve address information from ORCID
#'
#' @description
#' Fetches address/country information associated with an ORCID record.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. Optional API token for authenticated
#'   requests. If NULL (default), checks the ORCID_TOKEN environment variable.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this address}
#'     \item{country}{Country code}
#'   }
#'   Returns an empty data.table with the same structure if no address
#'   information is found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/address}
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch address information
#' address <- orcid_address("0000-0002-1825-0097")
#' print(address)
#' }
#'
#' @export
orcid_address <- function(orcid_id, token = NULL) {
  fetch_and_parse("address", orcid_id, parse_address, token)
}


#' Retrieve email information from ORCID
#'
#' @description
#' Fetches email addresses associated with an ORCID record. Note that email
#' addresses are typically private and require authentication to access.
#'
#' @param orcid_id Character string. A valid ORCID identifier in the format
#'   XXXX-XXXX-XXXX-XXXX. Can also handle URLs like https://orcid.org/XXXX-XXXX-XXXX-XXXX.
#' @param token Character string or NULL. API token for authenticated requests.
#'   If NULL (default), checks the ORCID_TOKEN environment variable. Email
#'   addresses usually require authentication.
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{email}{Email address}
#'     \item{primary}{Logical indicating if this is the primary email}
#'     \item{verified}{Logical indicating if the email is verified}
#'     \item{visibility}{Visibility setting}
#'   }
#'   Returns an empty data.table with the same structure if no emails
#'   are found or accessible.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/email}
#'
#' Email addresses are typically private and will only be returned if you have
#' appropriate authentication permissions.
#'
#' @references
#' ORCID API Documentation: \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' # Fetch email (requires authentication)
#' Sys.setenv(ORCID_TOKEN = "your-token-here")
#' email <- orcid_email("0000-0002-1825-0097")
#' print(email)
#' }
#'
#' @export
orcid_email <- function(orcid_id, token = NULL) {
  fetch_and_parse("email", orcid_id, parse_email, token)
}
