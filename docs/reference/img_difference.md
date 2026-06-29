# Calculate Differences Between Two Images

Calculates the absolute pixel difference between two images.

## Usage

``` r
img_difference(
  image1,
  image2,
  threshold = NULL,
  file = NULL,
  overwrite = FALSE,
  bbox = NULL
)
```

## Arguments

- image1, image2:

  character or magick-image. Images to be compared.

- threshold:

  numeric. The image threshold that should be applied between 0 and 1.
  All values below the threshold will be converted to 0.

- file:

  character. File path to the output image.

- bbox:

  numeric vector. Bounding box values. Formatted as xmin, ymin, xmax,
  ymax. Use
  [`convert_bbox()`](https://oxyppgyn.github.io/camRa/reference/convert_bbox.md)
  to convert from other formats.

## Value

a magick image.
