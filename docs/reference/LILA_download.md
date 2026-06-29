# Download LILA Image Files

Downloads subsets of image files from AWS S3 buckets associated with
LILA datasets.

## Usage

``` r
LILA_download(dataset, files, dir, quiet = FALSE)
```

## Arguments

- dataset:

  character. Name of the dataset to download images from. Can be either
  the short name or standard name. See
  [`LILA_list_datasets()`](https://oxyppgyn.github.io/camRa/reference/LILA_list_datasets.md).

- files:

  character or character vector. Partial path(s) or file name(s) of all
  images to be downloaded. Files may have partial paths included here
  (such as `folder1/imgname.JPG`) depending on how buckets are
  organized. If all files are stored in the same "folder" through S3,
  you only need the file name with its extension. File names are
  typically available from JSON metadata files hosted on the LILA
  website or via
  [`LILA_list_files()`](https://oxyppgyn.github.io/camRa/reference/LILA_list_files.md).

- dir:

  character. Directory where images will be saved.

- quiet:

  boolean. If information on file downloads should be printed to the
  console.

## Value

`NULL`

## Examples

``` r
#Download example subset files
LILA_download_files(
  dataset = "ena24detection",
  files = ena24detection_img_files$subset,
  dir = getwd()
)
#> Error in LILA_download_files(dataset = "ena24detection", files = ena24detection_img_files$subset,     dir = getwd()): could not find function "LILA_download_files"
```
