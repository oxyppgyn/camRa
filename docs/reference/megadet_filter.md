# Filter MegaDetector/SpeciesNet JSON Files by Image

Filters MegaDetector/SpeciesNet JSON files to only data for images in
the directory specified.

## Usage

``` r
megadet_filter(
  dir,
  json,
  file = NULL,
  validate_json = getOption("camRa.validate_json", default = TRUE)
)
```

## Arguments

- dir:

  character. Directory to be used to filter the JSON data. This folder
  should not be within the relative path of the `file` JSON tag, but
  should directly contain any folders that appear there.

- json:

  character vector or nested list object from
  [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
  The JSON file or loaded JSON data to filter on.

- file:

  character. File to write JSON data to. Use `NA` to skip writing to a
  file.

- validate_json:

  boolean. If JSON data formatted as nested lists should be validated.
  This can prevent unexpected errors if the parameter is a list, but not
  JSON but may increase runtime.

## Value

a nested list object with filtered JSON data.
