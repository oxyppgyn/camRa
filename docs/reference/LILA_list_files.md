# List Files in LILA Datasets

Lists all files present in LILA datasets using AWS.

## Usage

``` r
LILA_list_files(dataset)
```

## Arguments

- dataset:

  character. Name of the dataset to download images from. Can be either
  the short name or standard name. See
  [`LILA_list_datasets()`](https://oxyppgyn.github.io/camRa/reference/LILA_list_datasets.md)
  for options.

## Value

A character vector of file names with partial paths (if applicable) of
files present in LILA datasets.
