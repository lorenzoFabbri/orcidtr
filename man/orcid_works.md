

# Retrieve works (publications) from ORCID

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches work records (publications, datasets, preprints, etc.) for a
given ORCID identifier from the ORCID public API. Returns a structured
data.table with work details including titles, types, DOIs, and
publication dates.

## Usage

<pre><code class='language-R'>orcid_works(orcid_id, token = NULL)
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
</table>

## Details

This function queries the ORCID public API endpoint:
<code>https://pub.orcid.org/v3.0/{orcid-id}/works</code>

Works can include journal articles, books, datasets, conference papers,
preprints, posters, and other scholarly outputs. The type field
indicates the specific category of each work.

The function respects ORCID API rate limits and includes appropriate
User-Agent headers identifying the orcidtr package.

## Value

A data.table with the following columns:

<dl>
<dt>
orcid
</dt>
<dd>
ORCID identifier
</dd>
<dt>
put_code
</dt>
<dd>
Unique identifier for this work record
</dd>
<dt>
title
</dt>
<dd>
Title of the work
</dd>
<dt>
type
</dt>
<dd>
Type of work (e.g., journal-article, dataset, preprint)
</dd>
<dt>
publication_date
</dt>
<dd>
Publication date (ISO format)
</dd>
<dt>
journal
</dt>
<dd>
Journal or venue name (if available)
</dd>
<dt>
doi
</dt>
<dd>
Digital Object Identifier (if available)
</dd>
<dt>
url
</dt>
<dd>
URL to the work (if available)
</dd>
</dl>

Returns an empty data.table with the same structure if no works are
found.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_employments</code>, <code>orcid_funding</code>,
<code>orcid_fetch_record</code>

## Examples

``` r
library("orcidtr")

# Fetch works for a public ORCID
works <- orcid_works("0000-0002-1825-0097")
print(works)

# Filter by type
articles <- works[type == "journal-article"]
datasets <- works[type == "data-set"]

# With authentication
Sys.setenv(ORCID_TOKEN = "your-token-here")
works <- orcid_works("0000-0002-1825-0097")
```
