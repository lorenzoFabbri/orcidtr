## R CMD check results

0 errors | 0 warnings | 0 notes

The local check also reports that it skipped HTML validation of the manual because the installed HTML Tidy is too old; that note concerns the check machine, not the package.

## Test environments

- Local macOS (aarch64), R 4.6.2
- GitHub Actions: macOS and Windows on R release; Windows on R oldrel-4; Ubuntu on R devel, release and oldrel-1 to oldrel-4

## Submission notes

This is an update from 0.1.0. It fixes search queries for values that contain spaces, makes the parsers return typed empty tables when a response lacks a section, and removes an ignored `...` argument from `orcid()` and `orcid_search()`. `NEWS.md` lists the changes.

Every example is in `\dontrun{}` and every test that calls the ORCID API is skipped on CRAN, because both need network access.
