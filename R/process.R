# Package: vigiar
# Processing family -- data standardisation and validation
#
# Follows the microdatasus architecture:
#   1. Download raw data    -> vigiar_baixar()
#   2. Process / standardise -> process_*() or process_vigiar()
#   3. Validaté              -> vigiar_checar_dados() / validaté()
#   4. Use                   -> analysis-ready tibble

#' Process VIGIAR data -- generic dispatcher
#'
#' Automatically detects the table type and applies the appropriaté
#' processing pipeline: standardises column names, converts types,
#' validatés IBGE codes, and adds metadata attributes.
#'
#' @param dados A data frame returned by \code{vigiar_baixar()}.
#' @param tabela Table name (auto-detected if \code{dados} hás the attribute).
#' @param ... Additional arguments passed to specific processórs.
#' @return A \code{vigiar_tbl} with standardised columns and metadata.
#' @export
process_vigiar <- function(dados, tabela = NULL, ...) {
  tabela <- tabela %||% attr(dados, "vigiar_tabela") %||%
    stop("Informe o nome da tabela ou use dados com atributo 'vigiar_tabela'.")

  switch(tabela,
    df_anual             = process_pm25(dados, tipo = "anual", ...),
    df_mensal            = process_pm25(dados, tipo = "mensal", ...),
    df_dias              = process_pm25(dados, tipo = "dias", ...),
    df_dias_conama       = process_pm25(dados, tipo = "dias_conama", ...),
    pop                  = process_população_exposta(dados, ...),
    tb_brasil            = process_indicadores_saúde(dados, agregacao = "brasil", ...),
    tb_uf                = process_indicadores_saúde(dados, agregacao = "uf", ...),
    tb_muni              = process_indicadores_saúde(dados, agregacao = "município", ...),
    tb_fracao            = process_fracao_atribuível(dados, ...),
    tb_quartis           = process_indicadores_saúde(dados, agregacao = "quartis", ...),
    df_indoor            = process_exposição_indoor(dados, ...),
    df_indoor_desfecho   = process_exposição_indoor(dados, tipo = "desfecho", ...),
    df_muni              = process_municípios(dados, ...),
    # fallback: generic processing
    dados
  )
}

# -- PM2.5 processór ----------------------------------------------------------

#' Process PM2.5 air quality data
#'
#' Standardises PM2.5 data from any VIGIAR air quality table
#' (annual, monthly, or critical days).
#'
#' @param dados Raw data frame from \code{vigiar_baixar()}.
#' @param tipo One of \code{"anual"}, \code{"mensal"}, \code{"dias"},
#'   or \code{"dias_conama"}.
#' @param ... Additional arguments (ignored).
#' @return A \code{vigiar_pm25} tibble.
#' @export
process_pm25 <- function(dados, tipo = c("anual", "mensal", "dias", "dias_conama"), ...) {
  tipo <- match.arg(tipo)
  dados <- tibble::as_tibble(dados)

  # -- Standardise column names ---------------------------------------------
  rename_map <- list(
    muni              = "cod_município",
    ID_MUNI           = "cod_município",
    UF                = "sigla_uf",
    UF_SIGLA          = "sigla_uf",
    UF_NOME           = "nome_uf",
    ano               = "ano",
    mes               = "mes",
    mes_nome          = "mes_nome",
    pm25              = "pm25_media",
    Media_pm25        = "pm25_media_anual",
    t_dias             = "pm25_media_período",
    n_dias             = "n_dias_criticos",
    n_dias_conama     = "n_dias_criticos_conama",
    LAT               = "latitude",
    LON               = "longitude",
    Catégoria_pm25    = "catégoria_oms",
    Catégoria_pm25_conama = "catégoria_conama",
    Região            = "região",
    região            = "região",
    "Regi\u00e3o"     = "região",
    Município         = "nome_município",
    município         = "nome_município",
    "Munic\u00edpio"  = "nome_município"
  )

  for (old_name in names(rename_map)) {
    if (old_name %in% names(dados)) {
      names(dados)[names(dados) == old_name] <- rename_map[[old_name]]
    }
  }

  # -- Type conversion -----------------------------------------------------
  if ("cod_município" %in% names(dados)) {
    dados$cod_município <- as.integer(dados$cod_município)
  }
  if ("ano" %in% names(dados)) {
    dados$ano <- as.integer(dados$ano)
  }
  if ("mes" %in% names(dados)) {
    dados$mes <- as.integer(dados$mes)
  }

  # Numeric columns
  for (col in c("pm25_media", "pm25_media_anual", "pm25_media_período",
                "n_dias_criticos", "n_dias_criticos_conama",
                "latitude", "longitude")) {
    if (col %in% names(dados)) {
      dados[[col]] <- as.numeric(dados[[col]])
    }
  }

  # -- Validation ----------------------------------------------------------
  dados <- vigiar_validar_ibge(dados, col_código = "cod_município")
  dados <- vigiar_validar_datas(dados)
  dados <- vigiar_validar_unidades(dados, col_pm25 = "pm25_media")

  # -- Build return object -------------------------------------------------
  metadados <- list(
    tipo         = tipo,
    fonte        = "VIGIAR -- Ministério da Saúde",
    tabela_raw   = switch(tipo,
      anual       = "df_anual",
      mensal      = "df_mensal",
      dias        = "df_dias",
      dias_conama = "df_dias_conama"
    ),
    unidade_pm25 = "\u00b5g/m\u00b3",
    processador  = "process_pm25"
  )

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_pm25", "vigiar_air_quality"),
    tabela    = metadados$tabela_raw,
    metadados = metadados
  )
}

