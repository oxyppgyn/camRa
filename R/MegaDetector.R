#' @include common.R
#' @noRd
NULL

#Req. Packages: library(jsonlite)

# ---------- Public Functions ----------
#' Filter MegaDetector/SpeciesNet JSON Files by Image
#'
#' Filters MegaDetector/SpeciesNet JSON files to only data for images in the directory specified.
#'
#' @param dir character. Directory to be used to filter the JSON data. This folder should
#' not be within the relative path of the `file` JSON tag, but should directly contain any
#' folders that appear there.
#' @param json character vector or nested list object from [jsonlite::read_json()].
#' The JSON file or loaded JSON data to filter on.
#' @param file character. File to write JSON data to. Use `NA` to skip writing to a file.
#' @param validate_json boolean. If JSON data formatted as nested lists should be validated.
#' This can prevent unexpected errors if the parameter is a list, but not JSON but may increase runtime.
#'
#' @return a nested list object with filtered JSON data.
#' @export
megadet_filter_json <- function(dir, json, file = NA, validate_json = getOption('camRa.validate_json', default = TRUE)) {
  #Get Files to Filter For
  img_files <- list.files(dir, full.names = FALSE, recursive = TRUE)

  #Import JSON File/Validate JSON Object
  json_data <- json_valimport(json, validate_json)

  #Remove Elements Not for Existing Image Files
  rem_i <- c()
  for (i in 1:length(json_data$images)) {
    rem_i <- append(rem_i, json_data$images[[i]]$file %in% img_files)
  }

  #Remove Indexes for Images Not in Files
  json_data$images <- json_data$images[rem_i]

  #Save File
  if (!is.na(file)) {
    jsonlite::write_json(json_data, file, pretty = TRUE)
  }

  return(json_data)
}

