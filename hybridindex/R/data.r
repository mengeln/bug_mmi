#' Example Data for the CSCI tool
#'
#' @name bugs_stations
#' @docType data
#' @keywords datasets
#' @description A list of two data frames, corresponding to the "bugs" type data frame (benthic macroinvertebrate
#'  count data) and "stations" type data frame (GIS-based site data) for the CSCI function. This is a toy data set
#'  and should not be used to make any inferences about the health of the included sites.
#' 
#' The bugs data frame contains the following:
#' \itemize{
#' \item StationCode: A code for the location of the sample
#' \item SampleID: A unique ID for the sample
#' \item FinalID: Names for the taxa identified in each sample. The names must correspond to a SWAMP FinalID
#' (see \url{http://swamp.mpsl.mlml.calstate.edu/}). 
#' \item BAResult: A count for that FinalID in that SampleID. Must be a non-negative integer.
#' \item LifeStageCode: Code for the life stage of the taxon. May be "A", "L", or "P" for insects; all non-insects
#' must be "X".
#' \item Distinct: Taxonomist's distinctiveness designation. This will override the automatic distinctiveness
#' designations made by the CSCI function. 1 indicates distinctiveness, 0 or NA will defer to the function's
#' designation.
#' }
#' The stations data frame contains the following:
#' \itemize{
#' \item StationCode: A code for the location of the sample. Every StationCode in the bugs data frame is
#' also represented here.
#' \item AREA_SQKM: The area of the watershed in square kilometers
#' \item New_Long: The site's longitude
#' \item New_Lat: The site's latitude
#' \item SITE_ELEV: Elevation in ???
#' \item TEMP_00_09: The average temperature from 2000 to 2009 in hundredths of degrees C
#' \item PPT_00_09: The average precipatation from 2000 to 2009 in hundredths of millimeters
#' \item SumAve_P: ???
#' \item KFCT_AVE: ???
#' \item BDH_AVE: ???
#' \item MgO_Mean: Average soil magnesium oxide in ???
#' \item P_MEAN: ???
#' \item CaO_Mean: Average calcareous soils in ???
#' \item PRMH_AVE: ???
#' \item S_Mean: ???
#' \item PCT_SEDIM: Percent sedimentary geology
#' \item LRPREM_mean: ???
#' \item N_MEAN: ???
#' \item LogWSA: \code{log10} of the AREA_SQKM. Not needed if AREA_SQKM is present.
#' }
#' @seealso \code{\link{CSCI}}, for processing these data
NULL