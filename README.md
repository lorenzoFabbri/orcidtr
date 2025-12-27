
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

| Function | Description | API Endpoint |
|----|----|----|
| `orcid_employments()` | Employment history | `/employments` |
| `orcid_educations()` | Education records | `/educations` |
| `orcid_works()` | Publications, datasets, preprints | `/works` |
| `orcid_funding()` | Grants and funding | `/fundings` |
| `orcid_peer_reviews()` | Peer review activities | `/peer-reviews` |
| `orcid_fetch_record()` | All sections combined | Multiple endpoints |
| `orcid_fetch_many()` | Batch fetch for multiple ORCIDs | Multiple endpoints |

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
