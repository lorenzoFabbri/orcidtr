
# orcidtr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- [![CRAN
status](https://www.r-pkg.org/badges/version/orcidtr)](https://CRAN.R-project.org/package=orcidtr) -->

[![R-CMD-check](https://github.com/lorenzoFabbri/orcidtr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lorenzoFabbri/orcidtr/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/lorenzoFabbri/orcidtr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/lorenzoFabbri/orcidtr)
[![Buy Me a
Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=☕&slug=epilorenzo&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/epilorenzo)

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

**Important:** The ORCID public API allows unauthenticated read access
to all public data. Authentication is entirely optional and only needed
for:

- **Higher rate limits**: Authenticated requests have more generous rate
  limits
- **Private data access**: If you’ve been granted permission to access
  restricted/private information

### Why Authentication is Optional

Unlike the rorcid package documentation might suggest, the ORCID
**public API** (pub.orcid.org) does NOT require authentication for
reading public records. The token mentioned in rorcid guides is for
increasing rate limits, not for basic access. This package works
perfectly fine without any token for typical use cases.

### When You Might Want a Token

You should consider getting a token if you:

- Need to make many requests in a short time (\>24 requests/second
  sustained)
- Are building an application with many users
- Need to access restricted data you’ve been granted permission to view

### How to Get a Token (If Needed)

1.  Register for ORCID API credentials at
    <https://orcid.org/developer-tools>
2.  Click “Register for the free ORCID public API”
3.  Fill in your application details and agree to terms
4.  Copy your Client ID and Client Secret
5.  Exchange them for an access token:

``` r
# Use your credentials to get a token
library(httr2)
resp <- request("https://orcid.org/oauth/token") |>
  req_headers(
    Accept = "application/json",
    `Content-Type` = "application/x-www-form-urlencoded"
  ) |>
  req_body_form(
    grant_type = "client_credentials",
    scope = "/read-public",
    client_id = "YOUR-CLIENT-ID",
    client_secret = "YOUR-CLIENT-SECRET"
  ) |>
  req_perform()

token_data <- resp_body_json(resp)
token <- token_data$access_token
```

6.  Set the environment variable:

``` r
# In your .Renviron file (recommended for persistent use)
ORCID_TOKEN <- "your-token-here"

# Or set temporarily in R session
Sys.setenv(ORCID_TOKEN = "your-token-here")
```

**Note:** The package will automatically use the `ORCID_TOKEN`
environment variable if it’s set. For the public API, this is purely
optional and most users can skip this entire section.

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

## License

MIT © Lorenzo Fabbri

## Acknowledgments

- ORCiD for providing the public API
- The `rorcid` package authors for leading ORCiD integration in R
- The R community for feedback and contributions
