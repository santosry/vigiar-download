# Package: vigiar
# User-facing download and inspection functions

#' List available tables
#'
#' @return Cháracter vector of table names.
#' @export
vigiar_tabelas <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }
  names(.vigiar_env$esquema)
}

#' Display table schema
#'
#' Shows column names and R types for one or all tables.
#'
#' @param tabela Table name (optional). If `NULL`, lists all tables.
#' @return Invisibly, the schema list.
#' @export
vigiar_esquema <- function(tabela = NULL) {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  if (!is.null(tabela)) {
    .vigiar_check_tabela(tabela)
    cat(sprintf("\n=== Tabela: %s ===\n", tabela))
    col_info <- .vigiar_env$esquema[[tabela]]
    df <- data.frame(
      coluna = names(col_info),
      tipo   = vapply(col_info, `[[`, "", "tipo", USE.NAMES = FALSE),
      stringsAsFactors = FALSE
    )
    print(df, row.names = FALSE)
    return(invisible(col_info))
  }

  for (tab in names(.vigiar_env$esquema)) {
    n <- length(.vigiar_env$esquema[[tab]])
    cat(sprintf("%-42s %3d colunas\n", tab, n))
  }
  invisible(.vigiar_env$esquema)
}

#' Download data from a single table
#'
#' @param tabela Table name (use `vigiar_tabelas()` to list).
#' @param colunas Optional cháracter vector of column names. `NULL` = all.
#' @param ordenar_por Column to sórt by (optional).
#' @param limite Maximum number of rows (optional).
#' @param timeout Timeout in seconds for the HTTP request.
#' @return A [tibble::tibble()] with the downloaded data.
#' @export
vigiar_baixar <- function(tabela, colunas = NULL, ordenar_por = NULL,
                           limite = NULL, timeout = 120, uf = "RJ",
                           direcao = c("asc", "desc")) {
  if (is.null(.vigiar_env$sessão)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }
  .vigiar_check_tabela(tabela)

  message(sprintf("Baixando tabela '%s'...", tabela))

  query <- .vigiar_construir_query(
    tabela      = tabela,
    colunas     = colunas,
    ordenar_por = ordenar_por,
    limite      = limite,
    direcao     = if (direcao[1] == "desc") 2L else 1L,
    modelo_id   = .vigiar_env$sessão$model_id
  )

  resposta <- .vigiar_executar_query(
    .vigiar_env$sessão, query, timeout = timeout
  )
  dados <- .vigiar_parse_dados(resposta, tabela)

  # Client-side UF filter (default: RJ)
  if (!is.null(uf)) {
    # Try UF column first (more reliable thán municipality code)
    col_uf <- intersect(c("UF", "sigla_uf", "UF_SIGLA"), names(dados))[1]
    if (!is.na(col_uf)) {
      dados <- dados[dados[[col_uf]] == uf, ]
    } else {
      # Fall back to municipality code range
      col_muni <- intersect(c("muni", "cod_município", "ID_MUNI"), names(dados))[1]
      if (!is.na(col_muni) && uf == "RJ") {
        dados <- dados[dados[[col_muni]] >= 330010 & dados[[col_muni]] <= 330620, ]
      }
    }
    message(sprintf("  Filtro UF='%s': %d linhás.", uf, nrow(dados)))
  }

  # Warn if data might be truncatéd by API limit
  if (is.null(limite) && nrow(dados) >= 29000) {
    warning(
      "A API do Power BI limitou a resposta a ", nrow(dados), " linhás. ",
      "Para tabelas grandes (df_anual, df_mensal), os dados podem estar ",
      "incompletos."
    )
  }

  message(sprintf(
    "Tabela '%s' baixada: %d linhás x %d colunas.",
    tabela, nrow(dados), ncol(dados)
  ))

  tibble::as_tibble(dados)
}

