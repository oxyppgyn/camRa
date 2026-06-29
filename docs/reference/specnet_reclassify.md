# Update Classification Information in SpeciesNet JSON Data

Reclassifies classification categories in SpeciesNet JSON data with new
species values, including merging categories into one. This function is
best used with a data frame mapping old values to new ones. A list of
current classification names can be pulled using
[`megadet_get_info()`](https://oxyppgyn.github.io/camRa/reference/megadet_get_info.md)
with `key = "classification_categories"` to build this table.

## Usage

``` r
specnet_reclassify(
  json,
  values_from,
  values_to,
  values_description = NULL,
  file = NULL,
  overwrite = FALSE,
  validate_json = getOption("camRa.validate_json", default = TRUE)
)
```

## Arguments

- json:

  character vector or nested list object from
  [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
  The JSON file or loaded JSON data to filter on.

- values_from:

  character vector. A vector of classification names currently in the
  JSON to be updated. This must be unique values and include all names
  present in the file.

- values_to:

  character vector. A vector of classification names to reassign current
  classification names as. Multiple copies of the same name can be
  present here to map values as many-to-one.

- values_description:

  character vector. A vector of classification descriptions to reassign
  current classification descriptions as. This must have unique values
  to map onto `values_from`. Use `NA` to skip updating descriptions and
  instead remove them from the file.

- file:

  character. File to write JSON data to. Use `NA` to skip writing to a
  file.

- overwrite:

  logical. If overwriting files is allowed.

- validate_json:

  boolean. If JSON data formatted as nested lists should be validated.
  This can prevent unexpected errors if the parameter is a list, but not
  JSON but may increase runtime.

## Value

a nested list object representing JSON data.

## Examples

``` r
if (FALSE) { # \dontrun{
#CSV with columns for old values, new values, and new descriptions columns
value_map <- read.csv("mapped_values.csv")

specnet_reclassify(
  json = "classifications.json",
  values_from = value_map$old_value,
  values_to = value_map$new_value,
  values_description = value_map$new_description
)
} # }
```
