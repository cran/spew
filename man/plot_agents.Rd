% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_spew.R
\name{plot_agents}
\alias{plot_agents}
\title{Plot the agents of synthetic ecosystem}
\usage{
plot_agents(syneco, input_data, g = NULL, color_list = list(bds = "white",
  interior = "gray60", roads = "gray10", agents = "darkorchid3", envs =
  c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
  "#CC79A7")))
}
\arguments{
\item{syneco}{the outputted synthetic ecosystem data from spew}

\item{input_data}{a list of the essential data and possibly supplementary data, shapefile must be one of the names}

\item{g}{a ggplot.  Default is NULL.}

\item{color_list}{optional list of colors to provide to the synthetic ecosystem. This must be a list with the following components:
"bds", "interior", "roads", "agents", "envs" where each entry in the list is a color or vector of colors}
}
\value{
a ggplot of the region
}
\description{
Plot the agents of synthetic ecosystem
}
