

# Retrieve education history from ORCID

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches education records for a given ORCID identifier from the ORCID
public API. Returns a structured data.table with education history
including institutions, degrees, departments, and dates.

## Usage

<pre><code class='language-R'>orcid_educations(orcid_id, token = NULL)
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
<code>https://pub.orcid.org/v3.0/{orcid-id}/educations</code>

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
Unique identifier for this education record
</dd>
<dt>
organization
</dt>
<dd>
Name of the educational institution
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
Degree or program name
</dd>
<dt>
start_date
</dt>
<dd>
Education start date (ISO format)
</dd>
<dt>
end_date
</dt>
<dd>
Education end date (ISO format)
</dd>
<dt>
city
</dt>
<dd>
City of institution
</dd>
<dt>
region
</dt>
<dd>
State/region of institution
</dd>
<dt>
country
</dt>
<dd>
Country of institution
</dd>
</dl>

Returns an empty data.table with the same structure if no education
records are found.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_employments</code>, <code>orcid_works</code>,
<code>orcid_fetch_record</code>

## Examples

``` r
library("orcidtr")

# Fetch education history for a public ORCID
edu <- orcid_educations("0000-0002-1825-0097")
print(edu)

# With authentication
Sys.setenv(ORCID_TOKEN = "your-token-here")
edu <- orcid_educations("0000-0002-1825-0097")
```
