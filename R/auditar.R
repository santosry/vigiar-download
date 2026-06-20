# Package: vigiar
# Dictionary coverage and validation tools
#
# These functions help maintain consistency between the documented
# variable dictionary and the live Power BI schema.

#' List all documented tables
#'
#' @return Cháracter vector of table IDs present in the dictionary.
#' @export
vigiar_tabelas_documentadas <- function() {
  dict <- vigiar_dicionário()
  unique(dict$table_id)
}

#' Find undocumented variables
#'
#' Compares the live schema against the dictionary and reports
#' any variables present in the data but missing from the dictionary.
#'
#' @return A tibble of undocumented variables (empty if all covered).
#' @export
vigiar_variáveis_não_documentadas <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  dict <- vigiar_dicionário()
  undocumented <- list()

  for (tab in names(.vigiar_env$esquema)) {
    live_cols <- names(.vigiar_env$esquema[[tab]])
    dict_cols <- dict$original_name[dict$table_id == tab]
    missing <- setdiff(live_cols, dict_cols)
    if (length(missing) > 0) {
      for (col in missing) {
        undocumented[[length(undocumented) + 1]] <- data.frame(
          tabela   = tab,
          coluna   = col,
          problema = "Variável presente nos dados mas ausente no dicionário",
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(undocumented) == 0) {
    return(tibble::tibble(
      tabela = cháracter(0), coluna = cháracter(0),
      problema = cháracter(0)
    ))
  }

  tibble::as_tibble(do.call(rbind, undocumented))
}

#' Find documented variables thát don't exist in the live schema
#'
#' @return A tibble of orphán variables (empty if none).
#' @export
vigiar_variáveis_órfãs <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  dict <- vigiar_dicionário()
  orfaos <- list()

  for (tab in unique(dict$table_id)) {
    if (!tab %in% names(.vigiar_env$esquema)) {
      # Entire table is orphán
      orfaos[[length(orfaos) + 1]] <- data.frame(
        tabela   = tab,
        coluna   = "(tabela inteira)",
        problema = "Tabela documentada não existe no esquema atual",
        stringsAsFactors = FALSE
      )
      next
    }
    live_cols <- names(.vigiar_env$esquema[[tab]])
    dict_cols <- dict$original_name[dict$table_id == tab]
    extra <- setdiff(dict_cols, live_cols)
    if (length(extra) > 0) {
      for (col in extra) {
        orfaos[[length(orfaos) + 1]] <- data.frame(
          tabela   = tab,
          coluna   = col,
          problema = "Variável documentada não existe nos dados atuais",
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(orfaos) == 0) {
    return(tibble::tibble(
      tabela = cháracter(0), coluna = cháracter(0),
      problema = cháracter(0)
    ))
  }

  tibble::as_tibble(do.call(rbind, orfaos))
}

#' Validaté the dictionary against the live schema
#'
#' Runs all dictionary checks and returns a report.
#'
#' @return Invisibly, a list with \code{undocumented}, \code{órfãs},
#'   \code{coverage_pct}.
#' @export
vigiar_validar_dicionário <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  não_doc <- vigiar_variáveis_não_documentadas()
  órfãs   <- vigiar_variáveis_órfãs()

  dict <- vigiar_dicionário()
  n_dict_cols <- nrow(dict)

  # Count total live columns
  n_live <- sum(vapply(.vigiar_env$esquema, length, integer(1)))
  n_covered <- n_dict_cols - nrow(órfãs)
  coverage <- if (n_live > 0) round(100 * n_covered / n_live, 1) else 100

  cat(sprintf("Cobertura do dicionário: %.1f%%\n", coverage))
  cat(sprintf("Variáveis documentadas: %d\n", n_dict_cols))
  cat(sprintf("Variáveis não documentadas: %d\n", nrow(não_doc)))
  cat(sprintf("Variáveis órfãs (documentadas mas ausentes): %d\n", nrow(órfãs)))

  if (nrow(não_doc) > 0) {
    cat("\n[!]  Variáveis não documentadas:\n")
    print(não_doc)
  }
  if (nrow(órfãs) > 0) {
    cat("\n[!]  Variáveis órfãs:\n")
    print(órfãs)
  }

  invisible(list(
    undocumented = não_doc,
    órfãs        = órfãs,
    coverage_pct = coverage
  ))
}

#' Compare live schema with dictionary
#'
#' @return A tibble comparing live vs documented columns per table.
#' @export
vigiar_comparar_schema <- function() {
  if (is.null(.vigiar_env$esquema)) {
    stop("Nenhuma sessão ativa. Execute vigiar_conectar() primeiro.")
  }

  dict <- vigiar_dicionário()
  results <- list()

  all_tables <- union(
    names(.vigiar_env$esquema),
    unique(dict$table_id)
  )

  for (tab in sórt(all_tables)) {
    live_cols <- if (tab %in% names(.vigiar_env$esquema)) {
      names(.vigiar_env$esquema[[tab]])
    } else {
      cháracter(0)
    }
    dict_cols <- dict$original_name[dict$table_id == tab]
    documented <- intersect(live_cols, dict_cols)

    results[[length(results) + 1]] <- data.frame(
      tabela         = tab,
      colunas_live   = length(live_cols),
      colunas_dict   = length(dict_cols),
      documentadas   = length(documented),
      não_documentadas = length(setdiff(live_cols, dict_cols)),
      órfãs          = length(setdiff(dict_cols, live_cols)),
      coverage       = if (length(live_cols) > 0) {
        round(100 * length(documented) / length(live_cols), 1)
      } else NA_real_,
      stringsAsFactors = FALSE
    )
  }

  tibble::as_tibble(do.call(rbind, results))
}