#' Flatten MegaDetector/SpeciesNet JSON Detection Data
#'
#' Flattens MegaDetector/SpeciesNet JSON files to a table format. Data is split by detection, with
#' images potentially having more than one row of data if more than one detection was found. Images
#' with no detections are not included here.
#'
#' @param json character vector or nested list object from [jsonlite::read_json()].
#' The JSON file or loaded JSON data to filter on.
#' @param  map_names boolean. If MegaDetector and SpeciesNet names should be mapped from
#' numeric values to the values provided in the `detection_categories` and
#' `classification_categories` tags. These are typically gross (human, animal, vehicle) and
#' taxonomic classifications respectively.
#' @param validate_json boolean. If JSON data formatted as nested lists should be validated.
#' This can prevent unexpected errors if the parameter is a list, but not JSON but may increase runtime.
#'
#' @return a dataframe with all data from the `images` tag of the JSON file.
#' @export
megadet_flatten_json <- function(json, map_names = TRUE, validate_json = getOption('camRa.validate_json', default = TRUE)) {

  #Import JSON File/Validate JSON Object
  json_data <- json_valimport(json, validate_json)

  #Iterate Through Images
  md_sn_data <- list()
  for (i in 1:length(json_data$images)) {
    img_data <- json_data$images[[i]]

    #Check for Image Failure
    if (length(json_data$images[[i]]$failure) > 0) {
      if (length(json_data$classification_categories)  == 0) {
        x <- list(
          'index' = i, 'file' = img_data$detections[[i]][['file']],
          'detection_category' = NA, 'detection_conf' = NA, 'bbox_x' = NA,
          'bbox_y' = NA, 'bbox_width' = NA, 'bbox_height' = NA, 'failure' = TRUE
        )
      } else {
        x <- list(
          'index' = i, 'file' = img_data$detections[[i]][['file']],
          'detection_category' = NA, 'detection_conf' = NA, 'classification_category' = NA,
          'classification_conf' = NA, 'bbox_x' = NA, 'bbox_y' = NA, 'bbox_width' = NA,
          'bbox_height' = NA, 'failure' = TRUE
        )
      }

      md_sn_data <- append(md_sn_data, list(x))
      next
    }

    ##Skip When No Detections
    if (length(img_data$detections) == 0) {next}

    ##For Files Without SpeciesNet
    if (!('classification_categories' %in% names(json_data)) || length(json_data$classification_categories)  == 0) {
      for (i in 1:length(img_data$detections)) {
        x <- list(
          'index' = i,
          'file' = img_data$file,
          'detection_category' = img_data$detections[[i]][['category']],
          'detection_conf' = img_data$detections[[i]][['conf']],
          'bbox_x' = img_data$detections[[i]][['bbox']][[1]],
          'bbox_y' = img_data$detections[[i]][['bbox']][[2]],
          'bbox_width' = img_data$detections[[i]][['bbox']][[3]],
          'bbox_height' = img_data$detections[[i]][['bbox']][[4]],
          'failure' = FALSE
        )

        md_sn_data <- append(md_sn_data, list(x))
      }
    } else {
      #For Files with SpeciesNet
      for (i in 1:length(img_data$detections)) {
        x <- list(
          'index' = i,
          'file' = img_data$file,
          'detection_category' = img_data$detections[[i]][['category']],
          'detection_conf' = img_data$detections[[i]][['conf']],
          'classification_category' = ifelse(
            length(img_data$detections[[i]]$classifications) > 0,
            img_data$detections[[i]]$classifications[[1]][[1]],
            NA
          ),
          'classification_conf' = ifelse(
            length(img_data$detections[[i]]$classifications) > 0,
            img_data$detections[[i]]$classifications[[1]][[2]],
            NA
          ),
          'bbox_x' = img_data$detections[[i]][['bbox']][[1]],
          'bbox_y' = img_data$detections[[i]][['bbox']][[2]],
          'bbox_width' = img_data$detections[[i]][['bbox']][[3]],
          'bbox_height' = img_data$detections[[i]][['bbox']][[4]],
          'failure' = FALSE
        )

        md_sn_data <- append(md_sn_data, list(x))
      }
    }
  }

  #Convert to DF
  md_sn_data <- do.call(rbind, lapply(md_sn_data, as.data.frame))

  #Map Category Names
  if (map_names) {
    ##Map MegaDetector Categories
    md_sn_data$detection_category <- lapply(
      X = md_sn_data$detection_category,
      FUN = function(x, y) {ifelse(is.na(x), NA, y[[x]])},
      y = json_data$detection_categories
    ) |> unlist()

    ##Map SpeciesNet Categories
    if ('classification_categories' %in% names(json_data) && length(json_data$classification_categories)  > 0) {
      md_sn_data$classification_category <- lapply(
        X = md_sn_data$classification_category,
        FUN = function(x, y) {ifelse(is.na(x), NA, y[[x]])},
        y = json_data$classification_categories
      ) |> unlist()
    }
  }

  return(md_sn_data)
}

#' Get Values from MegaDetector/SpeciesNet JSON Files
#'
#' Grabs values from MegaDetector/SpeciesNet JSON files based on provided keys.
#'
#' @param json character vector or nested list object from [jsonlite::read_json()].
#' The JSON file or loaded JSON data to filter on.
#' @param key character, character vector, list, or `NULL`. Key(s) and/or indices to filter on in the JSON data.
#' For first level keys, provide a character of the key name. For higher levels, provide a vector
#' of keys in the order they are nested, such as `c("info", "megadetector_version")` to get the
#' MegaDetector version. A list with keys and indices can also be used, such as `list("images", 1)`
#' for detection information on the first image in the file. If `NULL` is passed as a key, the entire JSON
#' file will be returned.
#' @param file character. File to write JSON data to. Use `NA` to skip writing to a file.
#' @param validate_json boolean. If JSON data formatted as nested lists should be validated.
#' This can prevent unexpected errors if the parameter is a list, but not JSON but may increase runtime.
#' @examples
#' \dontrun{
#' #Get data for first images in file
#' megadet_get_info(
#'   json = "classifications.json",
#'   key = list("images", 1)
#' )
#'
#' #Get name of detector used
#' megadet_get_info(
#'   json = "classifications.json",
#'   key = c("info", "detector")
#' )
#'
#' #Load entire JSON from file
#' megadet_get_info(
#'   json = "classifications.json",
#'   key = NULL
#' )
#' }
#'
#' @return dependent on keys used.
#' @export
megadet_get_info <- function(json, key = 'info', file = NA, validate_json = getOption('camRa.validate_json', default = TRUE)) {
  #Import JSON File/Validate JSON Object
  json_data <- json_valimport(json, validate_json)

  for (i in key) {
    json_data <- json_data[[i]]
  }

  #Save File
  if (!is.na(file)) {
    jsonlite::write_json(json_data, file, pretty = TRUE)
  }

  return(json_data)
}

