% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read_roads}
\alias{read_roads}
\title{Read in road lines shapefiles}
\usage{
read_roads(path_to_roads, road_id)
}
\arguments{
\item{path_to_roads}{full path to the directory of where 
the roads are stored, the directory should have zip files that 
have been unzipped for each county}

\item{road_id}{ID of the tract the roads are in}
}
\value{
an appended SpatialDataFrame object with all the roads in the state
}
\description{
Read in road lines shapefiles
}
