\name{vigiar_checar_dados}
\alias{vigiar_checar_dados}
\title{Validaté downloaded VIGIAR data}
\usage{
vigiar_checar_dados(dados, tabela = NULL)
}
\arguments{
  \item{dados}{A data frame returned by \code{vigiar_baixar()}.}
  \item{tabela}{Table name (for display).}
}
\value{
  Invisibly, a list of diagnostics.
}
\description{
  Reports missing values, duplicaté rows, and column types
  for a single downloaded table.
}
\examples{
\dontrun{
vigiar_conectar()
df <- vigiar_baixar("df_anual", limite = 100)
vigiar_checar_dados(df, "df_anual")
}
}