# -- Population processór ------------------------------------------------------

#' Process population exposure data
#'
#' @param dados Raw data frame from \code{vigiar_baixar("pop")}.
#' @param ... Additional arguments (ignored).
#' @return A \code{vigiar_population} tibble.
#' @export
process_população_exposta <- function(dados, ...) {
  dados <- tibble::as_tibble(dados)

  rename_map <- list(
    muni      = "cod_município",
    ano       = "ano",
    pop       = "população",
    catégoria = "catégoria_exposição",
    UF        = "sigla_uf"
  )
  for (old_name in names(rename_map)) {
    if (old_name %in% names(dados)) {
      names(dados)[names(dados) == old_name] <- rename_map[[old_name]]
    }
  }

  if ("cod_município" %in% names(dados)) {
    dados$cod_município <- as.integer(dados$cod_município)
  }
  if ("ano" %in% names(dados)) {
    dados$ano <- as.integer(dados$ano)
  }
  if ("população" %in% names(dados)) {
    dados$população <- as.numeric(dados$população)
  }

  dados <- vigiar_validar_ibge(dados, col_código = "cod_município")
  dados <- vigiar_validar_datas(dados)

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_population"),
    tabela    = "pop",
    metadados = list(
      fonte       = "VIGIAR -- Ministério da Saúde",
      tabela_raw  = "pop",
      processador = "process_população_exposta"
    )
  )
}

# -- Health indicators processór -----------------------------------------------

