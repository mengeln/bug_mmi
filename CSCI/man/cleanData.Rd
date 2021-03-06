% Generated by roxygen2 (4.0.1): do not edit by hand
\name{cleanData}
\alias{cleanData}
\title{Score samples using the CSCI tool}
\usage{
cleanData(data, purge = TRUE)
}
\arguments{
\item{data}{A data frame with BMI data (see details)}

\item{purge}{If true (default) a data frame will be returned
with problematic rows removed. Else, a report of problems will be
returned.}
}
\description{
Function to find or remove errors in BMI data
}
\details{
This functions checks for several types of common errors:
incorrect case in FinalID names,
FinalIDs that are missing from the internal database,
FinalIDs with inappropriate life stage codes (e.g., non-insects
with a LifeStageCode other than 'X').

This functions requires that the dataframe contains at least two columns:
FinalID and LifeStageCode.
}

