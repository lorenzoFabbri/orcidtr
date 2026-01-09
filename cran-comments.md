## R CMD check results

0 errors | 0 warnings | 1 note

- This is a new release.

## Test environments

- Local macOS install, R 4.5.2
- GitHub Actions (ubuntu-latest, windows-latest, macOS-latest): R-release, R-devel

## Package submission notes

This is the initial CRAN submission of `orcidtr` version 0.1.0, a modern replacement for the discontinued `rorcid` package.

### Purpose

Provides comprehensive access to the ORCID public API v3.0 for retrieving researcher profiles, publications, affiliations, and other scholarly metadata. All functions return structured data.table objects for efficient data analysis.

### Authentication clarification

The package documentation clearly states that authentication is **optional** for the ORCID public API:

- Public data is fully accessible without any token
- Authentication tokens are only needed for higher rate limits or accessing private data (with granted permissions)
- This differs from some historical documentation that suggested tokens were required

The package does not automatically use environment variables for authentication to avoid issues with the public API rejecting invalid tokens.

### CRAN compliance

- All examples are wrapped in `\dontrun{}` as they require network access
- All tests use `skip_on_cran()` to avoid network-dependent tests on CRAN servers
- No external dependencies beyond standard CRAN packages
- Full documentation for all exported functions
- Package passes R CMD check with no errors or warnings

### Key features

- **27 exported functions** covering all ORCID API v3.0 endpoints
- Biographical data: person info, bio, keywords, URLs, identifiers
- Professional activities: employments, education, distinctions, memberships, services
- Research outputs: works/publications, funding, peer reviews
- Search capabilities: flexible query interface and DOI-based search
- Batch operations for multiple ORCID records
- Comprehensive test suite with 302 passing tests (all skipped on CRAN)

### Comparison to rorcid

This package provides a complete replacement for `rorcid` which was removed from CRAN:

- Modern httr2 instead of legacy httr
- No authentication required for public data (rorcid documentation was unclear on this)
- Complete API v3.0 coverage
- Returns data.table instead of lists for better performance
- Simplified, consistent API design

The package is ready for production use and has been tested extensively against the live ORCID API.