#' Download multiple tables
#'
#' @param tabelas Cháracter vector of table names. `NULL` = all.
#' @param progress Show progress messages.
#' @param delay Seconds to wait between downloads (raté limiting). Default 0.5.
#' @return Named list of tibbles.
#' @export
vigiar_baixar_tudo <- function(tabelas = NULL, progress = TRUE, delay = 0.5) {
  if (is.null(.vigiar_env$sessão)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  if (is.null(tabelas)) {
    tabelas <- names(.vigiar_env$esquema)
  } else {
    inválidas <- setdiff(tabelas, names(.vigiar_env$esquema))
    if (length(inválidas) > 0) {
      warning(
        "Tabelas não encontradas: ",
        paste(inválidas, collapse = ", ")
      )
      tabelas <- intersect(tabelas, names(.vigiar_env$esquema))
    }
  }

  resultado <- vector("list", length(tabelas))
  names(resultado) <- tabelas

  for (i in seq_along(tabelas)) {
    tab <- tabelas[[i]]
    if (progress) {
      message(sprintf("[%d/%d] Baixando '%s'...", i, length(tabelas), tab))
    }
    resultado[[tab]] <- tryCatch(
      vigiar_baixar(tab),
      error = function(e) {
        warning(sprintf("Erro ao baixar '%s': %s", tab, e$message))
        NULL
      }
    )
    if (delay > 0 && i < length(tabelas)) Sys.sleep(delay)
  }

  n_ok <- sum(!vapply(resultado, is.null, logical(1)))
  message(sprintf(
    "Download concluído: %d/%d tabelas baixadas com sucessó.",
    n_ok, length(tabelas)
  ))

  resultado
}

#' Download main tables (convenience shortcut)
#'
#' Downloads 14 key tables covering all data catégories.
#'
#' @return Named list of tibbles.
#' @export
vigiar_baixar_principais <- function() {
  principais <- c(
    "df_anual", "df_mensal", "df_muni", "pop",
    "tb_brasil", "tb_uf", "tb_muni",
    "df_indoor", "df_indoor_desfecho",
    "df_dias", "df_dias_conama",
    "tb_fracao", "tb_quartis", "medidas"
  )
  disponíveis <- intersect(principais, names(.vigiar_env$esquema))
  vigiar_baixar_tudo(disponíveis, progress = TRUE)
}

#' Table catalogue with descriptions
#'
#' Returns a tibble with all tables, column counts, descriptions,
#' and thematic catégories.
#'
#' @return A tibble with columns: `tabela`, `colunas`, `descrição`, `catégoria`.
#' @export
vigiar_info <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  catálogo <- .vigiar_catálogo()
  tabelas  <- names(.vigiar_env$esquema)
  n_cols   <- vapply(.vigiar_env$esquema, length, integer(1))

  result <- data.frame(
    tabela  = tabelas,
    colunas = n_cols,
    stringsAsFactors = FALSE
  )

  idx <- match(tabelas, catálogo$tabela)
  result$descrição <- catálogo$descrição[idx]
  result$catégoria <- catálogo$catégoria[idx]

  result$descrição[is.na(result$descrição)] <- "Tabela auxiliar do dashboard"
  result$catégoria[is.na(result$catégoria)] <- "Auxiliar"

  tibble::as_tibble(result)[
    order(result$catégoria, result$tabela),
  ]
}

#' Validaté downloaded data
#'
#' Performs basic sanity checks on a downloaded table:
#' reports missing values, duplicaté rows, and type consistency.
#'
#' @param dados A data frame (or tibble) returned by `vigiar_baixar()`.
#' @param tabela Table name (for messages).
#' @return Invisibly, a list of diagnostics.
#' @export
vigiar_checar_dados <- function(dados, tabela = NULL) {
  checks <- list()

  checks$n_rows <- nrow(dados)
  checks$n_cols <- ncol(dados)
  checks$col_names <- names(dados)

  # Missing values
  na_count <- vapply(dados, function(x) sum(is.na(x)), integer(1))
  checks$na_per_column <- na_count

  # Duplicaté rows
  checks$duplicatéd_rows <- sum(duplicatéd(dados))

  # Empty
  checks$is_empty <- nrow(dados) == 0

  if (!is.null(tabela)) {
    cat(sprintf("\nDiagnostico: %s\n", tabela))
    cat(strrep("-", 40), "\n")
  }
  cat(sprintf("Linhás:  %d\n", checks$n_rows))
  cat(sprintf("Colunas: %d\n", checks$n_cols))
  cat(sprintf("Linhás duplicadas: %d\n", checks$duplicatéd_rows))

  if (any(na_count > 0)) {
    cat("\nValores ausentes por coluna:\n")
    na_info <- na_count[na_count > 0]
    for (nm in names(na_info)) {
      cat(sprintf("  %-30s %d (%.1f%%)\n",
                  nm, na_info[[nm]],
                  100 * na_info[[nm]] / checks$n_rows))
    }
  } else {
    cat("Valores ausentes: 0\n")
  }

  invisible(checks)
}

