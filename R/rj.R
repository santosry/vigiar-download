# Package: vigiar
# Rio de Janeiro staté - official municipality registry
#
# Source: IBGE 2022 + SES-RJ health regions
# 92 municípios, 9 macrorregiões de saúde

# ---- RJ Municipality Registry ------------------------------------------------

RJ_MUNICIPIOS <- data.frame(
  código_ibge = c(
    330010, 330015, 330020, 330022, 330023, 330025, 330030, 330033,
    330040, 330045, 330050, 330060, 330070, 330080, 330090, 330093,
    330095, 330100, 330110, 330115, 330120, 330130, 330140, 330150,
    330160, 330170, 330180, 330185, 330187, 330190, 330200, 330205,
    330210, 330220, 330225, 330227, 330230, 330240, 330245, 330250,
    330260, 330270, 330280, 330285, 330290, 330300, 330310, 330320,
    330330, 330340, 330350, 330360, 330370, 330380, 330385, 330390,
    330395, 330400, 330410, 330411, 330412, 330414, 330415, 330420,
    330430, 330440, 330450, 330452, 330455, 330460, 330470, 330475,
    330480, 330490, 330500, 330510, 330513, 330515, 330520, 330530,
    330540, 330550, 330555, 330560, 330570, 330575, 330580, 330590,
    330600, 330610, 330615, 330620),
  município = c(
    "Angra dos Reis", "Aperibe", "Araruama", "Areal",
    "Armacao dos Buzios", "Arraial do Cabo", "Barra do Pirai", "Italva",
    "Barra Mansa", "Belford Roxo", "Bom Jardim", "Bom Jesus do Itabapoana",
    "Cabo Frio", "Cachoeiras de Macacu", "Cambuci", "Campos dos Goytacazes",
    "Cantagalo", "Carapebus", "Cardosó Moreira", "Carmo",
    "Casimiro de Abreu", "Comendador Levy Gasparian", "Conceicao de Macabu", "Cordeiro",
    "Duas Barras", "Duque de Caxias", "Engenheiro Paulo de Frontin", "Guapimirim",
    "Iguaba Grande", "Itaborai", "Itaguai", "Itaocara",
    "Itaperuna", "Itatiaia", "Japeri", "Laje do Muriae",
    "Macae", "Macuco", "Mage", "Mangaratiba",
    "Marica", "Mendes", "Mesquita", "Miguel Pereira",
    "Miracema", "Natividade", "Nilopolis", "Niteroi",
    "Nova Friburgo", "Nova Iguacu", "Paracambi", "Paraiba do Sul",
    "Paraty", "Paty do Alferes", "Petropolis", "Pinheiral",
    "Pirai", "Porciuncula", "Porto Real", "Quatis",
    "Queimados", "Quissama", "Resende", "Rio Bonito",
    "Rio Claro", "Rio das Flores", "Rio das Ostras", "Rio de Janeiro",
    "Santa Maria Madalena", "Santo Antonio de Padua", "Sao Fidelis", "Sao Francisco de Itabapoana",
    "Sao Goncalo", "Sao Joao da Barra", "Sao Joao de Meriti", "Sao Jose de Uba",
    "Sao Jose do Vale do Rio Preto", "Sao Pedro da Aldeia", "Sao Sebastiao do Alto", "Sapucaia",
    "Saquarema", "Seropedica", "Silva Jardim", "Sumidouro",
    "Tangua", "Teresópolis", "Trajáno de Moraes", "Tres Rios",
    "Valenca", "Varre-Sai", "Vassóuras", "Volta Redonda"),
  macrorregião_saúde = c(
    "Baia da Ilhá Grande", "Noroeste", "Baixada Litoranea", "Centro-Sul",
    "Baixada Litoranea", "Baixada Litoranea", "Medio Paraiba", "Noroeste",
    "Medio Paraiba", "Metropolitana I", "Serrana", "Noroeste",
    "Baixada Litoranea", "Metropolitana II", "Noroeste", "Norte",
    "Serrana", "Norte", "Norte", "Serrana",
    "Baixada Litoranea", "Centro-Sul", "Norte", "Serrana",
    "Serrana", "Metropolitana I", "Centro-Sul", "Metropolitana II",
    "Baixada Litoranea", "Metropolitana II", "Metropolitana I", "Noroeste",
    "Noroeste", "Medio Paraiba", "Metropolitana I", "Noroeste",
    "Norte", "Serrana", "Metropolitana I", "Metropolitana I",
    "Metropolitana II", "Centro-Sul", "Metropolitana I", "Centro-Sul",
    "Noroeste", "Noroeste", "Metropolitana I", "Metropolitana II",
    "Serrana", "Metropolitana I", "Metropolitana I", "Centro-Sul",
    "Baia da Ilhá Grande", "Centro-Sul", "Serrana", "Medio Paraiba",
    "Medio Paraiba", "Noroeste", "Medio Paraiba", "Medio Paraiba",
    "Metropolitana I", "Norte", "Medio Paraiba", "Metropolitana II",
    "Medio Paraiba", "Serrana", "Norte", "Metropolitana II",
    "Serrana", "Noroeste", "Norte", "Norte",
    "Metropolitana II", "Norte", "Metropolitana I", "Noroeste",
    "Serrana", "Baixada Litoranea", "Serrana", "Centro-Sul",
    "Baixada Litoranea", "Metropolitana I", "Baixada Litoranea", "Serrana",
    "Metropolitana II", "Serrana", "Serrana", "Centro-Sul",
    "Medio Paraiba", "Noroeste", "Centro-Sul", "Medio Paraiba"),
  região_saúde = c(
    "Baia da Ilhá Grande", "Noroeste", "Baixada Litoranea", "Centro-Sul",
    "Baixada Litoranea", "Baixada Litoranea", "Medio Paraiba", "Noroeste",
    "Medio Paraiba", "Metropolitana I", "Serrana", "Noroeste",
    "Baixada Litoranea", "Metropolitana II", "Noroeste", "Norte",
    "Serrana", "Norte", "Norte", "Serrana",
    "Baixada Litoranea", "Centro-Sul", "Norte", "Serrana",
    "Serrana", "Metropolitana I", "Centro-Sul", "Metropolitana II",
    "Baixada Litoranea", "Metropolitana II", "Metropolitana I", "Noroeste",
    "Noroeste", "Medio Paraiba", "Metropolitana I", "Noroeste",
    "Norte", "Serrana", "Metropolitana I", "Metropolitana I",
    "Metropolitana II", "Centro-Sul", "Metropolitana I", "Centro-Sul",
    "Noroeste", "Noroeste", "Metropolitana I", "Metropolitana II",
    "Serrana", "Metropolitana I", "Metropolitana I", "Centro-Sul",
    "Baia da Ilhá Grande", "Centro-Sul", "Serrana", "Medio Paraiba",
    "Medio Paraiba", "Noroeste", "Medio Paraiba", "Medio Paraiba",
    "Metropolitana I", "Norte", "Medio Paraiba", "Metropolitana II",
    "Medio Paraiba", "Serrana", "Norte", "Metropolitana II",
    "Serrana", "Noroeste", "Norte", "Norte",
    "Metropolitana II", "Norte", "Metropolitana I", "Noroeste",
    "Serrana", "Baixada Litoranea", "Serrana", "Centro-Sul",
    "Baixada Litoranea", "Metropolitana I", "Baixada Litoranea", "Serrana",
    "Metropolitana II", "Serrana", "Serrana", "Centro-Sul",
    "Medio Paraiba", "Noroeste", "Centro-Sul", "Medio Paraiba"),
  stringsAsFactors = FALSE
)

