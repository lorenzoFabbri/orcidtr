

# Retrieve records for multiple ORCID identifiers

[**Source code**](https://github.com/lorenzoFabbri/orcidtr/tree/main/R/#L)

## Description

Fetches data for multiple ORCID identifiers. This is a convenience
function that loops over a vector of ORCID iDs and fetches the specified
section(s) for each. Results are combined into a single data.table.

## Usage

<pre><code class='language-R'>orcid_fetch_many(
  orcid_ids,
  section = "works",
  token = NULL,
  stop_on_error = FALSE
)
</code></pre>

## Arguments

<table role="presentation">
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="orcid_ids">orcid_ids</code>
</td>
<td>
Character vector. Valid ORCID identifiers in the format
XXXX-XXXX-XXXX-XXXX. Can also handle URLs like
https://orcid.org/XXXX-XXXX-XXXX-XXXX.
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="section">section</code>
</td>
<td>
Character string. Section to fetch. One of: "employments", "educations",
"works", "funding", or "peer-reviews".
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="token">token</code>
</td>
<td>
Character string or NULL. Optional API token for authenticated requests.
If NULL (default), checks the ORCID_TOKEN environment variable.
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="stop_on_error">stop_on_error</code>
</td>
<td>
Logical. If TRUE, stops on the first error. If FALSE (default),
continues processing and returns results for successful requests,
issuing warnings for failures.
</td>
</tr>
</table>

## Details

This function makes one API request per ORCID identifier. Be mindful of
rate limits when fetching data for many ORCIDs.

The function validates each ORCID identifier and normalizes formats
before making requests.

For rate limit compliance, consider adding delays between large batches
or using authenticated requests which typically have higher rate limits.

## Value

A data.table combining results from all successful requests. The orcid
column identifies which ORCID each row belongs to.

## References

ORCID API Documentation:
<a href="https://info.orcid.org/documentation/api-tutorials/">https://info.orcid.org/documentation/api-tutorials/</a>

## See Also

<code>orcid_fetch_record</code>, <code>orcid_works</code>,
<code>orcid_employments</code>

## Examples

``` r
library("orcidtr")

# Fetch works for multiple ORCIDs
orcids <- c("0000-0002-1825-0097", "0000-0003-1419-2405")
works <- orcid_fetch_many(orcids, section = "works")
print(works)

# Fetch employments for multiple ORCIDs
employments <- orcid_fetch_many(orcids, section = "employments")

# Stop on first error
works <- orcid_fetch_many(orcids, section = "works", stop_on_error = TRUE)
```
