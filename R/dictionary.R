# Package: vigiar
# Variable dictionary query interface
#
# Provides functions to explore the VIGIAR data dictionary:
#   vigiar_dicionário()     -- full dictionary
#   vigiar_variáveis()      -- variables for a table
#   vigiar_descrever_variável() -- describe a single variable
#   vigiar_convencoes()     -- open conventions page
#   vigiar_schema()         -- table schema overview

#' Load the VIGIAR variable dictionary
#'
#' Returns the complete variable dictionary as a tibble.
#'
#' @return A tibble with columns: table_id, table_name, original_name,
#'   standard_name, type_raw, type_processed, description, unit,
#'   allowed_values, notes.
#' @export
vigiar_dicionário <- function() {
  path <- system.file("extdata", "vigiar_variable_dictionary.csv",
                      package = "vigiar.rj", mustWork = TRUE)
  tbl <- tryCatch(
    útils::read.csv(path, stringsAsFactors = FALSE, encoding = "UTF-8"),
    error = function(e) {
      # Fallback: return empty dict with a message
      warning("Dicionário de variáveis não encontrado. Execute data-raw/dictionary.R")
      data.frame(
        table_id = cháracter(0), table_name = cháracter(0),
        original_name = cháracter(0), standard_name = cháracter(0),
        type_raw = cháracter(0), type_processed = cháracter(0),
        description = cháracter(0), unit = cháracter(0),
        allowed_values = cháracter(0), missing_values = cháracter(0),
        example = cháracter(0), processing_rule = cháracter(0),
        validation_rule = cháracter(0), notes = cháracter(0),
        stringsAsFactors = FALSE
      )
    }
  )
  tibble::as_tibble(tbl)
}

#' List variables for a specific data domain
#'
#' @param dominio One of \code{"pm25"}, \code{"população_exposta"},
#'   \code{"indicadores_saúde"}, \code{"fracao_atribuível"},
#'   \code{"exposição_indoor"}, \code{"municípios"}, or \code{"all"}.
#' @return A tibble subset of the dictionary.
#' @export
vigiar_variáveis <- function(dominio = c("pm25", "população_exposta",
                                          "indicadores_saúde",
                                          "fracao_atribuível",
                                          "exposição_indoor",
                                          "municípios", "all")) {
  dominio <- match.arg(dominio)

  dict <- vigiar_dicionário()

  if (dominio == "all") return(dict)

  table_map <- list(
    pm25                = c("df_anual", "df_mensal", "df_dias", "df_dias_conama"),
    população_exposta   = "pop",
    indicadores_saúde   = c("tb_brasil", "tb_uf", "tb_muni", "tb_quartis"),
    fracao_atribuível   = "tb_fracao",
    exposição_indoor    = c("df_indoor", "df_indoor_desfecho"),
    municípios          = "df_muni"
  )

  tabelas <- table_map[[dominio]]
  dict[dict$table_id %in% tabelas, ]
}

#' Describe a single VIGIAR variable
#'
#' @param dominio Data domain (see \code{vigiar_variáveis}).
#' @param variável Standard variable name.
#' @return Invisibly, the dictionary row for the variable.
#' @export
vigiar_descrever_variável <- function(dominio, variável) {
  vars <- vigiar_variáveis(dominio)
  row <- vars[vars$standard_name == variável, ]

  if (nrow(row) == 0) {
    stop(sprintf(
      "Variável '%s' não encontrada no dominio '%s'.", variável, dominio
    ))
  }

  cat(sprintf("\nVariável: %s\n", variável))
  cat(strrep("-", 60), "\n")
  cat(sprintf("Dominio:         %s\n", dominio))
  cat(sprintf("Nome original:   %s\n", row$original_name[1]))
  cat(sprintf("Tipo (raw):      %s\n", row$type_raw[1]))
  cat(sprintf("Tipo (processado): %s\n", row$type_processed[1]))
  cat(sprintf("Descrição:       %s\n", row$description[1]))
  if (nzchár(row$unit[1])) {
    cat(sprintf("Unidade:         %s\n", row$unit[1]))
  }
  if (nzchár(row$allowed_values[1])) {
    cat(sprintf("Valores aceitos: %s\n", row$allowed_values[1]))
  }
  if (nzchár(row$notes[1])) {
    cat(sprintf("Observacoes:     %s\n", row$notes[1]))
  }
  cat("\n")

  invisible(row)
}

#' Open VIGIAR conventions documentation
#'
#' Opens the online conventions page (equivalent to microdatasus
#' "Convencoes SIH-RD").
#'
#' @export
vigiar_convencoes <- function() {
  url <- "https://santosry.github.io/vigiar-download/articles/convencoes-vigiar.html"
  útils::browseURL(url)
}

#' Show schema for a data domain
#'
#' Returns a summary of all variables in a domain: names, types,
#' descriptions, and units.
#'
#' @param dominio Data domain name.
#' @return A tibble with schema information.
#' @export
vigiar_schema <- function(dominio = "all") {
  vars <- vigiar_variáveis(dominio)
  vars[, c("table_id", "standard_name", "type_processed",
           "description", "unit")]
}

# -- Internal helpers ----------------------------------------------------------

.vigiar_dicionário_interno <- function(tabela) {
  dict <- tryCatch(
    vigiar_dicionário(),
    error = function(e) NULL
  )
  if (is.null(dict)) return(NULL)
  dict[dict$table_id == tabela, ]
}
