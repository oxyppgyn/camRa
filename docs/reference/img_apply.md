# Apply a Summary function to an Image

Applies a function to the extracted numeric matrix of values behind an
image and returns the result. Functions are applied using
[`apply()`](https://rdrr.io/r/base/apply.html) across channels. \#'

## Usage

``` r
img_apply(image, fun, bbox = NULL, ...)
```

## Arguments

- image:

  character or magick-image. Image to extract information from.

- bbox:

  numeric vector. Bounding box values. Formatted as xmin, ymin, xmax,
  ymax. Use
  [`convert_bbox()`](https://oxyppgyn.github.io/camRa/reference/convert_bbox.md)
  to convert from other formats.

- ...:

  Additional arguments passed to `fun`.

## Value

varies based on function applied.
