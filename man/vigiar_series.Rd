\name{vigiar_serie_temporal}
\alias{vigiar_serie_temporal}
\alias{vigiar_tendencia_descritiva}
\alias{vigiar_agregar_tempo}
\title{Descriptive time series helpers}
\usage{
vigiar_serie_temporal(dados, nivel = c("nacional", "uf", "municipio"))
vigiar_tendencia_descritiva(dados, variavel = NULL, janela_media_movel = 3)
vigiar_agregar_tempo(dados, agregar_por = c("ano"), variavel = NULL,
  funcoes = list(media = function(x) mean(x, na.rm = TRUE), n = length))
}
\arguments{
  \item{dados}{A processed VIGIAR tibble with \code{ano} column.}
  \item{nivel}{Aggregation level.}
  \item{variavel}{Numeric column name (auto-detected if \code{NULL}).}
  \item{janela_media_movel}{Window size for moving average.}
  \item{agregar_por}{Grouping variables.}
  \item{funcoes}{Named list of summary functions.}
}
\value{
  A tibble with aggregated time series data.
}
\description{
  These functions aggregate VIGIAR data along the time dimension
  and compute simple descriptive statistics. No models (DLNM, GAM,
  ARIMA) are fitted — these are purely exploratory.
}
\examples{
\dontrun{
vigiar_conectar()
pm25 <- vigiar_baixar("df_anual") |> process_pm25()
serie <- vigiar_serie_temporal(pm25, nivel = "nacional")
tendencia <- vigiar_tendencia_descritiva(pm25)
}
}