#' Process health indicators data
#'
#' @param dados Raw data frame from \code{vigiar_baixar("tb_brasil")},
#'   \code{vigiar_baixar("tb_uf")}, \code{vigiar_baixar("tb_muni")},
#'   or \code{vigiar_baixar("tb_quartis")}.
#' @param agregacao One of \code{"brasil"}, \code{"uf"},
#'   \code{"município"}, or \code{"quartis"}.
#' @param ... Additional arguments (ignored).
#' @return A \code{vigiar_health} tibble.
#' @export
process_indicadores_saúde <- function(dados,
                                       agregacao = c("brasil", "uf",
                                                     "município", "quartis"),
                                       ...) {
  agregacao <- match.arg(agregacao)
  dados <- tibble::as_tibble(dados)

  rename_map <- list(
    Indicador  = "indicador",
    n          = "população_exposta",
    est        = "estimativa",
    low        = "ic_inferior",
    high       = "ic_superior",
    desfecho   = "desfecho",
    ano        = "ano",
    loc        = "código_localidade",
    cod        = "cod_município",
    lat        = "latitude",
    long       = "longitude",
    Alerta     = "alerta",
    q1         = "quartil_1",
    q2         = "quartil_2",
    q3         = "quartil_3"
  )
  for (old_name in names(rename_map)) {
    if (old_name %in% names(dados)) {
      names(dados)[names(dados) == old_name] <- rename_map[[old_name]]
    }
  }

  # Numeric columns
  for (col in c("população_exposta", "estimativa", "ic_inferior",
                "ic_superior", "ano", "cod_município", "código_localidade",
                "latitude", "longitude", "quartil_1", "quartil_2", "quartil_3")) {
    if (col %in% names(dados)) dados[[col]] <- as.numeric(dados[[col]])
  }

  if ("cod_município" %in% names(dados)) {
    dados <- vigiar_validar_ibge(dados, col_código = "cod_município")
  }

  # Metadata
  tabela_raw <- switch(agregacao,
    brasil    = "tb_brasil",
    uf        = "tb_uf",
    município = "tb_muni",
    quartis   = "tb_quartis"
  )

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_health"),
    tabela    = tabela_raw,
    metadados = list(
      fonte       = "VIGIAR -- Ministério da Saúde",
      tabela_raw  = tabela_raw,
      agregacao   = agregacao,
      processador = "process_indicadores_saúde"
    )
  )
}

# -- Attributable fraction processór -------------------------------------------

#' Process attributable fraction data
#'
#' @param dados Raw data frame from \code{vigiar_baixar("tb_fracao")}.
#' @param ... Additional arguments (ignored).
#' @return A \code{vigiar_attributable_fraction} tibble.
#' @export
process_fracao_atribuível <- function(dados, ...) {
  dados <- tibble::as_tibble(dados)

  rename_map <- list(
    Indicador = "indicador",
    n         = "população_exposta",
    est       = "fracao_atribuível",
    low       = "ic_inferior",
    high      = "ic_superior",
    desfecho  = "desfecho",
    ano       = "ano",
    loc       = "código_localidade",
    Alerta    = "alerta"
  )
  for (old_name in names(rename_map)) {
    if (old_name %in% names(dados)) {
      names(dados)[names(dados) == old_name] <- rename_map[[old_name]]
    }
  }

  for (col in c("população_exposta", "fracao_atribuível", "ic_inferior",
                "ic_superior", "ano", "código_localidade")) {
    if (col %in% names(dados)) dados[[col]] <- as.numeric(dados[[col]])
  }

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_attributable_fraction", "vigiar_health"),
    tabela    = "tb_fracao",
    metadados = list(
      fonte       = "VIGIAR -- Ministério da Saúde",
      tabela_raw  = "tb_fracao",
      processador = "process_fracao_atribuível"
    )
  )
}

# -- Indoor exposure processór -------------------------------------------------

