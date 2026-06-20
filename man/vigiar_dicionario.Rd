\name{vigiar_dicionário}
\alias{vigiar_dicionário}
\alias{vigiar_variáveis}
\alias{vigiar_descrever_variável}
\alias{vigiar_convencoes}
\alias{vigiar_schema}
\title{Query the VIGIAR variable dictionary}
\usage{
vigiar_dicionário()
vigiar_variáveis(dominio = c("pm25", "população_exposta", "indicadores_saúde",
  "fracao_atribuível", "exposição_indoor", "municípios", "all"))
vigiar_descrever_variável(dominio, variável)
vigiar_convencoes()
vigiar_schema(dominio = "all")
}
\arguments{
  \item{dominio}{Data domain. One of \code{"pm25"}, \code{"população_exposta"},
    \code{"indicadores_saúde"}, \code{"fracao_atribuível"},
    \code{"exposição_indoor"}, \code{"municípios"}, or \code{"all"}.}
  \item{variável}{Standard variable name.}
}
\value{
  \code{vigiar_dicionário} returns the complete variable dictionary as a tibble.

  \code{vigiar_variáveis} returns a subset for a specific domain.

  \code{vigiar_descrever_variável} prints details for one variable.

  \code{vigiar_schema} returns a schema overview for a domain.
}
\description{
  Functions to explore the VIGIAR data dictionary, which documents
  every variable: original name, standardised name, type, description,
  unit, allowed values, and processing rules.
}
\examples{
\dontrun{
vigiar_dicionário()
vigiar_variáveis("pm25")
vigiar_descrever_variável("pm25", "pm25_media_anual")
vigiar_schema("indicadores_saúde")
}
}
