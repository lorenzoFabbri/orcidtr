

# Retrieve complete ORCID record

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches all public data for a given ORCID identifier, including
employments, education, works, funding, and peer reviews. Returns a
named list of data.table objects.

## Usage

<pre><code class='language-R'>orcid_fetch_record(
  orcid_id,
  token = NULL,
  sections = c("employments", "educations", "works", "funding", "peer-reviews")
)
</code></pre>

## Arguments

<table role="presentation">
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="orcid_id">orcid_id</code>
</td>
<td>
Character string. A valid ORCID identifier in the format
XXXX-XXXX-XXXX-XXXX. Can also handle URLs like
https://orcid.org/XXXX-XXXX-XXXX-XXXX.
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="token">token</code>
</td>
<td>
Character string or NULL. Optional API token for authenticated requests.
If NULL (default), checks the ORCID_TOKEN environment variable. Most
public data is accessible without authentication.
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="sections">sections</code>
</td>
<td>
Character vector. Sections to fetch. Default is all available sections:
c("employments", "educations", "works", "funding", "peer-reviews"). You
can specify a subset to fetch only specific sections.
</td>
</tr>
</table>

## Details

This is a convenience function that calls individual API functions for
each section. Each section requires a separate API request.

To minimize API calls, specify only the sections you need using the
<code>sections</code> parameter.

## Value

A named list with the following elements (each a data.table):

<dl>
<dt>
employments
</dt>
<dd>
Employment history (see <code>orcid_employments</code>)
</dd>
<dt>
educations
</dt>
<dd>
Education history (see <code>orcid_educations</code>)
</dd>
<dt>
works
</dt>
<dd>
Works/publications (see <code>orcid_works</code>)
</dd>
<dt>
funding
</dt>
<dd>
Funding records (see <code>orcid_funding</code>)
</dd>
<dt>
peer_reviews
</dt>
<dd>
Peer review activities (see <code>orcid_peer_reviews</code>)
</dd>
</dl>

Empty data.tables are returned for sections with no data.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_fetch_many</code>, <code>orcid_employments</code>,
<code>orcid_works</code>

## Examples

``` r
library("orcidtr")

# Fetch complete record for a public ORCID
record <- orcid_fetch_record("0000-0002-1825-0097")
names(record)
record$works
record$employments

# Fetch only works and funding
record <- orcid_fetch_record(
  "0000-0002-1825-0097",
  sections = c("works", "funding")
)

# With authentication
Sys.setenv(ORCID_TOKEN = "your-token-here")
record <- orcid_fetch_record("0000-0002-1825-0097")
```
