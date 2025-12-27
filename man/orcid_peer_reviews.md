

# Retrieve peer review activities from ORCID

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches peer review records for a given ORCID identifier from the ORCID
public API. Returns a structured data.table with peer review activities
including reviewer roles, review types, and organizations.

## Usage

<pre><code class='language-R'>orcid_peer_reviews(orcid_id, token = NULL)
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
<code>https://pub.orcid.org/v3.0/{orcid-id}/peer-reviews</code>

Peer review activities can include journal article reviews, conference
paper reviews, grant reviews, and other forms of scholarly evaluation.

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
Unique identifier for this peer review record
</dd>
<dt>
reviewer_role
</dt>
<dd>
Role of the reviewer (e.g., reviewer, editor)
</dd>
<dt>
review_type
</dt>
<dd>
Type of review (e.g., review, evaluation)
</dd>
<dt>
review_completion_date
</dt>
<dd>
Date the review was completed (ISO format)
</dd>
<dt>
organization
</dt>
<dd>
Name of the convening organization (e.g., journal, conference)
</dd>
</dl>

Returns an empty data.table with the same structure if no peer review
records are found.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_works</code>, <code>orcid_funding</code>,
<code>orcid_fetch_record</code>

## Examples

``` r
library("orcidtr")

# Fetch peer review records for a public ORCID
reviews <- orcid_peer_reviews("0000-0002-1825-0097")
print(reviews)

# With authentication
Sys.setenv(ORCID_TOKEN = "your-token-here")
reviews <- orcid_peer_reviews("0000-0002-1825-0097")
```
