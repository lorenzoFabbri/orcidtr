# Development

## Everyday commands

Run these from the package root in R:

```r
devtools::load_all()     # load the package
devtools::document()     # regenerate man/ and NAMESPACE from roxygen
devtools::test()         # run the tests
devtools::check()        # R CMD check
devtools::build_readme() # render README.md from README.Rmd
lintr::lint_package()    # lint
altdoc::render_docs()    # build the website in docs/
```

Format R code with `air format .` in the shell. Update local dependencies with `pak::local_install_dev_deps()`; the package has no lockfile, because `DESCRIPTION` and the CI matrix define what it supports.

Most tests call the live ORCID API. They are skipped on CRAN and when offline, so run `devtools::test()` online before a release.

## Release

1. Set the version in `DESCRIPTION` and add its section to the top of `NEWS.md`.
2. Run `devtools::document()`, `devtools::build_readme()`, `devtools::check()`, `urlchecker::url_check()` and `devtools::spell_check()`.
3. Commit, then tag and push: `git tag -a vX.Y.Z -m "orcidtr X.Y.Z"` and `git push origin main vX.Y.Z`.
4. Create the GitHub release with `gh release create vX.Y.Z --notes-file <notes>`; publishing it rebuilds the website.
5. For a CRAN release, update `cran-comments.md` and run `devtools::submit_cran()`, which also updates `CRAN-SUBMISSION`.
