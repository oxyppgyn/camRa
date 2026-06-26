#' @include common.R
#' @noRd
NULL

#Req. Packages: library(magick, tesseract)

# ---------- Private Functions ----------
#Import magick Image
import_image <- function(image) {
  if (class(image) == 'character') {
    return(magick::image_read(image))
  }

  if (class(image) != 'magick-image') {
    stop('`image` parameter is not a magick image or file path.')
  }
}

# ---------- Public Functions ----------
#' Extract Text from Image Using OCR
#'
#' Extracts text from an image using optical character recognition (OCR). OCR is
#' notably unreliable for some camera types, text extraction should be used as a
#' last resort and may not be accurate. Check the results of test images before
#' trusting OCR text outputs.
#'
#' @param image character or magick-image. The image to extract text from.
#' @param bbox numeric vector. Bounding box values. Formatted as xmin, ymin, xmax, ymax.
#' Use [camRa::convert_bbox()] to convert from other formats.
#' using absolute pixel values (Top-Left Bottom-Right format). Positions are measured from
#' the top left corder of the image. Use `NA` to get text from the entire image.
#' @param ... additional arguments passed to OCR engine as [tesseract::tesseract()].
#'
#' @return a character.
#' @export
image_extract_text <- function(image, bbox = NA, file = NA, ...) {
  #Get Image
  img <- import_image(image)

  #Crop Image
  if (any(!is.na(bbox))) {
    if (length(bbox) != 4) {
      stop('Parameter `bbox` must be a a vector with four values (xmin, ymin, xmax, ymax) or `NA`.')
    }

    width  <- bbox[[3]] - bbox[[1]] # xmax - xmin
    height <- bbox[[4]] - bbox[[2]] # ymax - ymin
    geometry <- paste0(width, 'x', height, '+', bbox[[1]], '+', bbox[[2]])

    img <- magick::image_crop(image = img, geometry = geometry)
  }

  #Run OCR
  ocr_text <- tesseract::ocr(
    image = img,
    engine =  tesseract::tesseract(...)
  )

  #Free Memory from Image
  magick::image_destroy(img)

  return(ocr_text)
}

