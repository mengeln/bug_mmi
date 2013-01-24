setClass("oe", representation(ambiguous="data.frame",
                              oesubsample="data.frame",
                              iterations="matrix",
                              fulliterations="list",
                              datalength="numeric",
                              oeresults="data.frame"), 
         contains="bugs",
         prototype=list(ambiguous=data.frame(),
                        oesubsample=data.frame(),
                        datalength=numeric(),
                        iterations=matrix(),
                        fulliterations=list(),
                        datalength=numeric(),
                        oeresults=data.frame()
         ))

setValidity("oe", function(object){
  validity(object)
})

setMethod("nameMatch", "oe", function(object, effort = "SAFIT1__OTU_a"){
  
  colnames(object@bugdata)[which(colnames(object@bugdata) == "FinalID")] <- "Taxa"
  colnames(object@bugdata)[which(colnames(object@bugdata) == "BAResult")] <- "Result"
  
  ###Clean data###
  object@bugdata$Taxa <- str_trim(object@bugdata$Taxa)
  ###Aggregate taxa###
  object@bugdata <- ddply(object@bugdata, "SampleID", function(df){
    ddply(df, "Taxa", function(sdf){
      id <- unique(sdf[, !(colnames(sdf) %in% "Result")])
      Result <- sum(sdf$Result)
      cbind(id, Result)
    })
  })
  
  ###Match to STE###
  load(system.file("metadata.rdata", package="BMIMetrics"))
  otu_crosswalk <- metadata
  object@bugdata$STE <- rep(NA, length(object@bugdata$Taxa))
  object@bugdata$STE <- otu_crosswalk[match(object@bugdata$Taxa, otu_crosswalk$FinalID), as.character(effort)]
  object@bugdata$STE <- as.character(object@bugdata$STE)
  object@bugdata <- object@bugdata[which(object@bugdata$STE != "Exclude"), ]
  object@bugdata$STE[which(is.na(object@bugdata$STE))] <- "Missing"
  
  ###Calculate ambiguous###
  percent.ambiguous <- ddply(object@bugdata, "SampleID", function(df){
    100*sum(df$Result[df$STE == "Ambiguous"])/sum(df$Result)
  })
  taxa.ambiguous <- ddply(object@bugdata, "SampleID", function(df){
    100*length(df$Taxa[df$STE == "Ambiguous"])/length(df$Taxa)
  })
  object@ambiguous <- merge(percent.ambiguous, taxa.ambiguous, by="SampleID")
  names(object@ambiguous)[2:3] <- c("individuals", "taxa")
  object@bugdata <- object@bugdata[object@bugdata$STE != "Ambiguous",]
  return(object)
})    
            
setMethod("subsample", "oe", function(object){
  if(nrow(object@ambiguous)==0){object <- nameMatch(object)}
  object@datalength <- length(object@bugdata)
  object@bugdata$SampleID <- as.character(object@bugdata$SampleID)
  rarifydown <- function(data){unlist(sapply(unique(data$SampleID), function(sample){
    v <- data[data$SampleID==sample, "Result"]
    if(sum(v)>=400){rrarefy(v, 400)} else
    {v}
  }))}
  registerDoParallel()
  rarificationresult <- foreach(i=1:20, .combine=cbind, .packages="vegan") %dopar% {
    rarifydown(object@bugdata)
  }
  closeAllConnections()
  object@oesubsample <- as.data.frame(cbind(object@bugdata, rarificationresult))
  colnames(object@oesubsample)[(object@datalength + 1):(object@datalength + 20)]<- paste("Replicate", 1:20)
  return(object)
})

setMethod("rForest", "oe", function(object){
  if(nrow(object@oesubsample)==0){object <- subsample(object)}
  load(system.file("data", "oe_stuff.rdata", package="CSCI"))
  
  object@predictors <- merge(unique(object@oesubsample[, c("StationCode", "SampleID")]), object@predictors,
                             by="StationCode", all.x=FALSE)
  row.names(object@predictors) <- paste0(object@predictors$StationCode, "%", object@predictors$SampleID)
  
  iterate <- function(rep){
    patable <- dcast(data=object@oesubsample[, c("StationCode", "SampleID", "STE", rep)],
                     StationCode + SampleID ~ STE,
                     value.var=rep,
                     fun.aggregate=function(x)sum(x)/length(x))
    patable[is.na(patable)] <- 0
    row.names(patable) <- paste(patable$StationCode, "%", patable$SampleID, sep="")
    
    
    iresult <- model.predict.RanFor.4.2(bugcal.pa=oe_stuff[[2]],
                                        grps.final=oe_stuff[[3]],
                                        preds.final=oe_stuff[[4]],
                                        ranfor.mod=oe_stuff[[1]],
                                        prednew=object@predictors,
                                        bugnew=patable,
                                        Pc=0.5,
                                        Cal.OOB=FALSE)
    iresult$SampleID <- unique(object@predictors$SampleID)
    return(iresult)
  }
  object@fulliterations <- lapply(paste("Replicate", 1:20), function(i)iterate(i))
  labels <- strsplit(row.names(object@fulliterations[[1]]), "%")
  labels <- as.data.frame(matrix(unlist(labels), nrow=length(labels), byrow=T))
  object@fulliterations <- lapply(object@fulliterations, function(l){
    row.names(l)<-labels[, 2]
    l
  })
  object@iterations <- do.call(cbind, lapply(object@fulliterations, function(l)l$OoverE))
  object@oeresults <- data.frame(labels, apply(object@iterations, 1, mean))
  names(object@oeresults) <- c("StationCode", "SampleID", "OoverE")
  object
})


setMethod("score", "oe", function(object)rForest(object))

setMethod("summary", "oe", function(object = "oe"){
  if(nrow(object@oeresults) != 0){
    object@oeresults
  } else
    show(object)
})

setMethod("plot", "oe", function(x = "oe"){
  load(system.file("data", "base_map.rdata", package="CSCI"))
  if(nrow(x@oeresults) == 0)stop("No data to plot; compute O/E scores first")
  x@oeresults <- cbind(x@oeresults, x@predictors[, c("StationCode", "SampleID", "New_Lat", "New_Long")])
  ggmap(base_map) + 
    geom_point(data=x@oeresults, aes(x=New_Long, y=New_Lat, colour=OoverE), size=4, alpha=.6) + 
    scale_color_continuous(low="red", high="green", name="O/E Score") + labs(x="", y="")
})