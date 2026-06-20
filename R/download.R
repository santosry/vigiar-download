# Package: vigiar
# Funções de download para o usuário final

#' Lista as tabelas disponíveis no dashboard VIGIAR
#'
#' @return Vetor de caracteres com os nomes das tabelas.
#' @export
vigiar_tabelas <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }
  names(.vigiar_env$esquema)
}

#' Exibe o esquema das tabelas VIGIAR
#'
#' Mostra a estrutura de cada tabela: nomes das colunas e seus tipos.
#'
#' @param tabela Nome da tabela (opcional). Se NULL, mostra todas.
#' @return Invisivelmente, uma lista com o esquema.
#' @export
vigiar_esquema <- function(tabela = NULL) {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  if (!is.null(tabela)) {
    if (!tabela %in% names(.vigiar_env$esquema)) {
      stop(sprintf("Tabela '%s' não encontrada. Use vigiar_tabelas() para ver as disponíveis.", tabela))
    }

    cat(sprintf("\n=== Tabela: %s ===\n", tabela))
    col_df <- do.call(rbind, lapply(names(.vigiar_env$esquema[[tabela]]), function(col) {
      data.frame(
        coluna = col,
        tipo = .vigiar_env$esquema[[tabela]][[col]]$tipo,
        stringsAsFactors = FALSE
      )
    }))
    print(col_df, row.names = FALSE)
    return(invisible(.vigiar_env$esquema[[tabela]]))
  }

  # Mostrar todas
  for (tab in names(.vigiar_env$esquema)) {
    n_cols <- length(.vigiar_env$esquema[[tab]])
    cat(sprintf("%-40s %3d colunas\n", tab, n_cols))
  }

  invisible(.vigiar_env$esquema)
}

#' Baixa dados de uma tabela específica do VIGIAR
#'
#' @param tabela Nome da tabela (use \code{vigiar_tabelas()} para listar)
#' @param colunas Vetor opcional com nomes das colunas. NULL = todas.
#' @param ordenar_por Coluna para ordenação (opcional)
#' @param limite Número máximo de linhas (opcional)
#' @return Um \code{data.frame} (tibble) com os dados da tabela.
#' @export
#'
#' @examples
#' \dontrun{
#' # Conectar
#' vigiar_conectar()
#'
#' # Baixar dados anuais de PM2.5
#' df_anual <- vigiar_baixar("df_anual")
#'
#' # Baixar apenas algumas colunas
#' df_mensal <- vigiar_baixar("df_mensal",
#'   colunas = c("ano", "UF", "Município", "pm25"))
#'
#' # Com limite de linhas
#' df_muni <- vigiar_baixar("df_muni", limite = 100)
#' }
vigiar_baixar <- function(tabela, colunas = NULL, ordenar_por = NULL, limite = NULL) {
  if (is.null(.vigiar_env$sessao)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  if (!tabela %in% names(.vigiar_env$esquema)) {
    stop(sprintf("Tabela '%s' não encontrada. Use vigiar_tabelas() para ver as disponíveis.", tabela))
  }

  message(sprintf("Baixando tabela '%s'...", tabela))

  query <- .vigiar_construir_query(
    tabela = tabela,
    colunas = colunas,
    ordenar_por = ordenar_por,
    limite = limite,
    modelo_id = .vigiar_env$sessao$model_id
  )

  resposta <- .vigiar_executar_query(.vigiar_env$sessao, query)
  dados <- .vigiar_parse_dados(resposta, tabela)

  message(sprintf("Tabela '%s' baixada: %d linhas x %d colunas.",
                  tabela, nrow(dados), ncol(dados)))

  tibble::as_tibble(dados)
}

#' Baixa todas as tabelas disponíveis do VIGIAR
#'
#' @param tabelas Vetor opcional com os nomes das tabelas. NULL = todas.
#' @param progresso Se TRUE, mostra barra de progresso.
#' @return Uma lista nomeada de data.frames (tibbles).
#' @export
vigiar_baixar_tudo <- function(tabelas = NULL, progresso = TRUE) {
  if (is.null(.vigiar_env$sessao)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  if (is.null(tabelas)) {
    tabelas <- names(.vigiar_env$esquema)
  } else {
    invalidas <- setdiff(tabelas, names(.vigiar_env$esquema))
    if (length(invalidas) > 0) {
      warning("Tabelas não encontradas: ", paste(invalidas, collapse = ", "))
      tabelas <- intersect(tabelas, names(.vigiar_env$esquema))
    }
  }

  resultado <- list()

  for (i in seq_along(tabelas)) {
    tab <- tabelas[i]
    if (progresso) {
      message(sprintf("[%d/%d] Baixando '%s'...", i, length(tabelas), tab))
    }
    resultado[[tab]] <- tryCatch(
      vigiar_baixar(tab),
      error = function(e) {
        warning(sprintf("Erro ao baixar tabela '%s': %s", tab, e$message))
        NULL
      }
    )
  }

  n_ok <- sum(!sapply(resultado, is.null))
  message(sprintf("Download concluído: %d/%d tabelas baixadas com sucesso.",
                  n_ok, length(tabelas)))

  resultado
}

#' Verifica se a sessão VIGIAR ainda está ativa
#'
#' @return TRUE se a sessão estiver ativa, FALSE caso contrário.
#' @export
vigiar_sessao_ativa <- function() {
  !is.null(.vigiar_env$sessao)
}

#' Encerra a sessão VIGIAR e limpa o cache
#'
#' @export
vigiar_desconectar <- function() {
  .vigiar_env$sessao <- NULL
  .vigiar_env$esquema <- NULL
  message("Sessão VIGIAR encerrada.")
}

#' Baixa as tabelas principais de uma vez (atalho prático)
#'
#' Baixa as tabelas mais relevantes: df_anual, df_mensal, df_muni,
#' pop, tb_brasil, tb_uf, tb_muni, df_indoor, df_dias.
#'
#' @return Lista nomeada com as tabelas principais.
#' @export
vigiar_baixar_principais <- function() {
  principais <- c(
    "df_anual", "df_mensal", "df_muni", "pop",
    "tb_brasil", "tb_uf", "tb_muni",
    "df_indoor", "df_indoor_desfecho",
    "df_dias", "df_dias_conama"
  )

  disponiveis <- intersect(principais, names(.vigiar_env$esquema))
  vigiar_baixar_tudo(disponiveis, progresso = TRUE)
}
