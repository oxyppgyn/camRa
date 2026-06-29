
<!-- README.md is generated from README.Rmd. Please edit that file -->

# camRa

**This package is currently in pre-release. Information such as most
Vignettes and official tests built for the package are currently
missing.**

*camRa* is an R package aimed at providing utilities for managing and
manipulating camera trap-related data. *CamRa* includes utilities to
help with obtaining data from the [Living Library of Alexandria
(LILA)](https://lila.science), summarizing and updating
MegaDetector/SpeciesNet detection files, and other general utilities for
camera trap image data.

## Current Functionality

- Getting info on LILA datasets and downloading images from LILA.
- Filtering, updating/merging classification names, converting from JSON
  to flat tables, easily grabbing values from JSON files for
  MegaDetector/SpeciesNet data.
- A easy-to-use optical character recognition (OCR) implementation to
  extract text (such as temperature or date-time) from camera trap
  images.

## Planned Functionality

- Expanded manipulation of JSON data.
- Expanded OCR implementations with the ability to train models.
- Functions to manipulate actual images and summarize aspects of them
  (such as measuring brightness/darkness and calculating differences
  between images) to help eliminate empty or “bad” images.
- Functions related to Timelapse (image processing program).
- Simple implementations of common but annoying data processing tasks
  (TBD)
- More vignettes!
- Test implementation (boring…).

## How to Install

*camRa* is not currently in CRAN, but can be installed from Github using
one of the options below:

``` r
#Depricated, use for older R versions
devtools::install_github("oxyppgyn/camRa")
```

``` r
#Most up-to-date method
pak::pak("oxyppgyn/camRa")
```

Don’t forget to import after!

``` r
library(camRa)
```
