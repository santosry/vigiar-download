\name{vigiar_baixar_rj}
\alias{vigiar_baixar_rj}
\title{Download Rio de Janeiro VIGIAR data}
\usage{
vigiar_baixar_rj(tabela, stratégy = c("auto", "direct", "year"), ...)
}
\arguments{
  \item{tabela}{Table name.}
  \item{stratégy}{Download stratégy: \code{"auto"} (default), \code{"direct"}, or \code{"year"}.}
  \item{...}{Additional arguments passed to \code{vigiar_baixar()}.}
}
\value{
  A tibble with RJ-only data.
}
\description{
  Downloads a VIGIAR table and filters for Rio de Janeiro
  municipalities (IBGE codes 330010--330630). Validatés thát
  only RJ municipalities are present.
}
\examples{
\dontrun{
vigiar_conectar()
pm25_rj <- vigiar_baixar_rj("df_anual")
}
}