#' Convert between BBox Formats
#'
#' Converts bounding box data between three common formats: xyxy, xywh, and centerwh.
#' WARNING: This function is experimental, math behind some conversions may be wrong
#' and has not yet been validated.
#'
#' @param bbox character vector. Bounding box values.
#' @param from,to:
#'   * `from` character vector. Bounding box format to convert from.
#'   * `to` character vector. Bounding box format to convert to.
#'   * Options: "xyxy", "xywh", and "centerwh"
#' @param image character or magick-image. The image to extract width and height from.
#' Only needed if converting between value types (`value_type` is opposite of the provided
#' bounding box). Value type of the input bounding box is inferred.
#' @param value_type character. Type of values to use for the converted bounding box measures.
#' Either "absolute" for pixel values or "relative" for scaled values.
#'
#' @return a numberic vector.
#' @export
convert_bbox <- function(bbox, from, to, image, value_type = 'absolute') {
  #Check Inputs
  if (length(bbox) != 4) {
    stop('Parameter `bbox` must be a a vector with four values (xmin, ymin, xmax, ymax) or `NA`.')
  }

  if (!from %in% c('xyxy', 'xywh', 'centerwh')) {
    stop('Parameter `from` must be one of "xyxy", "xywh", or "centerwh".')
  }

  if (!to %in% c('xyxy', 'xywh', 'centerwh')) {
    stop('Parameter `to` must be one of "xyxy", "xywh", or "centerwh".')
  }

  if (!value_type %in% c('absolute', 'relative')) {
    stop('Parameter `value_type` must be one of "absolute" or "relative".')
  }

  if (from == to) {
    stop('Parameters `from` and `to` must be different values.')
  }

  #Determine BBox Format
  ##Relative Values
  if(all(bbox <= 1)) {
    given_value_type <- 'relative'
    ##Absolute Values
  } else if (all(bbox > 1)) {
    given_value_type <- 'absolute'
    ##Unknown
  } else {
    stop('Could not determine bounding box format from values provided.')
  }

  #Get Image
  if (given_value_type != value_type) {
    img <- import_image(image)
    img_info <- magick::image_info(img)
  }

  #Convert
  if (from == 'xyxy' & to == 'xywh') {
    bbox_new <- c(
      bbox[[1]],
      bbox[[2]],
      bbox[[3]] - bbox[[1]],
      bbox[[4]] - bbox[[2]]
    )
  } else if (from == 'xyxy' & to == 'centerwh') {
    bbox_new <- c(
      (bbox[[1]] + bbox[[3]]) / 2,
      (bbox[[2]] + bbox[[4]]) / 2,
      bbox[[3]] - bbox[[1]],
      bbox[[4]] - bbox[[2]]
    )

  } else if (from == 'xywh' & to == 'xyxy') {
    bbox_new <- c(
      bbox[[1]],
      bbox[[2]],
      bbox[[1]] + bbox[[3]],
      bbox[[2]] + bbox[[4]]
    )

  } else if (from == 'xywh' & to == 'centerwh') {
    bbox_new <- c(
      (bbox[[1]] * 2 + bbox[[3]]) / 2,
      (bbox[[2]] * 2 + bbox[[4]]) / 2,
      bbox[[3]],
      bbox[[4]]
    )

  } else if (from == 'centerwh' & to == 'xyxy') {
    bbox_new <- c(
      bbox[[1]] - bbox[[3]]/2,
      bbox[[2]] - bbox[[4]]/2,
      bbox[[1]] + bbox[[3]]/2,
      bbox[[2]] + bbox[[4]]/2,
    )

  } else if (from == 'centerwh' & to == 'xywh') {
    bbox_new <- c(
      bbox[[1]] - bbox[[3]]/2,
      bbox[[2]] - bbox[[4]]/2,
      bbox[[3]],
      bbox[[4]]
    )
  }

  #Change Between Relative and Absolute
  if (given_value_type == 'absolute' & value_type == 'relative') {
    if (to == 'xyxy') {
      bbox_new <- c(
        bbox_new[[1]] / img_info$width,
        bbox_new[[2]] / img_info$height,
        bbox_new[[3]] / img_info$width,
        bbox_new[[4]] / img_info$height
      )

    } else if (to == 'xywh') {
      bbox_new <- c(
        bbox_new[[1]] / img_info$width,
        bbox_new[[2]] / img_info$height,
        bbox_new[[3]] / img_info$width,
        bbox_new[[4]] / img_info$height
      )

    } else if (to == 'centerwh') {
      bbox_new <- c(
        bbox_new[[1]] / img_info$width,
        bbox_new[[2]] / img_info$height,
        bbox_new[[3]] / img_info$width,
        bbox_new[[4]] / img_info$height
      )
    }

  } else if (given_value_type == 'relative' & value_type == 'absolute') {
    if (to == 'xyxy') {
      bbox_new <- c(
        bbox_new[[1]] * img_info$width,
        bbox_new[[2]] * img_info$height,
        bbox_new[[3]] * img_info$width,
        bbox_new[[4]] * img_info$height
      )

    } else if (to == 'xywh') {
      bbox_new <- c(
        bbox_new[[1]] * img_info$width,
        bbox_new[[2]] * img_info$height,
        bbox_new[[3]] * img_info$width,
        bbox_new[[4]] * img_info$height
      )

    } else if (to == 'centerwh') {
      bbox_new <- c(
        bbox_new[[1]] * img_info$width,
        bbox_new[[2]] * img_info$height,
        bbox_new[[3]] * img_info$width,
        bbox_new[[4]] * img_info$height
      )
    }
  }

  return(bbox_new)
}
