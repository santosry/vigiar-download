\name{vigiar_baixar_tudo}
\alias{vigiar_baixar_tudo}
\title{Baixa multiplas tabelas do VIGIAR}
\usage{
vigiar_baixar_tudo(tabelas = NULL, progress = TRUE)
}
\arguments{
  \item{tabelas}{Vetor opcional com os nomes das tabelas. NULL = todas.}
  \item{progress}{Se TRUE, mostra barra de progresso.}
}
\value{Uma lista nomeada de data.frames (tibbles).}
\description{
Baixa todas as tabelas disponiveis (ou as especificadas) do VIGIAR.
}
\examples{
\dontrun{
vigiar_conectar()
tudo <- vigiar_baixar_tudo()
}
}