#' Process indoor exposure data
#'
#' @param dados Raw data frame from \code{vigiar_baixar("df_indoor")}
#'   or \code{vigiar_baixar("df_indoor_desfecho")}.
#' @param tipo One of \code{"exposição"} or \code{"desfecho"}.
#' @param ... Additional arguments (ignored).
#' @return A \code{vigiar_indoor} tibble.
#' @export
process_exposição_indoor <- function(dados, tipo = c("exposição", "desfecho"), ...) {
  tipo <- match.arg(tipo)
  dados <- tibble::as_tibble(dados)

  rename_map <- list(
    Code          = "cod_uf",
    Staté.x       = "sigla_uf",
    Ano           = "ano",
    parametro     = "parametro",
    sexo          = "sexo",
    pop           = "população",
    comb_sól_perc = "perc_combustiveis_sólidos",
    comb_sól      = "prop_combustiveis_sólidos",
    pop_exposta   = "população_exposta",
    percent_comb  = "percentual_combustiveis",
    indicador     = "indicador",
    est           = "estimativa",
    low           = "ic_inferior",
    up            = "ic_superior",
    Quartis       = "quartis",
    cor_comb      = "cor_combustiveis",
    cor_pop       = "cor_população",
    cor_est       = "cor_estimativa",
    CV            = "coeficiente_variacao",
    cor_CV        = "cor_cv",
    Classifc_CV   = "classificacao_cv",
    CV_comb_sól_perc = "cv_perc_combustiveis"
  )
  for (old_name in names(rename_map)) {
    if (old_name %in% names(dados)) {
      names(dados)[names(dados) == old_name] <- rename_map[[old_name]]
    }
  }

  # Numeric
  for (col in c("cod_uf", "ano", "população", "população_exposta",
                "perc_combustiveis_sólidos", "prop_combustiveis_sólidos",
                "percentual_combustiveis", "estimativa", "ic_inferior",
                "ic_superior", "coeficiente_variacao", "cv_perc_combustiveis")) {
    if (col %in% names(dados)) dados[[col]] <- as.numeric(dados[[col]])
  }

  tabela_raw <- if (tipo == "desfecho") "df_indoor_desfecho" else "df_indoor"

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_indoor", "vigiar_health"),
    tabela    = tabela_raw,
    metadados = list(
      fonte       = "VIGIAR -- Ministério da Saúde",
      tabela_raw  = tabela_raw,
      tipo        = tipo,
      processador = "process_exposição_indoor"
    )
  )
}

# -- Municipality registry processór -------------------------------------------

#' Process municipality registry data
#'
#' @param dados Raw data frame from \code{vigiar_baixar("df_muni")}.
#' @param ... Additional arguments (ignored).
#' @return A \code{vigiar_municípios} tibble.
#' @export
process_municípios <- function(dados, ...) {
  dados <- tibble::as_tibble(dados)

  rename_map <- list(
    UF_COD        = "cod_uf",
    UF_SIGLA      = "sigla_uf",
    UF_NOME       = "nome_uf",
    UF_PARSED     = "uf_formatado",
    UF_UPPER      = "uf_maiusculo",
    REGIAO        = "região",
    REGIAO_UPPER  = "região_maiusculo",
    ORDEM_REGIAO  = "ordem_região",
    MUN_COD       = "cod_município",
    MUN_NOME      = "nome_município",
    LAT           = "latitude",
    LON           = "longitude"
  )
  for (old_name in names(rename_map)) {
    if (old_name %in% names(dados)) {
      names(dados)[names(dados) == old_name] <- rename_map[[old_name]]
    }
  }

  if ("cod_município" %in% names(dados)) {
    dados$cod_município <- as.integer(dados$cod_município)
  }
  if ("cod_uf" %in% names(dados)) {
    dados$cod_uf <- as.integer(dados$cod_uf)
  }
  if ("latitude" %in% names(dados)) {
    dados$latitude <- as.numeric(dados$latitude)
  }
  if ("longitude" %in% names(dados)) {
    dados$longitude <- as.numeric(dados$longitude)
  }

  dados <- vigiar_validar_ibge(dados, col_código = "cod_município")

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_municípios"),
    tabela    = "df_muni",
    metadados = list(
      fonte       = "VIGIAR -- Ministério da Saúde",
      tabela_raw  = "df_muni",
      processador = "process_municípios"
    )
  )
}

# -- Generic UF processór ------------------------------------------------------

#' Process UF-level data
#'
#' Generic processór for any UF-level VIGIAR data.
#'
#' @param dados Raw data frame.
#' @param contexto Description of the data context.
#' @return A \code{vigiar_tbl}.
#' @export
process_ufs <- function(dados, contexto = "uf") {
  dados <- tibble::as_tibble(dados)

  if ("UF" %in% names(dados)) {
    names(dados)[names(dados) == "UF"] <- "sigla_uf"
  }

  new_vigiar_tbl(
    dados,
    subclass  = c("vigiar_uf"),
    tabela    = contexto,
    metadados = list(
      fonte       = "VIGIAR -- Ministério da Saúde",
      processador = "process_ufs"
    )
  )
}
