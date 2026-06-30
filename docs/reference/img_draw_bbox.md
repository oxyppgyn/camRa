# Add Bounding Box(es) to Images

Overlays bounding box(es) over images and saves this as a new image.

## Usage

``` r
img_draw_bbox(
  image,
  bbox,
  file = NULL,
  overwrite = FALSE,
  validate_json = getOption("camRa.validate_json", default = TRUE),
  ...
)
```

## Arguments

- image:

  character or magick-image. The image to extract text from.

- bbox, json:

  Pick one of `bbox` and `json`:

  - `bbox` character vector. Bounding box values. Formatted as xmin,
    ymin, xmax, ymax using absolute pixel values (Top-Left Bottom-Right
    format). Use `NA` to get text from the entire image.

  - `json`character vector or nested list object from
    [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
    JSON data with bounding box info to pull for the image.

- file:

  character. File to write image to. Use `NA` to skip writing to a file.

- validate_json:

  boolean. If JSON data formatted as nested lists should be validated.
  This can prevent unexpected errors if the parameter is a list, but not
  JSON but may increase runtime.

- ...:

  additional arguments passed to
  [`rect()`](https://rdrr.io/r/graphics/rect.html).

## Value

a magick image.
