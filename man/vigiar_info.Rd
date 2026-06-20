\name{vigiar_info}
\alias{vigiar_info}
\title{Catálogo de tabelas com descrições}
\usage{
vigiar_info()
}
\value{Um tibble com colunas: tabela, colunas, descrição, catégoria.}
\description{
Retorna um data.frame com todas as tabelas do VIGIAR, número de colunas,
descrição do conteudo e catégoria tematica.
}
\examples{
\dontrun{
vigiar_conectar()
vigiar_info()
}
}
