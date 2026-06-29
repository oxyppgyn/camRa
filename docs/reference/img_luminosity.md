# Calculate Luminosity/Brightness of an Image

Extracts luminance information from a specified colorspace and returns
the appropriate channel.

## Usage

``` r
img_luminosity(
  image,
  method = "grayscale",
  file = NULL,
  overwrite = FALSE,
  bbox = NULL
)
```

## Arguments

- image:

  character or magick-image. Image to extract information from.

- method:

  character. The method used to calculate luminosity/brightness. Options
  are "greyscale" or "grayscale" to get a greyscale version of an RGB
  image, "LAB" to extract the lightness (L) channel from a LAB
  colorspace, "HSV" to extract the value (V) channel from a HVS
  colorspace, "YCbCr" for the luminance channel (Y) from a YCbCr color
  space, or "YIQ" for the luma (Y) channel in YIQ colorspace.

- file:

  character. File path to the output image.

- bbox:

  numeric vector. Bounding box values. Formatted as xmin, ymin, xmax,
  ymax. Use
  [`convert_bbox()`](https://oxyppgyn.github.io/camRa/reference/convert_bbox.md)
  to convert from other formats.

## Value

a magick image.
