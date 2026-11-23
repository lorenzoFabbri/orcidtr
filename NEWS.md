# orcidtr 0.2.0

## Breaking changes

- `orcid()` and `orcid_search()` no longer take `...`. The argument was documented as passing extra parameters to the API but was ignored, so a misspelled argument such as `orcid_search(given_names = "John")` silently searched without that criterion. It now fails with "unused argument".
- The `other_names` list column of search results holds a character vector per row instead of a list.

## Bug fixes

- `orcid_search()` quotes values that contain spaces or slashes. Before, `affiliation_org = "Stanford University"` sent `affiliation-org-name:Stanford University`, which Solr reads as "Stanford" in the affiliation field or "University" anywhere: 8.5 million matches instead of about 33,000.
- Parsers return a zero-row table with the documented columns when the response lacks the expected list. Before, a missing key produced one row of `NA` values.
- A field missing from every row is now a character column of `NA`, not a logical one, so results bind cleanly across records.
- `orcid_activities()` returns each missing section with its usual columns rather than a table with no columns.
- `orcid()`, `orcid_search()` and `orcid_doi()` no longer read the `ORCID_TOKEN` environment variable. This was the last code path that still did, contrary to the 0.1.0 notes, so a stale token in `.Renviron` made every search fail with a 401 while the record endpoints worked.
- Search errors now report 404, 401, 429 and 503 responses with the same messages as the record functions, and a 503 is described as a possible rate-limit response.
- `orcid()` checks that `query` is a single string and that `rows` and `start` are whole numbers.

## Documentation

- The documentation no longer says that a token raises the rate limit or gives access to private data. ORCID's public API serves only public data, and a `/read-public` token raises the daily read quota (from 25,000 reads per IP address to 100,000 per client) while the rate stays at 12 requests a second.
- Examples that returned nothing now work: `digital-object-ids:10.1371/*` needs quotes, and `orcid_search()` takes `given_name`, not `given_names`.
- The vignette named the wrong people for two example iDs; `0000-0002-1825-0097` is ORCID's fictitious demonstration record and `0000-0003-1419-2405` belongs to Martin Fenner.
- `orcid_email()` no longer lists a `visibility` column it never returned, and its help no longer says a token reveals private addresses.
- `Title` and `Description` quote software and API names and cite the ORCID API documentation, following CRAN's style requirements.

# orcidtr 0.1.0

First CRAN release. orcidtr reads the ORCID public API (version 3.0) and returns data.table objects:

- one function per record section: `orcid_employments()`, `orcid_educations()`, `orcid_distinctions()`, `orcid_invited_positions()`, `orcid_memberships()`, `orcid_qualifications()`, `orcid_services()`, `orcid_research_resources()`, `orcid_works()`, `orcid_funding()`, `orcid_peer_reviews()`, `orcid_person()`, `orcid_bio()`, `orcid_keywords()`, `orcid_researcher_urls()`, `orcid_external_identifiers()`, `orcid_other_names()`, `orcid_address()` and `orcid_email()`;
- `orcid_activities()` for summaries of every activity section in one request;
- `orcid_fetch_record()` and `orcid_fetch_many()` for several sections of one record, or one section of several records;
- `orcid()`, `orcid_search()` and `orcid_doi()` to search the registry;
- `orcid_ping()` to check that the API is up.

A token is optional and is never read from the environment, because the public API rejects an invalid token even though it needs none.
