# Flatten MegaDetector/SpeciesNet JSON Detection Data

Flattens MegaDetector/SpeciesNet JSON files to a table format. Data is
split by detection, with images potentially having more than one row of
data if more than one detection was found. Images with no detections
will have only one record here, with no detection (bbox) information.

## Usage

``` r
megadet_flatten(
  json,
  map_names = TRUE,
  validate_json = getOption("camRa.validate_json", default = TRUE)
)
```

## Arguments

- json:

  character vector or nested list object from
  [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
  The JSON file or loaded JSON data to filter on.

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

a dataframe with all data from the `images` tag of the JSON file.
