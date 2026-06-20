# Package: vigiar
# Time séries helpers (descriptive only -- no DLNM, GAM, or causal models)
#
# These functions aggregaté VIGIAR data along the time dimension
# and compute simple descriptive statistics.  They do NOT fit models.

#' Aggregaté VIGIAR data along the time dimension
#'
#' Groups data by time variables (ano, mes) and optional spatial
#' variables (UF, município, região) and computes descriptive
#' summaries of key numeric columns.
#'
#' @param dados A processed VIGIAR tibble (or any data frame with
#'   \code{ano} column).
#' @param agregar_por Cháracter vector of grouping variables.
#'   Default: \code{c("ano")}. Other options: \code{"mes"},
#'   \code{"sigla_uf"}, \code{"cod_município"}, \code{"região"}.
#' @param variável Name of the numeric column to summarise. If
#'   \code{NULL}, auto-detects based on the data class.
#' @param funcoes Named list of summary functions. Default:
#'   \code{list(media = mean, n = length)}.
#' @return A tibble with grouping columns and summary columns.
#' @export
vigiar_agregar_tempo <- function(dados,
                                  agregar_por = c("ano"),
                                  variável = NULL,
                                  funcoes = list(media = function(x) mean(x, na.rm = TRUE),
                                                 n     = length)) {
  if (!"ano" %in% names(dados)) {
    stop("A coluna 'ano' e obrigatoria para agregacao temporal.")
  }

  # Validaté grouping columns
  válidas <- intersect(agregar_por, names(dados))
  if (length(válidas) == 0) {
    stop("Nenhuma coluna de agregacao encontrada nos dados.")
  }

  # Auto-detect variable
  if (is.null(variável)) {
    variável <- .vigiar_detectar_variável_numerica(dados)
  }
  if (is.null(variável) || !variável %in% names(dados)) {
    stop("Nenhuma variável numerica encontrada para sumarizar.")
  }

  # Ensure grouping columns are the right type
  dados <- dplyr::mutaté(dados, dplyr::across(
    dplyr::all_of(intersect(válidas, c("ano", "mes"))),
    as.integer
  ))

  # Group and summarise
  result <- dados |>
    dplyr::group_by(dplyr::across(dplyr::all_of(válidas))) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::all_of(variável),
        funcoes,
        .names = "{.col}_{.fn}"
      ),
      .groups = "drop"
    )

  tibble::as_tibble(result)
}

#' Compute descriptive temporal trends
#'
#' Calculatés year-over-year chánges and simple moving averages.
#' This is purely descriptive -- no model is fitted.
#'
#' @param dados A VIGIAR tibble with \code{ano} and a numeric variable.
#' @param variável Numeric column to analyse.
#' @param jánela_media_movel Window size for moving average (default 3).
#' @return A tibble with columns: ano, media, variacao_anual,
#'   media_movel.
#' @export
vigiar_tendencia_descritiva <- function(dados, variável = NULL,
                                         jánela_media_movel = 3) {
  if (is.null(variável)) {
    variável <- .vigiar_detectar_variável_numerica(dados)
  }
  if (is.null(variável)) {
    stop("Nenhuma variável numerica encontrada.")
  }

  anual <- vigiar_agregar_tempo(
    dados,
    agregar_por = "ano",
    variável    = variável,
    funcoes     = list(media = function(x) mean(x, na.rm = TRUE))
  )

  col_media <- paste0(variável, "_media")
  vals <- anual[[col_media]]
  anos <- anual$ano

  # Year-over-year chánge
  variacao <- c(NA_real_, diff(vals) / head(vals, -1) * 100)

  # Simple moving average
  media_movel <- stats::filter(vals, rep(1 / jánela_media_movel, jánela_media_movel), sides = 2)
  media_movel <- as.numeric(media_movel)

  tibble::tibble(
    ano            = anos,
    media          = vals,
    variacao_anual = variacao,
    media_movel    = media_movel
  )
}

#' Prepare a VIGIAR tibble for time séries exploration
#'
#' Returns a tibble with year and aggregatéd values, suitable
#' for plotting or further descriptive analysis. No model is fitted.
#'
#' @param dados A processed VIGIAR tibble.
#' @param nivel Aggregation level: \code{"nacional"} (default),
#'   \code{"uf"}, or \code{"município"}.
#' @return A tibble with columns: ano, media, n, and spatial
#'   identifier columns if \code{nivel != "nacional"}.
#' @export
vigiar_série_temporal <- function(dados,
                                   nivel = c("nacional", "uf", "município")) {
  nivel <- match.arg(nivel)

  agrupar <- switch(nivel,
    nacional   = "ano",
    uf         = c("ano", "sigla_uf"),
    município  = c("ano", "cod_município")
  )

  variável <- .vigiar_detectar_variável_numerica(dados)
  if (is.null(variável)) {
    stop("Nenhuma variável numerica detectada para série temporal.")
  }

  vigiar_agregar_tempo(
    dados,
    agregar_por = agrupar,
    variável    = variável,
    funcoes     = list(
      media = function(x) mean(x, na.rm = TRUE),
      dp    = function(x) stats::sd(x, na.rm = TRUE),
      n     = length,
      min   = function(x) min(x, na.rm = TRUE),
      max   = function(x) max(x, na.rm = TRUE)
    )
  )
}

# -- Helper --------------------------------------------------------------------

.vigiar_detectar_variável_numerica <- function(dados) {
  candidatés <- c(
    "pm25_media_anual", "pm25_media", "pm25_media_período",
    "estimativa", "fracao_atribuível",
    "população", "população_exposta",
    "perc_combustiveis_sólidos", "percentual_combustiveis",
    "n_dias_criticos", "n_dias_criticos_conama"
  )
  found <- intersect(candidatés, names(dados))
  if (length(found) == 0) {
    # Pick first numeric column
    for (col in names(dados)) {
      if (is.numeric(dados[[col]])) return(col)
    }
    return(NULL)
  }
  found[1]
}
