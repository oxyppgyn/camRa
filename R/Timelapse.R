#' @include common.R
#' @noRd
NULL

#Req. Packages: library(DBI, RSQLite)
# ---------- Private Functions ----------

# ---------- Public Functions ----------
#' Get Data Table from Timelapse Database
#'
#' Pulls the data table from a .ddb file used by the Timelapse program. Similar to the export
#' to CSV option in the GUI.
#'
#' @param file character. File path to a timelapse database file (.ddb).
#'
#' @return a data frame.
#' @export
tl_ddb_extract <- function(file) {
  #Connect to DB
  con <- DBI::dbConnect(RSQLite::SQLite(), file)
  on.exit(DBI::dbDisconnect(con))

  #Get Data Table
  data_table <- DBI::dbReadTable(con, 'DataTable')

  return(data_table)
}

#' Insert New Values for a Timelapse DDB Column
#'
#' Inserts a vector of values into a column in the data table of a Timelapse DDB
#' file, overwriting existing data. Best used to insert data that cannot be
#' obtained within Timelapse form metadata, such as OCR extracted temperature values.
#'
#' @param file character. File path to a timelapse database file (.ddb).
#' @param col character. Name of the column you want to update in the DDB file.
#' @param values vector. A vector of values to insert into the database table.
#' The class of this vector must align with the class of the database column.
#' @param ids numeric vector. A vector of values with the IDs used in the table.
#' [camRa::tl_ddb_extract] can be used to extract this information and join with
#' your datasets.
#'
#' @return NULL.
#' @export
tl_ddb_insert <- function(file, col, values, ids) {
  #Check if Values and IDs are Same Length
  if (length(values) != length(ids)) {
    stop('Values and ids are different lengths.')
  }

  #Connect to DB
  con <- DBI::dbConnect(RSQLite::SQLite(), file)
  on.exit(DBI::dbDisconnect(con))

  #Check if Column Exists
  if (!col %in% DBI::dbListFields(con, 'DataTable')) {
    stop(paste(col, 'does not exist in the data table.'))
  }

  #Check if Lengths are the Same
  nrow_db <- DBI::dbGetQuery(con, 'SELECT COUNT(*) FROM DataTable')$`COUNT(*)`
  if (nrow_db != length(values)) {
    stop(paste('Database contains', nrow_db, 'rows. Values contains', length(values), 'elements.'))
  }

  #Check Types are Compatible
  col_class <- DBI::dbGetQuery(con, "SELECT * FROM DataTable LIMIT 0")[[col]] |> class()
  if (col_class != class(values)) {
    stop(paste(col, 'is of class', col_class, '. Values are of class', class(values), 'and is incompatible.'))
  }

  #Create DF to Insert
  data_insert <- data.frame(
    'id' = ids,
    'value' = values
  )

  #Create Temp. Table in DB
  DBI::dbWriteTable(con, name = 'temp_DT_update', value = data_insert, temporary = TRUE)

  query <- sprintf('
    UPDATE DataTable
    SET %1$s = (
      SELECT value
      FROM temp_DT_update
      WHERE temp_DT_update.id = DataTable.id
    )
    WHERE id IN (
      SELECT id FROM temp_DT_update
    );
  ', col)

  #Execute the Query
  rows_updated <- DBI::dbExecute(con, query)

  #Remove Temp. Table
  DBI::dbRemoveTable(con, 'temp_DT_update')

  invisible(NULL)
}
