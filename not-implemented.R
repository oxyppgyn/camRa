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
#' @param ... additional arguments passed to [rect()].
#'
#' @return a magick image.
# -----------------------------------------' @export
img_draw_bbox <- function(image, bbox, file = NULL, overwrite = FALSE, validate_json = getOption('camRa.validate_json', default = TRUE), ...) {
  #Check BBox Input
  if (class(bbox) != 'character' || length(bbox) != 4) {
    stop('Parameter `bbox` must be a a vector with four values (xmin, ymin, xmax, ymax).')
  }

  #Get Image
  img <- import_image(image)

  #Draw BBox
  on.exit(dev.off())
  img <- magick::image_draw(img)
  rect(
    xleft = bbox[[1]],
    ybottom = bbox[[2]],
    xright = bbox[[3]],
    ytop = bbox[[4]],
    ...
  )

  #Save File
  if (!is.null(file)) {
    if (file.exists(file) & !overwrite) {
      stop('File already exists and overwriting is not enabled.')
    }
    magick::image_write(img, path = file)
  }

  return(img)
}

# ------------------
test_img <- 'C:/Users/Tanner/Desktop/ena-subset/1006.jpg'
json <- 'C:/Users/Tanner/Desktop/camRa/camRa/inst/extdata/ena24subset_MegaDet_recognition.json'