#' Count Number of Instances of MegaDetector/SpeciesNet Categories in Images
#'
#' Counts instances of each class for MegaDetector/SpeciesNet across images in JSON data.
#'
#' @param json character vector or nested list object from [jsonlite::read_json()].
#' The JSON file or loaded JSON data to filter on.
#' @param type character. "detection" if counts should be done from MegaDetector's gross
#' categories or "classification" for counts from SpeciesNet's species-level classifications.
#' @param  map_names boolean. If MegaDetector and SpeciesNet names should be mapped from
#' numeric values to the values provided in the `detection_categories` and `classification_categories`
#' tags. These are typically gross (human, animal, vehicle) and taxonomic classifications respectively.
#' @param validate_json boolean. If JSON data formatted as nested lists should be validated.
#' This can prevent unexpected errors if the parameter is a list, but not JSON but may increase runtime.
#'
#' @return a dataframe with a category and count column.
#' @export
megadet_get_counts <- function(json, type = 'detection', map_names = TRUE, validate_json = getOption('camRa.validate_json', default = TRUE)) {
  #Validate Inputs
  if (!type %in% c('detection', 'classification')) {
    stop('Paramter `type` is not a valid option.')
  }

  #Import JSON File/Validate JSON Object
  json_data <- json_valimport(json, validate_json)

  #Ensure The File Has SpeciesNet Data if Classifications are Used
  if (type == 'classification' & length(json_data$classification_categories)  == 0) {
    stop('"classification" provided for parameter `type`, but no classification categories in file.')
  }

  counts <- list()
  #Iterate Through Images and Detections
  for (img in json_data$images) {
    for (det in img$detections) {
      #Get Category
      if (type == 'detection') {
        category <- det$category
      } else {
        category <- det$classifications[[1]][[1]]
      }

      #Increment Count
      counts[[category]] <- ifelse(
        test = !is.null(counts[[category]]),
        yes = counts[[category]],
        no = 0
      ) + 1
    }
  }

  #Convert to DF
  counts_df <- data.frame(
    category = names(counts),
    count = unname(unlist(counts))
  )

  #Map Names
  if (map_names) {
    counts_df$category <- lapply(
      X = counts_df$category,
      FUN = function(x, y) {y[[x]]},
      y = json_data[[paste0(type, '_categories')]]
    ) |> unlist()
  }

  return(counts_df)

}

