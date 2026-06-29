# Count Number of Instances of MegaDetector/SpeciesNet Categories in Images

Counts instances of each class for MegaDetector/SpeciesNet across images
in JSON data.

## Usage

``` r
megadet_get_counts(
  json,
  type = "detection",
  map_names = TRUE,
  validate_json = getOption("camRa.validate_json", default = TRUE)
)
```

## Arguments

- json:

  character vector or nested list object from
  [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
  The JSON file or loaded JSON data to filter on.

- type:

  character. "detection" if counts should be done from MegaDetector's
  gross categories or "classification" for counts from SpeciesNet's
  species-level classifications.

- map_names:

  boolean. If MegaDetector and SpeciesNet names should be mapped from
  numeric values to the values provided in the `detection_categories`
  and `classification_categories` tags. These are typically gross
  (human, animal, vehicle) and taxonomic classifications respectively.

- validate_json:

  boolean. If JSON data formatted as nested lists should be validated.
  This can prevent unexpected errors if the parameter is a list, but not
  JSON but may increase runtime.

## Value

a dataframe with a category and count column.
