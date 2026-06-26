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
TL_extract_ddb <- function(file) {
  con <- DBI::dbConnect(RSQLite::SQLite(), file)
  data_table <- DBI::dbReadTable(con, 'DataTable')
  data_table <- data_table[, colnames(data_table) != 'Id']
  DBI::dbDisconnect(con)

  return(data_table)
}
