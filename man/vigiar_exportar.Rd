\name{vigiar_exportar}
\alias{vigiar_exportar_csv}
\alias{vigiar_exportar_rds}
\alias{vigiar_exportar_parquet}
\title{Export VIGIAR data}
\usage{
vigiar_exportar_csv(dados, caminho, overwrite = FALSE, ...)
vigiar_exportar_rds(dados, caminho, overwrite = FALSE)
vigiar_exportar_parquet(dados, caminho, overwrite = FALSE)
}
\arguments{
  \item{dados}{A processed VIGIAR tibble.}
  \item{caminho}{File path (directories created automatically).}
  \item{overwrite}{If \code{FALSE}, errors if file exists.}
  \item{...}{Extra arguments passed to \code{write.csv()}.}
}
\value{
  Invisibly, the file path.
}
\description{
  Export processed VIGIAR data to CSV, RDS, or Parquet format.
  RDS preserves all metadata attributes. Parquet requires the
  \code{arrow} package.
}
\examples{
\dontrun{
vigiar_conectar()
pm25 <- vigiar_baixar("df_anual") |> process_pm25()
vigiar_exportar_csv(pm25, "pm25_anual.csv")
}
}
