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
  return(image)
}

crop_image <- function(image, bbox) {
  if (any(!is.null(bbox))) {
    if (length(bbox) != 4) {
      stop('Parameter `bbox` must be a a vector with four values (xmin, ymin, xmax, ymax) or `NULL`.')
    }

    width  <- bbox[[3]] - bbox[[1]] # xmax - xmin
    height <- bbox[[4]] - bbox[[2]] # ymax - ymin
    geometry <- paste0(width, 'x', height, '+', bbox[[1]], '+', bbox[[2]])
    image <- magick::image_crop(image = image, geometry = geometry)
  }

  return(image)
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
#' the top left corder of the image. Use `NULL` to get text from the entire image.
#' @param ... additional arguments passed to OCR engine as [tesseract::tesseract()].
#'
#' @return a character.
#' @export
img_extract_text <- function(image, bbox = NULL, file = NULL, ...) {
  #Get Image
  img <- import_image(image)

  #Crop Image
  img <- crop_image(img, bbox)

  #Run OCR
  ocr_text <- tesseract::ocr(
    image = img,
    engine =  tesseract::tesseract(...)
  )

  #Save Image
  if(!is.null(file)) {
    magick::image_write(img, path = file)
  }

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
#' Only used if converting between value types (`value_type` is opposite of the provided
#' bounding box). Value type of the input bounding box is inferred. Mutually exclusive
#' with `img_width` and `img_height`.
#' @param img_width,img_height numeric. The width and height of the image this bounding box
#' belongs to. Only used if converting between value types (`value_type` is opposite of the
#' provided bounding box). Value type of the input bounding box is inferred. Mutually exclusive
#' mutually exclusive with `image`.
#' @param value_type character. Type of values to use for the converted bounding box measures.
#' Either "absolute" for pixel values or "relative" for scaled values.
#'
#' @return a numberic vector.
#' @export
convert_bbox <- function(bbox, from, to, image = NULL, img_width = NULL, img_height = NULL, value_type = 'absolute') {
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

  #Get Image Width/Height
  if (given_value_type != value_type) {
    if (!is.null(image)) {
      img <- import_image(image)
      img_info <- magick::image_info(img)
    } else if (is.numeric(img_width) & is.numeric(img_width)) {
      img_info <- list(width = img_width, height = img_height)
    } else {
      stop('One of `image` or `img_width` and `img_height` must be specified when value type is different between input and output.')
    }
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

#' Calculate Differences Between Two Images
#'
#' Calculates the absolute pixel difference between two images.
#'
#' @param image1,image2 character or magick-image. Images to be compared.
#' @param file character. File path to the output image.
#' @param bbox numeric vector. Bounding box values. Formatted as xmin, ymin, xmax, ymax.
#' Use [camRa::convert_bbox()] to convert from other formats.
#'@param threshold numeric. The image threshold that should be applied between 0 and 1.
#'All values below the threshold will be converted to 0.
#'
#' @return a magick image.
#' @export
img_diff <- function(image1, image2, file = NULL, bbox = NULL, threshold = NULL) {

  #Read in Images
  img1 <- import_image(image1)
  img2 <- import_image(image2)

  #Check Dims
  if (magick::image_info(img1)$width != magick::image_info(img2)$width) {
    stop('Images have different widths.')
  }

  if (magick::image_info(img1)$height != magick::image_info(img2)$height) {
    stop('Images have different heights.')
  }

  #Crop Image
  img1 <- crop_image(img1, bbox)
  img2 <- crop_image(img2, bbox)

  #Calculate Difference
  diff_img <- magick::image_composite(img1, img2, operator = 'Difference') |>
    magick::image_convert(colorspace = "gray")

  #Threshold Image
  if (!is.null(threshold)) {
    diff_img <- magick::image_threshold(diff_img, threshold = paste0(threshold * 100, '%'), type = 'black')
  }

  #Save Image
  if (!is.null(file)) {
    magick::image_write(diff_img, path = file)
  }

  return(diff_img)
}

#' Apply a Summary function to an Image
#'
#' Applies a function to the extracted numeric matrix of values behind an image
#' and returns the result. Functions are applied using `apply()` across channels.
#' #'
#' @param image character or magick-image. Image to extract information from.
#' @param bbox numeric vector. Bounding box values. Formatted as xmin, ymin, xmax, ymax.
#' Use [camRa::convert_bbox()] to convert from other formats.
#'@param ... Additional arguments passed to `fun`.
#'
#' @return varies based on function applied.
#' @export
img_apply <- function(image, fun, bbox = NULL, ...) {
  if (!class(fun) == 'function') {
    stop('`fun` is not a function.')
  }

  #Import Image
  img <- import_image(image)

  #Crop Image
  img <- crop_image(img, bbox)

  #Get Image as Data
  img <- magick::image_data(img) |> as.numeric()

  return(fun(img, ...))
}

#' Calculate Luminosity/Brightness of an Image
#'
#' Extracts luminance information from a specified colorspace and returns the
#' the appropriate channel.
#'
#'
#' @param image character or magick-image. Image to extract information from.
#' @param method character. The method used to calculate luminosity/brightness.
#' Options are "greyscale" or "grayscale" to get a greyscale version of an RGB image, "LAB" to extract
#' the lightness (L) channel from a LAB colorspace, "HSV" to extract the value (V)
#' channel from a HVS colorspace, "YCbCr" for the luminance channel (Y) from a YCbCr
#' color space, or "YIQ" for the luma (Y) channel in YIQ colorspace.
#' @param file character. File path to the output image.
#' @param bbox numeric vector. Bounding box values. Formatted as xmin, ymin, xmax, ymax.
#' Use [camRa::convert_bbox()] to convert from other formats.
#'
#' @return a magick image.
#' @export
img_luminosity <- function(image, method = 'grayscale', file = NULL, bbox = NULL) {
  #Check Input
  if (!method %in% c('greyscale', 'grayscale', 'LAB', 'HSV', 'YCbCr', 'YIQ')) {
    stop('`method` is not a valid luminosity/brightness option.')
  }

  #Import Image
  img <- import_image(image)

  #Crop Image
  img <- crop_image(img, bbox)

  #Extract Channel
  ##Weird that "red" gets Y channels, but it works
  if (method %in% c('grayscale', 'greyscale')) {
    img <- magick::image_quantize(img, colorspace = 'gray')
  } else if (method == 'HSV') {
    img <- magick::image_convert(img, colorspace = method)
    img <- magick::image_channel(img, 'blue')
  } else {
    img <- magick::image_convert(img, colorspace = method)
    img <- magick::image_channel(img, 'red')
  }

  #Save Image
  if (!is.null(file)) {
    magick::image_write(img, path = file)
  }

  return(img)
}
