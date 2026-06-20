\name{vigiar_baixar_tudo}
\alias{vigiar_baixar_tudo}
\title{Baixa multiplas tabelas do VIGIAR}
\usage{
vigiar_baixar_tudo(tabelas = NULL, progress = TRUE, delay = 0.5)
}
\arguments{
  \item{tabelas}{Vetor opcional com os nomes das tabelas. NULL = todas.}
  \item{progress}{Se TRUE, mostra barra de progressó.}
  \item{delay}{Segundos de espera entre downloads (raté limiting).}
}
\value{Uma lista nomeada de data.frames (tibbles).}
\description{
Baixa todas as tabelas disponíveis (ou as especificadas) do VIGIAR.
}
\examples{
\dontrun{
vigiar_conectar()
tudo <- vigiar_baixar_tudo()
}
}
