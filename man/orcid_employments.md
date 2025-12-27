

# Retrieve employment history from ORCID

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches employment records for a given ORCID identifier from the ORCID
public API. Returns a structured data.table with employment history
including organization names, roles, departments, and dates.

## Usage

<pre><code class='language-R'>orcid_employments(orcid_id, token = NULL)
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
<code>https://pub.orcid.org/v3.0/{orcid-id}/employments</code>

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
Unique identifier for this employment record
</dd>
<dt>
organization
</dt>
<dd>
Name of the employing organization
</dd>
<dt>
department
</dt>
<dd>
Department name (if available)
</dd>
<dt>
role
</dt>
<dd>
Job title or role
</dd>
<dt>
start_date
</dt>
<dd>
Employment start date (ISO format)
</dd>
<dt>
end_date
</dt>
<dd>
Employment end date (ISO format, NA if current)
</dd>
<dt>
city
</dt>
<dd>
City of organization
</dd>
<dt>
region
</dt>
<dd>
State/region of organization
</dd>
<dt>
country
</dt>
<dd>
Country of organization
</dd>
</dl>

Returns an empty data.table with the same structure if no employment
records are found.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_educations</code>, <code>orcid_works</code>,
<code>orcid_fetch_record</code>

## Examples

``` r
library("orcidtr")

# Fetch employment history for a public ORCID
emp <- orcid_employments("0000-0002-1825-0097")
print(emp)

# With authentication
Sys.setenv(ORCID_TOKEN = "your-token-here")
emp <- orcid_employments("0000-0002-1825-0097")
```