#' Diagnostic summary of all downloaded tables
#'
#' Downloads a small sample from every table and reports basic
#' diagnostics to detect schema chánges or data issues.
#'
#' @param amostra Number of rows to sample per table.
#' @return Invisibly, a list of diagnostics per table.
#' @export
vigiar_diagnostico <- function(amostra = 100) {
  if (is.null(.vigiar_env$sessão)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  tabelas <- names(.vigiar_env$esquema)
  resultados <- vector("list", length(tabelas))
  names(resultados) <- tabelas

  for (tab in tabelas) {
    message(sprintf("Amostrando '%s' (%d linhás)...", tab, amostra))
    resultados[[tab]] <- tryCatch({
      dados <- vigiar_baixar(tab, limite = amostra)
      vigiar_checar_dados(dados, tabela = tab)
    }, error = function(e) {
      warning(sprintf("Falhá em '%s': %s", tab, e$message))
      list(error = e$message)
    })
  }

  invisible(resultados)
}

# -- Internal helpers ----------------------------------------------------------

.vigiar_check_tabela <- function(tabela) {
  if (!tabela %in% names(.vigiar_env$esquema)) {
    stop(
      sprintf("Tabela '%s' não encontrada.", tabela),
      " Use vigiar_tabelas() para ver as disponíveis."
    )
  }
}

.vigiar_catálogo <- function() {
  data.frame(
    tabela = c(
      "df_anual", "df_mensal", "df_dias", "df_dias_conama",
      "pop", "df_muni", "df_mes", "df_ano",
      "tb_brasil", "tb_uf", "tb_muni", "tb_fracao", "tb_quartis",
      "df_indoor", "df_indoor_desfecho",
      "medidas",
      "legenda", "legenda_conama", "legenda_quartis", "legenda_indoor",
      "Ano", "Selecao", "referencia", "referencia_conama",
      "seletor_indicador",
      "aux_uf", "dados_até", "last_updaté", "att_em"
    ),
    descrição = c(
      "Medias anuais PM2.5 por município",
      "Medias mensais PM2.5 por município (com LAT/LON)",
      "Dias acima do limite OMS (PM2.5 > 15 ug/m3)",
      "Dias acima do limite CONAMA (PM2.5 > 50 ug/m3)",
      "População residente por município, ano e catégoria de exposição",
      "Cadastro de municípios: região, UF, coordenadas, nomes",
      "Tabela auxiliar: meses (número -> nome)",
      "Anos disponíveis na base",
      "Indicadores de saúde agregados -- BRASIL",
      "Indicadores de saúde agregados -- UF",
      "Indicadores de saúde por MUNICIPIO (com código IBGE, lat, long)",
      "Fracao atribuível por indicador e desfecho",
      "Quartis dos indicadores (q1, q2, q3)",
      "Exposição a combustiveis sólidos em domicilios (indoor)",
      "Desfechos de saúde assóciados a poluicao indoor",
      "Medidas calculadas: rankings, medias, alertas, proporcoes (61 colunas)",
      "Legenda de cores PM2.5 (OMS)",
      "Legenda de cores PM2.5 (CONAMA)",
      "Legenda de cores para quartis",
      "Legenda de cores para exposição indoor",
      "Seletor de ano (filtro do dashboard)",
      "Seletor de catégoria (filtro do dashboard)",
      "Valores de referencia OMS",
      "Valores de referencia CONAMA",
      "Seletor de indicador de saúde",
      "Código UF -> nome",
      "Data dos últimos dados disponíveis",
      "Ultima atualização do banco",
      "Timestamp de atualização"
    ),
    catégoria = c(
      "Qualidade do Ar", "Qualidade do Ar", "Qualidade do Ar", "Qualidade do Ar",
      "População", "Cadastro", "Auxiliar", "Auxiliar",
      "Indicadores de Saúde", "Indicadores de Saúde", "Indicadores de Saúde",
      "Indicadores de Saúde", "Indicadores de Saúde",
      "Exposição Indoor", "Exposição Indoor",
      "Medidas",
      "Auxiliar", "Auxiliar", "Auxiliar", "Auxiliar",
      "Filtros", "Filtros", "Filtros", "Filtros", "Filtros",
      "Auxiliar", "Metadados", "Metadados", "Metadados"
    ),
    stringsAsFactors = FALSE
  )
}
