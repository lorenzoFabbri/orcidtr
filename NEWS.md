# orcidtr 0.0.1 (development version)

## New Features

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

### Activities Summary

- `orcid_activities()`: Fetch all activities in one call (returns named list of all activity types)

### Search Functions

- `orcid()`: Flexible Solr query search of ORCID registry
- `orcid_search()`: User-friendly search with named parameters
- `orcid_doi()`: Search for ORCID records by DOI

### Utilities

- `orcid_ping()`: Check ORCID API status

### Enhancements

- `orcid_fetch_record()`: Now supports all new sections (biographical data, professional activities)
- `orcid_fetch_many()`: Extended to support new affiliation types

## Initial Release Features

- `orcid_employments()`: Fetch employment history
- `orcid_educations()`: Retrieve education records
- `orcid_works()`: Get works/publications
- `orcid_funding()`: Fetch funding records
- `orcid_peer_reviews()`: Retrieve peer review activities
- `orcid_fetch_record()`: Get complete ORCID record
- `orcid_fetch_many()`: Batch fetch for multiple ORCIDs

## Technical Details

- Full ORCID API v3.0 support
- CRAN-compliant implementation
- Comprehensive test coverage with `skip_on_cran()` guards
- All functions return data.table objects for efficient data manipulation
- Complete roxygen2 documentation
- No function overlap with archived rorcid package
