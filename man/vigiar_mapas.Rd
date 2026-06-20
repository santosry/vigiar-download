\name{vigiar_mapa_pm25}
\alias{vigiar_mapa_pm25}
\alias{vigiar_mapa_populacao_exposta}
\alias{vigiar_mapa_indicadores_saude}
\alias{vigiar_mapa_fracao_atribuivel}
\alias{vigiar_mapa_indoor}
\alias{vigiar_join_geobr}
\title{Exploratory choropleth maps}
\usage{
vigiar_mapa_pm25(dados, nivel = c("municipio", "uf"), ano = NULL,
  variavel = NULL, titulo = NULL)
vigiar_mapa_populacao_exposta(dados, nivel = c("municipio", "uf"),
  ano = NULL, variavel = "populacao", titulo = NULL)
vigiar_mapa_indicadores_saude(dados, nivel = c("uf", "municipio"),
  ano = NULL, variavel = NULL, titulo = NULL)
vigiar_mapa_fracao_atribuivel(dados, nivel = c("uf", "municipio"),
  ano = NULL, variavel = "fracao_atribuivel", titulo = NULL)
vigiar_mapa_indoor(dados, nivel = c("uf", "municipio"), ano = NULL,
  variavel = NULL, titulo = NULL)
vigiar_join_geobr(dados, nivel = c("municipio", "uf"), ano = 2020)
}
\arguments{
  \item{dados}{A processed VIGIAR tibble or sf object.}
  \item{nivel}{Spatial resolution: \code{"municipio"} or \code{"uf"}.}
  \item{ano}{Year to map (\code{NULL} = all).}
  \item{variavel}{Column to map (auto-detected if \code{NULL}).}
  \item{titulo}{Optional plot title.}
}
\value{
  A \code{ggplot} object (or \code{sf} for \code{vigiar_join_geobr}).
}
\description{
  Create choropleth maps from VIGIAR data. Requires \code{ggplot2}.
  \code{vigiar_join_geobr} optionally uses \code{geobr} and \code{sf}
  (Suggests) for spatial geometries; an informative error is raised
  if they are not installed.
}
\examples{
\dontrun{
vigiar_conectar()
pm25 <- vigiar_baixar("df_anual") |> process_pm25()
vigiar_mapa_pm25(pm25, nivel = "uf", ano = 2020)
}
}
