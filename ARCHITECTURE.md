# orcidtr Package Architecture

## Overview

The `orcidtr` package provides a CRAN-compliant R interface to the ORCiD public API. This document explains the package architecture, design decisions, and implementation details.

## Design Principles

### 1. CRAN Compliance

- No use of `setwd()`, `options()`, or `Sys.setenv()` in functions
- No interactive prompts or authentication flows
- Graceful handling of network failures
- Examples run in <5 seconds
- Passes `R CMD check --as-cran` on all platforms

### 2. Minimal Dependencies

- **httr2**: Modern HTTP client for API requests
- **data.table**: Fast, efficient data structures
- **jsonlite**: JSON parsing
- **No tidyverse dependencies** to keep package lightweight

### 3. Modern R Practices

- Native pipe (`|>`) instead of `magrittr`
- Fully qualified function calls (`pkg::fun()`)
- No `library()` or `require()` calls in package code
- data.table for all return values

### 4. Safety and Reliability

- No global state modifications
- No side effects
- Comprehensive input validation
- Informative error messages
- Rate limit respect

---

## Package Structure

```
orcidtr/
├── R/
│   ├── orcidtr-package.R           # Package documentation
│   ├── http.R                      # Core HTTP request handling
│   ├── utils.R                     # Validation and utility functions
│   ├── parsers.R                   # JSON to data.table conversion
│   ├── api-employments.R           # Employment endpoint
│   ├── api-educations.R            # Education endpoint
│   ├── api-works.R                 # Works/publications endpoint
│   ├── api-funding.R               # Funding endpoint
│   ├── api-peer-reviews.R          # Peer review endpoint
│   └── api-record.R                # Complete record & batch operations
├── tests/
│   └── testthat/
│       ├── test-utils.R            # Utility function tests
│       ├── test-parsers.R          # Parser function tests
│       └── test-api-integration.R  # Integration tests (network)
├── man/                            # Generated documentation
├── DESCRIPTION                     # Package metadata
├── NAMESPACE                       # Generated exports
├── README.Rmd                      # Source for README
├── DEVELOPMENT.md                  # Development workflow guide
└── ARCHITECTURE.md                 # This file
```

---

## Core Components

### 1. HTTP Layer (`R/http.R`)

**Purpose**: Handle all communication with the ORCiD API.

**Key Functions**:

- `orcid_request()`: Core request handler
  - Adds User-Agent header identifying the package
  - Handles authentication (optional ORCID_TOKEN)
  - Implements retry logic (3 attempts, 10 seconds max)
  - Provides detailed error messages
  - Parses JSON responses safely

**Error Handling**:

- 404: Record not found
- 401: Authentication failed
- 429: Rate limit exceeded
- 4xx/5xx: General HTTP errors

### 2. Validation Layer (`R/utils.R`)

**Purpose**: Validate inputs and provide utility functions.

**Key Functions**:

- `validate_orcid()`: Validates ORCiD format (XXXX-XXXX-XXXX-XXXX)
- `normalize_orcid()`: Handles various ORCiD formats (with/without dashes, URLs)
- `safe_extract()`: Safely extracts values from nested lists
- `orcid_date_to_iso()`: Converts ORCiD date objects to ISO strings
- `has_env_var()`: Checks for environment variables

**Validation Pattern**:

```
ORCiD formats accepted:
✓ 0000-0002-1825-0097
✓ 0000000218250097
✓ https://orcid.org/0000-0002-1825-0097
✓ 0000-0002-1825-009X (X in checksum)

ORCiD formats rejected:
✗ invalid
✗ 0000-0002-1825
✗ 0000-0002-1825-00971 (too long)
```

### 3. Parser Layer (`R/parsers.R`)

**Purpose**: Convert nested ORCiD JSON responses into normalized data.table objects.

**Key Functions**:

- `parse_employments()`: Extracts employment records
- `parse_educations()`: Extracts education records
- `parse_works()`: Extracts publication/work records
- `parse_funding()`: Extracts funding records
- `parse_peer_reviews()`: Extracts peer review records

**Design Pattern**:

```r
# All parsers follow this structure:
parse_SECTION <- function(json_data, orcid_id) {
  # 1. Extract relevant section from JSON
  # 2. Handle empty responses (return empty data.table with correct structure)
  # 3. Loop through records
  # 4. Extract fields using safe_extract()
  # 5. Convert to data.table
  # 6. Return consistent structure
}
```

**Consistency**:

- All parsers return data.table objects
- Empty results return data.table with correct column structure (0 rows)
- All include `orcid` column for joining
- All include `put_code` for unique identification

### 4. API Layer (`R/api-*.R`)

**Purpose**: User-facing functions for each ORCiD API endpoint.

**Pattern**:

