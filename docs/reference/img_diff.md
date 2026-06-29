# Calculate Differences Between Two Images

Calculates the absolute pixel difference between two images.

## Usage

``` r
img_diff(image1, image2, file = NULL, bbox = NULL, threshold = NULL)
```

## Arguments

- image1, image2:

  character or magick-image. Images to be compared.

- file:

  character. File path to the output image.

- bbox:

  numeric vector. Bounding box values. Formatted as xmin, ymin, xmax,
  ymax. Use
  [`convert_bbox()`](https://oxyppgyn.github.io/camRa/reference/convert_bbox.md)
  to convert from other formats.

- threshold:

  numeric. The image threshold that should be applied between 0 and 1.
  All values below the threshold will be converted to 0.

## Value

a magick image.
