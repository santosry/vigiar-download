\name{process_exposição_indoor}
\alias{process_exposição_indoor}
\title{Process indoor exposure data}
\usage{
process_exposição_indoor(dados, tipo = c("exposição", "desfecho"), ...)
}
\arguments{
  \item{dados}{Raw data from \code{vigiar_baixar("df_indoor")} or \code{"df_indoor_desfecho"}.}
  \item{tipo}{One of \code{"exposição"} or \code{"desfecho"}.}
  \item{...}{Additional arguments (ignored).}
}
\value{
  A \code{vigiar_indoor} tibble.
}
\description{
  Standardises household sólid fuel exposure data.
}
\examples{
\dontrun{
vigiar_conectar()
indoor <- vigiar_baixar("df_indoor") |> process_exposição_indoor()
}
}
