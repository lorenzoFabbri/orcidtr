
<!-- README.md is generated from README.Rmd. Please edit that file -->

# orcidtr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/orcidtr)](https://CRAN.R-project.org/package=orcidtr)
[![R-CMD-check](https://github.com/lorenzoFabbri/orcidtr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lorenzoFabbri/orcidtr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

**orcidtr** provides a modern, CRAN-compliant R interface to the [ORCiD
public API](https://info.orcid.org/documentation/api-tutorials/). It
replaces the discontinued `rorcid` package with a streamlined
implementation that:

- Fetches **all available public data** from ORCiD records
- Returns structured **data.table** objects for easy manipulation
- Requires **no authentication** for public data (optional token
  support)
- Fully complies with **CRAN policies** and best practices

### What is ORCiD?

[ORCiD](https://orcid.org) (Open Researcher and Contributor ID) is a
persistent digital identifier that distinguishes individual researchers
and supports automated linkages between researchers and their
professional activities. An ORCiD record can contain employment history,
education, publications, funding, peer review activities, and more.

## Installation

Install from CRAN (when available):

``` r
install.packages("orcidtr")
```

Or install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("lorenzoFabbri/orcidtr")
```

## Quick Start

### Basic Usage (No Authentication Required)

``` r
# Fetch employment history
employments <- orcidtr::orcid_employments("0000-0002-1825-0097")
print(employments)

# Fetch publications/works
works <- orcidtr::orcid_works("0000-0002-1825-0097")
print(works)

# Fetch education records
education <- orcidtr::orcid_educations("0000-0002-1825-0097")

# Fetch funding information
funding <- orcidtr::orcid_funding("0000-0002-1825-0097")

# Fetch peer review activities
reviews <- orcidtr::orcid_peer_reviews("0000-0002-1825-0097")

# Fetch biographical data
person <- orcidtr::orcid_person("0000-0002-1825-0097")
bio <- orcidtr::orcid_bio("0000-0002-1825-0097")
keywords <- orcidtr::orcid_keywords("0000-0002-1825-0097")

# Fetch professional activities
distinctions <- orcidtr::orcid_distinctions("0000-0002-1825-0097")
memberships <- orcidtr::orcid_memberships("0000-0002-1825-0097")
```

### Search the ORCID Registry

``` r
# Search by name
results <- orcidtr::orcid_search(
  family_name = "Fabbri",
  given_names = "Lorenzo"
)

# Search by affiliation
results <- orcidtr::orcid_search(affiliation_org = "Stanford University")

# Search by DOI
results <- orcidtr::orcid_doi("10.1371/journal.pone.0001543")

# Advanced Solr query
results <- orcidtr::orcid("family-name:Smith AND affiliation-org-name:MIT")
```

### Fetch Complete Record

``` r
# Get all sections at once
record <- orcidtr::orcid_fetch_record("0000-0002-1825-0097")
names(record)

# Access individual sections
record$works
record$employments

# Fetch only specific sections
record <- orcidtr::orcid_fetch_record(
  "0000-0002-1825-0097",
  sections = c("works", "employments")
)
```

### Batch Processing

``` r
# Fetch works for multiple researchers
orcids <- c("0000-0002-1825-0097", "0000-0003-1419-2405", "0000-0002-9079-593X")
all_works <- orcidtr::orcid_fetch_many(orcids, section = "works")

# Filter using data.table syntax
all_works[type == "journal-article" & !is.na(doi)]
```

## Authentication (Optional)

Most public ORCiD data is accessible without authentication. However,
you can optionally use an API token for:

- Higher rate limits
- Access to private/restricted data (if granted permissions)

### Setup

1.  Register for ORCiD API credentials at
    <https://orcid.org/developer-tools>
2.  Get your API token (public client credentials)
3.  Set the environment variable:

``` r
# In your .Renviron file (recommended)
ORCID_TOKEN <- your - token - here

# Or set temporarily in R session
Sys.setenv(ORCID_TOKEN = "your-token-here")
```

The package will automatically detect and use the token. You can also
pass tokens explicitly:

``` r
works <- orcidtr::orcid_works("0000-0002-1825-0097", token = "your-token")
```

## Supported Data Types

### Employment and Education

| Function              | Description        | API Endpoint   |
|-----------------------|--------------------|----------------|
| `orcid_employments()` | Employment history | `/employments` |
| `orcid_educations()`  | Education records  | `/educations`  |

### Professional Activities

| Function | Description | API Endpoint |
|----|----|----|
| `orcid_distinctions()` | Distinctions and honors | `/distinctions` |
| `orcid_invited_positions()` | Invited positions | `/invited-positions` |
| `orcid_memberships()` | Professional memberships | `/memberships` |
| `orcid_qualifications()` | Qualifications | `/qualifications` |
| `orcid_services()` | Service activities | `/services` |
| `orcid_research_resources()` | Research resources | `/research-resources` |

### Works and Activities

| Function               | Description                       | API Endpoint    |
|------------------------|-----------------------------------|-----------------|
| `orcid_works()`        | Publications, datasets, preprints | `/works`        |
| `orcid_funding()`      | Grants and funding                | `/fundings`     |
| `orcid_peer_reviews()` | Peer review activities            | `/peer-reviews` |
| `orcid_activities()`   | All activities in one call        | `/activities`   |

### Biographical Data

| Function | Description | API Endpoint |
|----|----|----|
| `orcid_person()` | Complete person data | `/person` |
| `orcid_bio()` | Biography text | `/biography` |
| `orcid_keywords()` | Researcher keywords | `/keywords` |
| `orcid_researcher_urls()` | Researcher URLs | `/researcher-urls` |
| `orcid_external_identifiers()` | External IDs (Scopus, etc.) | `/external-identifiers` |
| `orcid_other_names()` | Alternative names | `/other-names` |
| `orcid_address()` | Address/country | `/address` |
| `orcid_email()` | Email addresses | `/email` |

### Search Functions

| Function         | Description                | API Endpoint |
|------------------|----------------------------|--------------|
| `orcid()`        | Flexible Solr query search | `/search`    |
| `orcid_search()` | User-friendly named search | `/search`    |
| `orcid_doi()`    | Search by DOI              | `/search`    |

### Utilities

| Function               | Description                     | API Endpoint       |
|------------------------|---------------------------------|--------------------|
| `orcid_fetch_record()` | Fetch complete record           | Multiple endpoints |
| `orcid_fetch_many()`   | Batch fetch for multiple ORCIDs | Multiple endpoints |
| `orcid_ping()`         | Check API status                | Base URL           |

## Data Structure

All functions return **data.table** objects with consistent structure:

``` r
works <- orcidtr::orcid_works("0000-0002-1825-0097")
str(works)
```

## Rate Limits and Best Practices

- **Public API**: ~24 requests per second
- **Authenticated**: Higher limits (check ORCiD documentation)
- Add delays for large batch operations: `Sys.sleep(0.1)` between
  requests
- Use `orcid_fetch_many()` for efficient batch processing
- Cache results when possible
- Handle errors gracefully with `tryCatch()`

## Contributing

Contributions are welcome! Please see the
[DEVELOPMENT.md](DEVELOPMENT.md) file for:

- Development workflow
- Package building and testing
- Documentation guidelines
- Contribution standards

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## License

MIT © Lorenzo Fabbri

## Acknowledgments

- ORCiD for providing the public API
- The `rorcid` package authors for pioneering ORCiD integration in R
- The R community for feedback and contributions