#' Update Classification Information in SpeciesNet JSON Data
#'
#' Reclassifies classification categories in SpeciesNet JSON data with new species values,
#' including merging categories into one. This function is best used with a data frame mapping
#' old values to new ones. A list of current classification names can be pulled using
#' [camRa::megadet_get_info()] with `key = "classification_categories"` to build this table.
#'
#' @param json character vector or nested list object from [jsonlite::read_json()].
#' The JSON file or loaded JSON data to filter on.
#' @param values_from character vector. A vector of classification names currently in the JSON to
#' be updated. This must be unique values and include all names present in the file.
#' @param values_to character vector. A vector of classification names to reassign current classification
#' names as. Multiple copies of the same name can be present here to map values as many-to-one.
#' @param values_description character vector. A vector of classification descriptions to reassign current
#' classification descriptions as. This must have unique values to map onto `values_from`. Use `NA`
#' to skip updating descriptions and instead remove them from the file.
#' @param file character. File to write JSON data to. Use `NA` to skip writing to a file.
#' @param validate_json boolean. If JSON data formatted as nested lists should be validated.
#' This can prevent unexpected errors if the parameter is a list, but not JSON but may increase runtime.
#'
#' @examples
#' \dontrun{
#' #CSV with columns for old values, new values, and new descriptions columns
#' value_map <- read.csv("mapped_values.csv")
#'
#' specnet_reclassify(
#'   json = "classifications.json",
#'   values_from = value_map$old_value,
#'   values_to = value_map$new_value,
#'   values_description = value_map$new_description
#' )
#' }
#'
#' @return a nested list object representing JSON data.
#' @export
specnet_reclassify <- function(json, values_from, values_to, values_description = NA, file = NA, validate_json = getOption('camRa.validate_json', default = TRUE)) {
  #Check if From Values Are Unique + Same Length
  if (length(values_from) != length(unique(values_from))) {
    stop('Values from are not unique.')
  }

  if (length(values_from) != length(values_to)) {
    stop('Values from and to are not the same length.')
  }

  #Import JSON File/Validate JSON Object
  json_data <- json_valimport(json, validate_json)

  #Validate Lengths/Values Contained
  if (!all(values_from %in% json_data$classification_categories |> unname() |> unlist())) {
    stop('Values from is missing values present in classification_categories.')
  }

  if (length(values_from) != json_data$classification_categories |> unname() |> unlist() |> length()) {
    stop('Values from is missing values present in classification_categories.')
  }

  if (class(values_description) == 'character') {
    if (length(values_description) != length(values_from)) {
      stop('Values from is not the same length as value descriptions.')
    }

    #if (length(unique(values_description)) != length(unique(values_from))) {
    #  stop('Values from and value descriptions do not have the same number of unique elements. These two arrays must be one-to-one.')
    #}

  } else {
    if (!is.na(values_description)) {
      stop('Value descriptions must be a character vector or `NA`.')
    }
  }

  #Get Maps
  ##Key = ID, Value = Name
  old_map <- json_data$classification_categories
  new_map <- unique(values_to) |> as.list()
  names(new_map) <- 0:(length(unique(values_to)) - 1)  |> as.character()

  #Create Crosswalk
  ##Key = Old ID, Value = New ID
  crosswalk <- lapply(
    X = values_to,
    FUN = function(x,y) {y[[x]]},
    y = as.list(setNames(names(new_map), new_map))
  ) |> unlist()

  names(crosswalk) <- lapply(
    X = values_from,
    FUN = function(x,y) {y[[x]]},
    y = as.list(setNames(names(old_map), old_map))
  ) |> unlist()

  #Replace Image Data Values
  for (i in 1:length(json_data$images)) {
    if (length(json_data$images[[i]]$detections) == 0) {next}
    for (j in 1:length(json_data$images[[i]]$detections)) {
      if (length(json_data$images[[i]]$detections[[j]]$classifications) == 0) {next}
      old_val <- json_data$images[[i]]$detections[[j]]$classifications[[1]][[1]]
      if (!is.null(old_val)) {
        json_data$images[[i]]$detections[[j]]$classifications[[1]][[1]] <- crosswalk[[old_val]]
      }
    }
  }

  #Replace Classification Categories
  json_data$classification_categories <- new_map

  #Replace Classification Descriptions
  if (class(values_description) == 'character') {
    desc_map <- unique(values_description) |> as.list()
    names(desc_map) <- 0:(length(unique(values_description)) - 1)  |> as.character()

    json_data$classification_category_descriptions <- desc_map
  } else {
    json_data$classification_category_descriptions <- setNames(list(), character(0))
  }

  #Save File
  if (!is.na(file)) {
    jsonlite::write_json(json_data, file, pretty = TRUE)
  }

  return(json_data)

}