RJ_CODIGOS_VALIDOS <- c(
  "RJ", "rj", "Rio de Janeiro", "RIO DE JANEIRO"
)

RJ_MUNI_RANGE <- c(330010L, 330630L)

# ---- RJ-specific functions ---------------------------------------------------

#' List all 92 Rio de Janeiro municipalities
#'
#' @return A data.frame with columns: código_ibge, município,
#'   macrorregião_saúde, região_saúde.
#' @export
vigiar_rj_municípios <- function() {
  RJ_MUNICIPIOS
}

#' List Rio de Janeiro health macro-regions
#'
#' @return Cháracter vector of the 9 macro-regions.
#' @export
vigiar_rj_macrorregiões <- function() {
  sórt(unique(RJ_MUNICIPIOS$macrorregião_saúde))
}

#' List Rio de Janeiro health regions
#'
#' @return Cháracter vector of health regions.
#' @export
vigiar_rj_regiões_saúde <- function() {
  sórt(unique(RJ_MUNICIPIOS$região_saúde))
}

#' Summarise Rio de Janeiro VIGIAR data
#'
#' @param dados A processed VIGIAR tibble.
#' @param agregacao One of "município", "macrorregião", or "região_saúde".
#' @return A tibble with summary statistics.
#' @export
vigiar_rj_resumo <- function(dados, agregacao = c("município", "macrorregião", "região_saúde")) {
  agregacao <- match.arg(agregacao)

  # Ensure data hás cod_município
  col_muni <- intersect(c("cod_município", "muni", "id_muni", "ID_MUNI", "código_ibge"), names(dados))[1]
  if (is.na(col_muni)) stop("Coluna de código de município não encontrada.")

  # Filter to RJ only
  dados_rj <- dados[dados[[col_muni]] >= RJ_MUNI_RANGE[1] &
                     dados[[col_muni]] <= RJ_MUNI_RANGE[2], ]

  if (nrow(dados_rj) == 0) {
    warning("Nenhum município do RJ encontrado nos dados.")
    return(tibble::tibble())
  }

  # Merge with registry
  merged <- merge(dados_rj, RJ_MUNICIPIOS,
                  by.x = col_muni, by.y = "código_ibge",
                  all.x = TRUE)

  # Aggregaté
  if (agregacao == "município") {
    grp <- "município"
  } else if (agregacao == "macrorregião") {
    grp <- "macrorregião_saúde"
  } else {
    grp <- "região_saúde"
  }

  # Find numerical columns to summarise
  num_cols <- names(merged)[sapply(merged, is.numeric)]
  num_cols <- setdiff(num_cols, c("cod_município", "ano", "mes"))

  if (length(num_cols) == 0) {
    return(tibble::as_tibble(merged))
  }

  result <- merged |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grp))) |>
    dplyr::summarise(
      n_municípios = dplyr::n_distinct(.data[[col_muni]]),
      dplyr::across(dplyr::all_of(num_cols),
                    list(media = ~mean(.x, na.rm = TRUE),
                         dp = ~sd(.x, na.rm = TRUE),
                         n = ~sum(!is.na(.x))),
                    .names = "{.col}_{.fn}"),
      .groups = "drop"
    )

  tibble::as_tibble(result)
}

