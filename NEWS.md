# vigiar 0.3.0

## Fixed (hardening)

* **BUG**: Duplicate `Regiao` entry in `process_pm25()` rename_map.
* **BUG**: Case mismatch in rename_maps — `vigiar_padronizar_colunas()`
  lowercases column names but some rename_map keys used capital letters
  (`Regiao`, `Municipio`). Added lowercase variants.
* **BUG**: `vigiar_variaveis_orfas()` exported in Rd but missing from
  NAMESPACE.
* Rate limiting: `vigiar_baixar_tudo()` now accepts `delay` parameter
  (default 0.5s) to respect Power BI API.
* Governance: Issue templates (bug, feature, schema change) and PR
  checklist added.
* `process_vigiar()` fallback for unknown tables now returns a usable
  data.frame instead of erroring.

## Documentation

* README: added complete 12-step example (connect → download → process
  → validate → summarise → plot → export → dictionary → disconnect).
* README: expanded function reference table with all processing,
  summary, dictionary, and export functions.

# vigiar 0.3.0 (original)

## New: Summary functions

* `vigiar_resumo()`: S3 generic dispatcher for descriptive summaries.
* `vigiar_resumo_pm25()`: mean, median, SD, percentiles, out-of-range count.
* `vigiar_resumo_saude()`: n_indicadores, n_desfechos, descriptive stats.
* `vigiar_resumo_populacao()`: total population, spatial coverage.
* `vigiar_resumo_fracao_atribuivel()`: mean, min, max of fractions.
* `vigiar_resumo_indoor()`: mean, min, max of solid fuel exposure.

## New: Time series (descriptive only, no models)

* `vigiar_serie_temporal()`: aggregate by year (national/UF/municipio).
* `vigiar_tendencia_descritiva()`: year-over-year change + moving average.
* `vigiar_agregar_tempo()`: flexible time aggregation with custom functions.

## New: Maps (ggplot2 + optional geobr)

* `vigiar_join_geobr()`: join VIGIAR data with geobr geometries.
* `vigiar_mapa_pm25()`: choropleth of PM2.5 concentrations.
* `vigiar_mapa_populacao_exposta()`: population exposure map.
* `vigiar_mapa_indicadores_saude()`: health indicator estimates map.
* `vigiar_mapa_fracao_atribuivel()`: attributable fraction map.
* `vigiar_mapa_indoor()`: indoor solid fuel exposure map.

## New: Export functions

* `vigiar_exportar_csv()`: export to CSV with UTF-8 encoding.
* `vigiar_exportar_rds()`: export to RDS (preserves all metadata).
* `vigiar_exportar_parquet()`: export to Parquet (requires arrow).

## New: Dictionary validation

* `vigiar_tabelas_documentadas()`: list documented tables.
* `vigiar_variaveis_nao_documentadas()`: find undocumented variables.
* `vigiar_validar_dicionario()`: full dictionary coverage report.
* `vigiar_comparar_schema()`: live vs documented column comparison.

## Documentation

* `convencoes-vigiar.Rmd`: complete variable conventions (microdatasus style).
* `mapas-vigiar.Rmd`: map-making tutorial.
* `series-temporais-vigiar.Rmd`: time series exploration.
* `uso-responsavel-dados.Rmd`: ethical use and limitations.
* pkgdown site with 11 reference sections and 9 articles.

## Benchmark

* Feature parity with microdatasus: download/process/document/visualise.
* No DLNM, GAM, or causal inference — descriptive exploration only.

# vigiar 0.2.0
...
