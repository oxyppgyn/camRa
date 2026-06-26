#' @include common.R
#' @noRd
NULL

#Req. Packages: library(jsonlite, aws.s3)

# ---------- Private Functions ----------
#Function to Get Region Seperately in Correct Format
aws_region <- function(x) {
  x <- strsplit(x, split = '/')[[1]][[3]]
  x <- strsplit(x, split = '\\.')[[1]][[1]]
}

#Function to Get Components of Bucket/Path in Bucket
##Formatting is different between LILA website and aws.s3
aws_bucket_components <- function(x) {
  x <- strsplit(x, split = '/')[[1]]
  bucket <- x[1:3] |> paste(collapse = '/')
  path <- x[4:length(x)] |> paste(collapse = '/')

  return(c(bucket, path))
}

# ---------- Public Functions ----------
#' Get a List of Datasets from LILA BC
#'
#' Provides a dataframe with names (long and short) used for LILA datasets.
#' Can be used to find valid values for other LILA functions.
#'
#' @param quiet boolean. If warnings should be shown.
#' @param only_nonzip boolean. If the returned datasets should be only ones
#' available file-by-file (not exclusively as compressed files).
#' @return A data frame with two columns: `DatasetName` and `DatasetShortName`.
#' @export
LILA_list_datasets <- function(quiet = FALSE, only_nonzip = TRUE) {
  if (!quiet) {
    warning('Datasets listed here are those available from LILA as of 06/18/2026.')
  }

  if (only_nonzip) {
    #Filter to Only Datasets that Can be Downloaded
    x <- LILA_datasets[LILA_datasets$AvailableNonZip, ]
    x <- x[, c('DatasetName', 'DatasetShortName')]

    return(x)

  } else {
    return(LILA_datasets[, c('DatasetName', 'DatasetShortName')])
  }
}

#' List Files in LILA Datasets
#'
#' Lists all files present in LILA datasets using AWS.
#'
#' @param dataset character. Name of the dataset to download images from.
#' Can be either the short name or standard name. See [LILA_list_datasets()] for options.
#'
#' @return A character vector of file names with partial paths (if applicable) of files
#' present in LILA datasets.
#' @export
LILA_list_files <- function(dataset) {
  #Validate Inputs
  if (!(dataset %in% LILA_datasets$DatasetName | dataset %in% LILA_datasets$DatasetShortName)) {
    stop('Paramter `dataset` is not a valid option. See LILA_list_datasets() for a list of valid dataset names.')
  }

  #Get Dataset Info
  ds_info <- LILA_datasets[LILA_datasets$DatasetName == dataset | LILA_datasets$DatasetShortName == dataset,] |>
    as.list()

  #Get AWS Path Sections
  aws_region <- aws_region(ds_info$AWS)
  bucket <- aws_bucket_components(ds_info$AWS)

  #Get List of Files
  aws_files <- get_bucket_df(
    bucket = bucket[[1]], prefix = bucket[[2]],
    region = aws_region
  )

  aws_files <- aws_files$Key

  #Clean Up Path
  aws_files <- gsub(pattern = bucket[[2]], replacement = '', x = aws_files)
  aws_files <- gsub("^/", "", aws_files)

  return(aws_files)
}

#' Download LILA Image Files
#'
#' Downloads subsets of image files from AWS S3 buckets associated with LILA datasets.
#'
#' @param dataset character. Name of the dataset to download images from.
#' Can be either the short name or standard name. See [LILA_list_datasets()].
#' @param files character or character vector. Partial path(s) or file name(s) of all images to be downloaded.
#' Files may have partial paths included here (such as `folder1/imgname.JPG`) depending on
#' how buckets are organized. If all files are stored in the same "folder" through S3, you
#' only need the file name with its extension. File names are typically available from JSON
#' metadata files hosted on the LILA website or via [LILA_list_files()].
#' @param dir character. Directory where images will be saved.
#' @param quiet boolean. If information on file downloads should be printed to the console.
#'
#' @return `NULL`
#'
#' @examplesIf interactive()
#' #Download example subset files
#' LILA_download_files(
#'   dataset = "ena24detection",
#'   files = ena24detection_img_files$subset,
#'   dir = getwd()
#' )
#'
#' @export
LILA_download <- function(dataset, files, dir, quiet = FALSE) {
  #Validate Inputs
  if (!(dataset %in% LILA_datasets$DatasetName | dataset %in% LILA_datasets$DatasetShortName)) {
    stop('Paramter `dataset` is not a valid option. See LILA_datasets() for a list of valid dataset names.')
  }

  #Get Dataset Info
  ds_info <- LILA_datasets[LILA_datasets$DatasetName == dataset | LILA_datasets$DatasetShortName == dataset,] |>
    as.list()

  #Get AWS Path Sections
  aws_region <- aws_region(ds_info$AWS)
  bucket <- aws_bucket_components(ds_info$AWS)

  #Create Folders
  file_paths <- file.path(dir, files)
  folder_paths <- file_paths |> dirname() |> unique()
  lapply(X = folder_paths, FUN = dir.create, showWarnings = FALSE)

  #Download File
  for (i in 1:length(files)) {
    aws.s3::save_object(
      object = paste(bucket[[2]], files[[i]], sep = '/'),
      bucket = bucket[[1]],
      file = file_paths[[i]],
      key = '',
      secret = '',
      region = aws_region
    )

    if (!quiet) {
      cat('Downloaded file:', files[[i]], '\n')
    }
  }

  invisible(NULL)
}
