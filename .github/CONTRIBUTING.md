# Contributing to orcidtr

## Small fixes

You can fix a typo or a wording problem in the documentation directly on GitHub. Edit the roxygen comment in the `.R` file under `R/`, not the generated `.Rd` file under `man/`.

## Larger changes

Open an issue before starting a larger change, so we can agree that it is needed. For a bug, include a minimal [reprex](https://reprex.tidyverse.org/); it will also become the test for the fix.

To prepare a pull request:

1. Fork and clone the repository, for example with `usethis::create_from_github("lorenzoFabbri/orcidtr", fork = TRUE)`.
2. Install the development dependencies with `pak::local_install_dev_deps()` and check that `devtools::check()` passes before you change anything.
3. Create a branch, for example with `usethis::pr_init("brief-description")`.
4. Make the change with tests, and add a bullet to the top section of `NEWS.md` if users will notice it.
5. Push and open the pull request with `usethis::pr_push()`. Put `Fixes #<issue number>` in its description.

Code follows the [tidyverse style guide](https://style.tidyverse.org) as applied by [Air](https://posit-dev.github.io/air/); format only the code you change. Documentation uses [roxygen2](https://roxygen2.r-lib.org/) with Markdown, and tests use [testthat](https://testthat.r-lib.org/). `DEVELOPMENT.md` lists the commands.

## Code of conduct

The project has a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing you agree to follow it.
