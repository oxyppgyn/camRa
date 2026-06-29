# Get a List of Datasets from LILA BC

Provides a dataframe with names (long and short) used for LILA datasets.
Can be used to find valid values for other LILA functions.

## Usage

``` r
LILA_list_datasets(quiet = FALSE, only_nonzip = TRUE)
```

## Arguments

- quiet:

  logical. If warnings should be shown.

- only_nonzip:

  logical. If the returned datasets should be only ones available
  file-by-file (not exclusively as compressed files).

## Value

A data frame with two columns: `DatasetName` and `DatasetShortName`.
