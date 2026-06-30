# Convert between BBox Formats

Converts bounding box data between three common formats: xyxy, xywh, and
centerwh. WARNING: This function is experimental, math behind some
conversions may be wrong and has not yet been validated.

## Usage

``` r
convert_bbox(
  bbox,
  from,
  to,
  image = NULL,
  img_width = NULL,
  img_height = NULL,
  value_type = "absolute",
  from_value_type = NULL
)
```

## Arguments

- bbox:

  character vector. Bounding box values.

- from, to::

  - `from` character vector. Bounding box format to convert from.

  - `to` character vector. Bounding box format to convert to.

  - Options: "xyxy", "xywh", and "centerwh"

- image:

  character or magick-image. The image to extract width and height from.
  Only used if converting between value types (`value_type` is opposite
  of the provided bounding box). Value type of the input bounding box is
  inferred. Mutually exclusive with `img_width` and `img_height`.

- img_width, img_height:

  numeric. The width and height of the image this bounding box belongs
  to. Only used if converting between value types (`value_type` is
  opposite of the provided bounding box). Value type of the input
  bounding box is inferred. Mutually exclusive mutually exclusive with
  `image`.

- value_type:

  character. Type of values to use for the converted bounding box
  measures. Either "absolute" for pixel values or "relative" for scaled
  values.

- from_value_type.:

  character or `NULL`. The type of values to convert from. This argument
  is only used if the type of values in the input bounding box cannot be
  automatically determined.

## Value

a numberic vector.