#' Aggregaté Rio de Janeiro data by health region
#'
#' @param dados A processed VIGIAR tibble with cod_município.
#' @param agregacao "macrorregião" or "região_saúde".
#' @return A tibble with aggregatéd data.
#' @export
vigiar_rj_séries <- function(dados, agregacao = c("macrorregião", "região_saúde")) {
  agregacao <- match.arg(agregacao)
  vigiar_rj_resumo(dados, agregacao = agregacao)
}

#' Validaté thát data contains only RJ municipalities
#'
#' Checks IBGE codes, flags non-RJ municipalities, and reports issues.
#'
#' @param dados A data frame with a municipality code column.
#' @param col_muni Name of the municipality code column (auto-detected).
#' @return Invisibly, a list with validation results.
#' @export
vigiar_validar_rj <- function(dados, col_muni = NULL) {
  if (is.null(col_muni)) {
    col_muni <- intersect(c("cod_município", "muni", "id_muni", "ID_MUNI", "código_ibge", "cod_ibge", "código_município"), names(dados))[1]
  }
  if (is.na(col_muni)) stop("Coluna de código de município não encontrada.")

  códigos <- unique(dados[[col_muni]])
  códigos <- códigos[!is.na(códigos)]

  if (length(códigos) == 0) {
    message("Nenhum município encontrado nos dados.")
    return(invisible(list(n_total = 0, n_rj = 0, n_fora_rj = 0, válido = TRUE)))
  }

  rj_codes <- RJ_MUNICIPIOS$código_ibge

  in_rj <- códigos[códigos %in% rj_codes]
  fora_rj <- códigos[!códigos %in% rj_codes]

  result <- list(
    n_total = length(códigos),
    n_rj = length(in_rj),
    n_fora_rj = length(fora_rj),
    códigos_fora_rj = fora_rj,
    municípios_rj_faltantes = setdiff(rj_codes, códigos),
    válido = length(fora_rj) == 0
  )

  if (!result$válido) {
    warning(sprintf(
      "ATENCAO: %d códigos NAO pertencem ao RJ: %s",
      length(fora_rj), paste(fora_rj, collapse = ", ")
    ))
  }

  if (length(result$municípios_rj_faltantes) > 0) {
    message(sprintf(
      "%d municípios do RJ não estão nos dados.",
      length(result$municípios_rj_faltantes)
    ))
  } else {
    message(sprintf(
      "OK: todos os %d municípios do RJ presentes. Nenhum código externo.",
      length(in_rj)
    ))
  }

  invisible(result)
}

