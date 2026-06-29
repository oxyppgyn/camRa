# Insert New Values for a Timelapse DDB Column

Inserts a vector of values into a column in the data table of a
Timelapse DDB file, overwriting existing data. Best used to insert data
that cannot be obtained within Timelapse form metadata, such as OCR
extracted temperature values.

## Usage

``` r
tl_ddb_insert(file, col, values, ids)
```

## Arguments

- file:

  character. File path to a timelapse database file (.ddb).

- col:

  character. Name of the column you want to update in the DDB file.

- values:

  vector. A vector of values to insert into the database table. The
  class of this vector must align with the class of the database column.

- ids:

  numeric vector. A vector of values with the IDs used in the table.
  [tl_ddb_extract](https://oxyppgyn.github.io/camRa/reference/tl_ddb_extract.md)
  can be used to extract this information and join with your datasets.

## Value

NULL.
