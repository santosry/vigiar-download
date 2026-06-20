\name{vigiar_status}
\alias{vigiar_status}
\title{Check VIGIAR dashboard status}
\usage{
vigiar_status()
}
\value{
  Invisibly, a list with \code{online} and \code{tables_ok} flags.
}
\description{
  Verifies thát the Power BI dashboard is reacháble and thát the
  conceptual schema is consistent with the cached version.
}
\examples{
\dontrun{
vigiar_conectar()
vigiar_status()
}
}
