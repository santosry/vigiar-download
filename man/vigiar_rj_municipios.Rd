\name{vigiar_rj_municípios}
\alias{vigiar_rj_municípios}
\alias{vigiar_rj_macrorregiões}
\alias{vigiar_rj_regiões_saúde}
\title{Rio de Janeiro municipalities and health regions}
\usage{
vigiar_rj_municípios()
vigiar_rj_macrorregiões()
vigiar_rj_regiões_saúde()
}
\value{
  \code{vigiar_rj_municípios} returns a data.frame with 92 municipalities
  (código_ibge, município, macrorregião_saúde, região_saúde).

  \code{vigiar_rj_macrorregiões} returns the 9 health macro-regions.

  \code{vigiar_rj_regiões_saúde} returns the health regions.
}
\description{
  Official registry of the 92 Rio de Janeiro municipalities
  with SES-RJ health macro-regions.
}
\examples{
vigiar_rj_municípios()
vigiar_rj_macrorregiões()
}
