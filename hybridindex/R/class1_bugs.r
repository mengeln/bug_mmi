setClass("bugs", representation(bugdata="data.frame",
                                predictors="data.frame",
                                dbconn="SQLiteConnection"),
         prototype=list(dbconn = dbConnect("SQLite", "data/bug_metadata.db"))
         )

setValidity("bugs", function(object){
  validity(object)
})

setMethod("initialize", "bugs", function(.Object="bugs", bugdata=data.frame(), predictors=data.frame()){
  .Object@bugdata <- bugdata
  .Object@predictors <- predictors
  .Object@dbconn <- dbConnect("SQLite", system.file("data", "bug_metadata.db", package="hybridindex"))
  .Object
})

setMethod("show", "bugs", function(object){
  print(head(object@bugdata))
  cat("\n")
  print(head(object@predictors))
})