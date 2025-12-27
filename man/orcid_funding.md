

# Retrieve funding records from ORCID

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches funding records for a given ORCID identifier from the ORCID
public API. Returns a structured data.table with funding details
including grant titles, funding organizations, amounts, and dates.

## Usage

<pre><code class='language-R'>orcid_funding(orcid_id, token = NULL)
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
<code>https://pub.orcid.org/v3.0/{orcid-id}/fundings</code>

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
Unique identifier for this funding record
</dd>
<dt>
title
</dt>
<dd>
Title of the funded project
</dd>
<dt>
type
</dt>
<dd>
Type of funding (e.g., grant, contract, award)
</dd>
<dt>
organization
</dt>
<dd>
Name of the funding organization
</dd>
<dt>
start_date
</dt>
<dd>
Funding start date (ISO format)
</dd>
<dt>
end_date
</dt>
<dd>
Funding end date (ISO format)
</dd>
<dt>
amount
</dt>
<dd>
Funding amount (if available)
</dd>
<dt>
currency
</dt>
<dd>
Currency code (e.g., USD, EUR)
</dd>
</dl>

Returns an empty data.table with the same structure if no funding
records are found.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_works</code>, <code>orcid_employments</code>,
<code>orcid_fetch_record</code>

## Examples

``` r
library("orcidtr")

# Fetch funding records for a public ORCID
funding <- orcid_funding("0000-0002-1825-0097")
print(funding)

# With authentication
Sys.setenv(ORCID_TOKEN = "your-token-here")
funding <- orcid_funding("0000-0002-1825-0097")
```
