# orcidtr 0.1.0

## Breaking Changes (December 28, 2025)

### Authentication Behavior

- **IMPORTANT**: The package no longer automatically uses the `ORCID_TOKEN` environment variable for API requests
- **Reason**: The ORCID public API does NOT require authentication and actually rejects invalid tokens with 401 errors
- **Impact**: If you previously set `ORCID_TOKEN` and experienced authentication errors, you can now safely unset it
- **Migration**: If you need authentication (for rate limits or private data), pass the token explicitly: `orcid_works(id, token = "your-token")`
- Authentication is now truly optional as intended by ORCID's public API design

## Bug Fixes (December 28, 2025)

### API Status Check

- Fixed `orcid_ping()` to use `application/json` instead of `text/plain` Accept header
- Now properly parses JSON response and returns "OK" when API is healthy
- Resolves 406 (Not Acceptable) errors from the status endpoint

### Search Results

- Fixed empty search results returning 1 row of NA values instead of 0 rows
- `orcid_search()` and `orcid()` now correctly return empty data.table with 0 rows when no matches found
- `attr(result, "found")` still correctly shows 0 for total matches

### Parser Improvements

- Enhanced `parse_search_results()` to handle NA values from `safe_extract()` when JSON contains null
- Prevents creation of placeholder rows with NA values

## Documentation Improvements (December 28, 2025)

### Clarified Authentication

- Updated README and vignette to explicitly state authentication is **optional**
- Explained when tokens are actually needed (rate limits, private data access)
- Provided OAuth2 flow example for users who do need tokens
- Corrected misconceptions from rorcid documentation about token requirements

### Internal Documentation

- Updated `orcid_request()` documentation to reflect optional authentication
- Clarified that public API works without any token
- Improved error messages for authentication failures

## Test Suite (December 28, 2025)

- Removed `ORCID_TOKEN` checks from all test helper functions
- All 302 tests now pass without requiring any authentication
- Tests correctly handle both authenticated and unauthenticated scenarios

## Initial Release Features

### Biographical Data Functions

- `orcid_person()`: Fetch complete person/biographical data
- `orcid_bio()`: Retrieve biography text
- `orcid_keywords()`: Get researcher keywords
- `orcid_researcher_urls()`: Fetch researcher URLs
- `orcid_external_identifiers()`: Get external identifiers (Scopus, ResearcherID, etc.)
- `orcid_other_names()`: Retrieve alternative names
- `orcid_address()`: Get address/country information
- `orcid_email()`: Fetch email addresses (if public)

### Professional Activities Functions

- `orcid_distinctions()`: Fetch distinctions and honors
- `orcid_invited_positions()`: Get invited positions
- `orcid_memberships()`: Retrieve professional memberships
- `orcid_qualifications()`: Fetch qualifications
- `orcid_services()`: Get service activities
- `orcid_research_resources()`: Retrieve research resources

### Employment and Education

- `orcid_employments()`: Fetch employment history
- `orcid_educations()`: Retrieve education records

### Research Outputs

- `orcid_works()`: Get works/publications
- `orcid_funding()`: Fetch funding records
- `orcid_peer_reviews()`: Retrieve peer review activities

### Activities Summary

- `orcid_activities()`: Fetch all activities in one call (returns named list of all activity types)

### Search Functions

- `orcid()`: Flexible Solr query search of ORCID registry
- `orcid_search()`: User-friendly search with named parameters
- `orcid_doi()`: Search for ORCID records by DOI

### Batch Operations

- `orcid_fetch_record()`: Get complete ORCID record (supports all sections)
- `orcid_fetch_many()`: Batch fetch for multiple ORCIDs

### Utilities

- `orcid_ping()`: Check ORCID API status

## Technical Details

- Full ORCID API v3.0 support
- CRAN-compliant implementation
- Comprehensive test coverage (302 tests) with `skip_on_cran()` guards
- All functions return data.table objects for efficient data manipulation
- Complete roxygen2 documentation
- Built with modern httr2 package for HTTP requests
- No authentication required for public data access
- Optional token support for enhanced rate limits
