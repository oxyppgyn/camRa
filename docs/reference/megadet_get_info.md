# Get Values from MegaDetector/SpeciesNet JSON Files

Grabs values from MegaDetector/SpeciesNet JSON files based on provided
keys.

## Usage

``` r
megadet_get_info(
  json,
  key = "info",
  validate_json = getOption("camRa.validate_json", default = TRUE)
)
```

## Arguments

- json:

  character vector or nested list object from
  [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
  The JSON file or loaded JSON data to filter on.

- key:

  character, character vector, list, or `NULL`. Key(s) and/or indices to
  filter on in the JSON data. For root keys, provide a character of the
  key name. For higher levels, provide a vector or list of keys in the
  order they are nested. If `NULL` is passed as a key, the entire JSON
  will be returned.

- validate_json:

  boolean. If JSON data formatted as nested lists should be validated.
  This can prevent unexpected errors if the parameter is a list, but not
  JSON but may increase runtime.

## Value

dependent on keys used.

## Examples

``` r
if (FALSE) { # \dontrun{
#Get data for first images in file
megadet_get_info(
  json = "classifications.json",
  key = list("images", 1)
)

#Get name of detector used
megadet_get_info(
  json = "classifications.json",
  key = c("info", "detector")
)

#Load entire JSON from file
megadet_get_info(
  json = "classifications.json",
  key = NULL
)
} # }
```
