# orcidtr: Development Quick Reference

## Common R Package Tasks

**Document functions:**

```r
devtools::document()
```

**Build README.md from README.Rmd:**

```r
devtools::build_readme()
```

**Run all tests:**

```r
devtools::test()
```

**Check package:**

```r
devtools::check()
```

**Install package locally:**

```r
devtools::install()
```

**Build source tarball:**

```r
devtools::build()
```

**Update version:**
Edit `DESCRIPTION` file, then update `NEWS.md`.

**Tag release:**

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

**Check before commit:**

```r
devtools::document(); devtools::test(); devtools::check(); devtools::build_readme()
```

**CRAN submission (summary):**

1. Update version, NEWS.md, cran-comments.md
2. `devtools::check(cran = TRUE)`
3. `rhub::check_for_cran()`
4. `devtools::spell_check()`
5. `urlchecker::url_check()`
6. `devtools::build()`
7. `devtools::submit_cran()`

**Help:**

```r
?function_name
```

**Website docs:**

```r
altdoc::render_docs()
```

**Install from GitHub:**

```r
remotes::install_github("lorenzoFabbri/orcidtr")
```

See README.md for more details.