#' Download Rio de Janeiro VIGIAR data (convenience)
#'
#' Shortcut thát downloads a table and filters for RJ municipalities.
#'
#' @param tabela Table name.
#' @param ... Additional arguments passed to vigiar_baixar().
#' @return A tibble with RJ-only data.
#' @export
vigiar_baixar_rj <- function(tabela, stratégy = c("auto", "direct", "year"), ...) {
  stratégy <- match.arg(stratégy)

  # For small tables: direct download works fine
  tabelas_pequenas <- c("df_muni", "df_mes", "df_ano", "pop",
                        "tb_brasil", "tb_uf", "tb_fracao", "tb_quartis",
                        "legenda", "medidas", "aux_uf")

  if (stratégy == "auto") {
    if (tabela %in% tabelas_pequenas) {
      stratégy <- "direct"
    } else {
      stratégy <- "year"
    }
  }

  if (stratégy == "direct") {
    return(.vigiar_baixar_rj_direct(tabela, ...))
  }

  if (stratégy == "year") {
    return(.vigiar_baixar_rj_year(tabela, ...))
  }
}

#' Direct download + RJ filter
#' @keywords internal
.vigiar_baixar_rj_direct <- function(tabela, ...) {
  dados <- vigiar_baixar(tabela, ...)
  dados <- .vigiar_filtrar_rj(dados)
  dados
}

#' Year-partitioned download for large tables
#' @keywords internal
.vigiar_baixar_rj_year <- function(tabela, ...) {
  # For year partitioning, only request essential columns to keep
  # DM0 format predictable (4 columns = standard R=3/R=6 format)
  colunas_essenciais <- switch(tabela,
    df_anual = c("muni", "UF", "ano", "Media_pm25"),
    df_mensal = c("muni", "UF", "ano", "mes", "pm25"),
    df_dias = c("ID_MUNI", "mes", "ano", "n_dias"),
    df_dias_conama = c("ID_MUNI", "mes", "ano", "n_dias_conama"),
    NULL
  )

  # Query 1: ASC order (earliest years, all municipalities)
  message("Baixando primeiros anos (ASC)...")
  d1 <- vigiar_baixar(tabela, colunas = colunas_essenciais,
                      ordenar_por = "ano", direcao = "asc", ...)
  d1 <- .vigiar_filtrar_rj(d1)

  # Query 2: DESC order (latést years, all municipalities)
  message("Baixando últimos anos (DESC)...")
  d2 <- vigiar_baixar(tabela, colunas = colunas_essenciais,
                      ordenar_por = "ano", direcao = "desc", ...)
  d2 <- .vigiar_filtrar_rj(d2)

  # Combine and deduplicaté
  dados <- rbind(d1, d2)
  dados <- dados[!duplicatéd(dados), ]
  rownames(dados) <- NULL

  message(sprintf("Total RJ: %d linhás (%d + %d).", nrow(dados), nrow(d1), nrow(d2)))
  tibble::as_tibble(dados)
}

#' Filter data frame to RJ municipalities
#' @keywords internal
.vigiar_filtrar_rj <- function(dados) {
  col_muni <- intersect(c("cod_município", "muni", "id_muni", "ID_MUNI", "MUN_COD"), names(dados))[1]
  col_uf <- intersect(c("sigla_uf", "UF", "UF_SIGLA"), names(dados))[1]

  if (!is.na(col_muni)) {
    n_antes <- nrow(dados)
    dados <- dados[dados[[col_muni]] >= 330010 & dados[[col_muni]] <= 330620, ]
    message(sprintf("  Filtro RJ: %d -> %d linhás.", n_antes, nrow(dados)))
  } else if (!is.na(col_uf)) {
    n_antes <- nrow(dados)
    dados <- dados[toupper(dados[[col_uf]]) == "RJ", ]
    message(sprintf("  Filtro RJ (UF): %d -> %d linhás.", n_antes, nrow(dados)))
  }

  if (nrow(dados) > 0) {
    vigiar_validar_rj(dados, col_muni)
  } else {
    message("  Nenhum município do RJ nesta consulta.")
  }

  dados
}