```r
orcid_SECTION <- function(orcid_id, token = NULL) {
  # 1. Normalize ORCiD
  orcid_id <- normalize_orcid(orcid_id)

  # 2. Validate ORCiD
  validate_orcid(orcid_id, stop_on_error = TRUE)

  # 3. Make API request
  response <- orcid_request(
    endpoint = "SECTION",
    orcid_id = orcid_id,
    token = token
  )

  # 4. Parse and return
  parse_SECTION(response, orcid_id)
}
```

**Exported Functions**:

- `orcid_employments()`
- `orcid_educations()`
- `orcid_works()`
- `orcid_funding()`
- `orcid_peer_reviews()`
- `orcid_fetch_record()` (combines all sections)
- `orcid_fetch_many()` (batch processing)

### 5. Batch Operations (`R/api-record.R`)

**`orcid_fetch_record()`**:

- Fetches all sections for one ORCiD
- Returns named list of data.tables
- Optional section filtering
- Error handling per section (continues on failure)

**`orcid_fetch_many()`**:

- Fetches one section for multiple ORCIDs
- Returns combined data.table
- Validates all ORCIDs first
- Handles failures gracefully (warnings, not errors)
- Optional `stop_on_error` parameter

---

## API Endpoints Used

| Function               | Endpoint        | API URL                                           |
| ---------------------- | --------------- | ------------------------------------------------- |
| `orcid_employments()`  | `/employments`  | `https://pub.orcid.org/v3.0/{orcid}/employments`  |
| `orcid_educations()`   | `/educations`   | `https://pub.orcid.org/v3.0/{orcid}/educations`   |
| `orcid_works()`        | `/works`        | `https://pub.orcid.org/v3.0/{orcid}/works`        |
| `orcid_funding()`      | `/fundings`     | `https://pub.orcid.org/v3.0/{orcid}/fundings`     |
| `orcid_peer_reviews()` | `/peer-reviews` | `https://pub.orcid.org/v3.0/{orcid}/peer-reviews` |

### API Versioning

- Currently uses ORCiD API v3.0
- Version specified in `orcid_base_url()` function
- Can be overridden with `ORCID_API_URL` environment variable (for testing)

---

## Authentication

### Public API (Default)

- No token required
- Rate limit: ~24 requests/second
- Accesses public data only

### Authenticated API (Optional)

- Set `ORCID_TOKEN` environment variable
- Higher rate limits
- May access restricted data (if permissions granted)

**Best Practices**:

- Store token in `.Renviron` file
- Never commit tokens to git
- Document token requirement clearly
- Make authentication optional for all public data

---

## Testing Strategy

### Unit Tests (`test-utils.R`, `test-parsers.R`)

- Test validation functions
- Test parsers with mock data
- No network calls
- Fast execution

### Integration Tests (`test-api-integration.R`)

- Test real API calls
- `skip_on_cran()` to avoid network dependency
- `skip_if_offline()` helper
- Uses public test ORCiD: 0000-0002-1825-0097

### Test Organization

```r
test_that("description", {
  # Arrange
  input <- "0000-0002-1825-0097"

  # Act
  result <- normalize_orcid(input)

  # Assert
  expect_equal(result, "0000-0002-1825-0097")
})
```

---

## Performance Considerations

### Efficient Data Structures

- **data.table**: Fast aggregation and filtering
- **Direct JSON parsing**: No intermediate formats

### Minimal API Calls

- Batch operations combine results efficiently
- `orcid_fetch_record()` makes N calls for N sections
- No redundant requests

### Rate Limit Respect

- Document rate limits clearly
- Recommend delays for large batches
- Retry logic with backoff (built into httr2)

---

## CRAN Compliance Checklist

✅ **No global state modifications**

- No `setwd()`, `options()`, or `Sys.setenv()` in functions
- Environment variables only read via `Sys.getenv()`

✅ **No interactive prompts**

- All authentication via environment variables
- No `readline()` or similar

✅ **Proper User-Agent**

- Identifies package and version
- Includes GitHub URL

✅ **Network handling**

- Examples skip network calls with `\dontrun{}`
- Tests skip on CRAN with `skip_on_cran()`
- Graceful error handling

✅ **Documentation**

- All exported functions documented
- Examples provided
- API endpoints referenced

✅ **Platform compatibility**

- No platform-specific code
- Works on Windows, macOS, Linux

✅ **Dependencies**

- All imports declared in DESCRIPTION
- No suggests in required code paths

---

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for:

- Development workflow
- Testing procedures
- Documentation standards
- Pull request process

---

## References

- [ORCiD API Documentation](https://info.orcid.org/documentation/api-tutorials/)
- [ORCiD API Guide](https://info.orcid.org/documentation/integration-guide/)
- [httr2 Package](https://httr2.r-lib.org/)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
