#' Retrieve complete person data from ORCID
#'
#' @description
#' Fetches comprehensive personal information including name, biography,
#' keywords, researcher URLs, and other public profile data from an ORCID
#' record.
#'
#' @inheritParams orcid_works
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
#'     \item{country}{Two-letter ISO country code of the first listed address}
#'   }
#'   Returns a data.table with NA values for missing fields.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/person}
#'
#' The function condenses the person section into one row. Keywords and
#' researcher URLs are collapsed into comma-separated strings and only the
#' first address is kept; use [orcid_keywords()], [orcid_researcher_urls()] and
#' [orcid_address()] for one row per item, and [orcid_email()] and
#' [orcid_external_identifiers()] for the parts this summary leaves out.
#'
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_bio}}, \code{\link{orcid_keywords}},
#' \code{\link{orcid_researcher_urls}}
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
#' # With an explicit token
#' person <- orcid_person("0000-0002-1825-0097", token = "your-token-here")
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
#' @inheritParams orcid_works
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
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
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
#' @inheritParams orcid_works
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
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
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
#' @inheritParams orcid_works
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
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
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
#' @inheritParams orcid_works
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this external ID}
#'     \item{external_id_type}{Type of external identifier (e.g., "Scopus Author
#'     ID")}
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
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
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
#' @inheritParams orcid_works
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
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
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
#' @inheritParams orcid_works
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{put_code}{Unique identifier for this address}
#'     \item{country}{Two-letter ISO country code}
#'   }
#'   Returns an empty data.table with the same structure if no address
#'   information is found.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/address}
#'
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
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
#' Fetches the email addresses that the record holder has made public. Most
#' researchers keep their email private, so the result is usually empty.
#'
#' @inheritParams orcid_works
#'
#' @return A data.table with the following columns:
#'   \describe{
#'     \item{orcid}{ORCID identifier}
#'     \item{email}{Email address}
#'     \item{verified}{Logical; whether ORCID has verified the address}
#'     \item{primary}{Logical; whether this is the primary address}
#'   }
#'   Returns an empty data.table with the same structure if no email is
#'   public.
#'
#' @details
#' This function queries the ORCID public API endpoint:
#' \code{https://pub.orcid.org/v3.0/{orcid-id}/email}
#'
#' The public API returns only public data, with or without a token. Reading
#' an email with limited visibility needs the researcher's permission through
#' the Member API, which this package does not use.
#'
#' @references
#' ORCID API Documentation:
#' \url{https://info.orcid.org/documentation/api-tutorials/}
#'
#' @seealso
#' \code{\link{orcid_person}}
#'
#' @examples
#' \dontrun{
#' email <- orcid_email("0000-0002-1825-0097")
#' print(email)
#' }
#'
#' @export
orcid_email <- function(orcid_id, token = NULL) {
  fetch_and_parse("email", orcid_id, parse_email, token)
}
