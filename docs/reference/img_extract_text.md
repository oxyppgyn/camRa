# Extract Text from Image Using OCR

Extracts text from an image using optical character recognition (OCR).
OCR is notably unreliable for some camera types, text extraction should
be used as a last resort and may not be accurate. Check the results of
test images before trusting OCR text outputs.

## Usage

``` r
img_extract_text(image, bbox = NULL, file = NULL, overwrite = FALSE, ...)
```

## Arguments

- image:

  character or magick-image. The image to extract text from.

- bbox:

  numeric vector. Bounding box values. Formatted as xmin, ymin, xmax,
  ymax. Use
  [`convert_bbox()`](https://oxyppgyn.github.io/camRa/reference/convert_bbox.md)
  to convert from other formats. using absolute pixel values (Top-Left
  Bottom-Right format). Positions are measured from the top left corder
  of the image. Use `NULL` to get text from the entire image.

- ...:

  additional arguments passed to OCR engine as
  [`tesseract::tesseract()`](https://docs.ropensci.org/tesseract/reference/tesseract.html).

## Value

a character.
