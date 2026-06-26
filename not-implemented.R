# -----------------------------------------------------------------------------#
# This file is not included in the installed package and is primarily for      #
#   development. Functions here are not implemented but may just be waiting on #
#   some fixes before being added to the package. I also put functions I have  #
#   an idea for here, often with just the function definition + description.   #
# -----------------------------------------------------------------------------#

#' Add Bounding Box(es) to Images
#'
#' Overlays bounding box(es) over images and saves this as a new image.
#'
#' @param image character or magick-image. The image to extract text from.
#' @param bbox,json Pick one of `bbox` and `json`:
#'   * `bbox` character vector. Bounding box values. Formatted as xmin, ymin, xmax, ymax
#' using absolute pixel values (Top-Left Bottom-Right format). Use `NA` to get text from
#' the entire image.
#'   * `json`character vector or nested list object from [jsonlite::read_json()].
#' JSON data with bounding box info to pull for the image.
#' @param file character. File to write image to. Use `NA` to skip writing to a file.
#' @param validate_json boolean. If JSON data formatted as nested lists should be validated.
#' This can prevent unexpected errors if the parameter is a list, but not JSON but may increase runtime.
#'
#' @return a magick image.
# -----------------------------------------' @export
image_draw_bbox <- function(image, bbox, json, file = NA, validate_json = .validate_json) {
  #Get Image
  img <- import_image(image)

  if (missing(bbox) & missing(json)) {
    stop('One of `bbox` or `json` must be given.')
  }

  if (!missing(bbox)) {

  } else {

  }
}

# ------------------
test_img <- 'C:/Users/Tanner/Desktop/ena-subset/1006.jpg'
json <- 'C:/Users/Tanner/Desktop/camRa/camRa/inst/extdata/ena24subset_MegaDet_recognition.json'

