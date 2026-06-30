# Basic Image Manipulations

``` r
library(camRa)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(magick)
#> Warning: package 'magick' was built under R version 4.5.1
#> Linking to ImageMagick 6.9.12.98
#> Enabled features: cairo, freetype, fftw, ghostscript, heic, lcms, pango, raw, rsvg, webp
#> Disabled features: fontconfig, x11
```

THIS VIGNETTE NOT FINISHED

*camRa* gives a variety of functions for manipulating and editing
images. Below are basic examples of using these functions.

## Prepare Data

Before running our examples, we’ll first want to grab whatever data we
need. First, the ena24detection and nacti subsets will both be used,
which are available as data frame objects in the package. The image
files for these are not already given and will need downloaded. We’ll
also need the JSON file that goes with the ena24detection subset, as
this contains information for bounding boxes.

For ena24detection, we’ll only download a single random image from the
dataset to use (in this case, “8491.jpg”). For nacti, we’ll download all
images in the subset to use.

``` r
#Get file paths
json_file <- system.file(
  "extdata", 
  "ena24subset_SpecNet_recognition.json", 
  package = "camRa"
)

image_file <- "8491.jpg"

#Download image for ena24detection
if (!file.exists(image_file)) {
  LILA_download(
    dataset = "ena24detection",
    files = image_file,
    dir = getwd(),
    quiet = TRUE
  )
}

#Download nacti images
##Check if already downloaded before running to save time
if (!all(file.exists(basename(nacti_subset$filename)))) {
  LILA_download(
    dataset = "nacti",
    files = nacti_subset$filename,
    dir = getwd(),
    flatten = TRUE, 
    quiet = TRUE
  )
}
```

Since we’re only wanting a single image’s data from the JSON file, we’ll
extract that and filter out information about other images. The easiest
way to get into a JSON file like this is usually with
[`megadet_flatten()`](https://oxyppgyn.github.io/camRa/reference/megadet_flatten.md)
which converts it to a table.

``` r
#Flatten JSON to make it easier to use
detection_data <- camRa::megadet_flatten(json_file)

#Filter JSON Data
detection_data <- dplyr::filter(detection_data, file == image_file)
```

## Adding Bounding Boxes to Images

Bounding boxes can be drawn on images using
[`img_draw_bbox()`](https://oxyppgyn.github.io/camRa/reference/img_draw_bbox.md).
For images with multiple bounding boxes, you can feed the image back
into the function iteratively for each bounding box. For a single
bounding box, things are of course a little simpler.

``` r
#Get BBox Data
image <- magick::image_read(image_file)

#Iterate through rows (each row is a bounding box)
for (i in 1:nrow(detection_data)) {
  #Get bounding box info
  bbox <- detection_data[i, c('bbox_x', 'bbox_y', 'bbox_width', 'bbox_height')] |>
  unname() |> unlist()
  
  #Convert to format expected by img_draw_bbox()
  bbox <- camRa::convert_bbox(
    bbox = bbox,
    from = 'xywh',
    to = 'xyxy',
    image = image,
    value_type = 'absolute'
  )
  
  #Draw bounding box
  image <- camRa::img_draw_bbox(
    image = image,
    bbox = bbox, 
    border = "red", lwd = 5
  )
}

print(image, info = FALSE)
```

![](basic-image-manipulation_files/figure-html/unnamed-chunk-4-1.png)

## Crop Using Bounding Boxes

TBD.

## Calculate Luminosity/Brightness

TBD.

## Calculate Differences Between Images

TBD.
