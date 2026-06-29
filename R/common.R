# ---------- Variables ----------

#Globals defined using options()
.onLoad <- function(libname, pkgname) {
  options(
    #Set globals (mutable) in here
    camRa.validate_json = TRUE
  )
}

# --- Copy/paste for references to these globals ---
#getOption('camRa.validate_json', default = TRUE)

#Example of how to edit these:
#options('camRa.validate_json' = FALSE)

# ---------- Functions ----------
#Import JSON File/Validate JSON Object
json_valimport <- function(json, validate_json) {
  #Skip Checking Contents
  if (!validate_json) {
    if (class(json) == 'character') {
      return(jsonlite::read_json(json))
    } else {
      return(json)
    }
  }

  #Validate if Format is Nested Lists
  if (class(json) == 'character') {
    json <- jsonlite::read_json(json)
  } else {
    if (validate_json) {
      if (!jsonlite::toJSON(json) |> jsonlite::validate()) {
        stop('Could not validate object provided to `json`. Please provide either the path to a JSON file or a JSON object from `read_json()`.')
      }
    }
  }

  return(json)
}


