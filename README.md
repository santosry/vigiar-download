# vigiar — Dados do Rio de Janeiro

[![R-CMD-check](https://github.com/santosry/vigiar-download/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/santosry/vigiar-download/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R >= 4.0.0](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://cran.r-project.org/)

Download e processamento dos dados do **VIGIAR** (Vigilancia em Saude Ambiental — Ministerio da Saude)
especializado para o **estado do Rio de Janeiro**.

---

## Instalacao

```r
remotes::install_github("santosry/vigiar-download")
```

## Uso rapido

```r
library(vigiar)
library(ggplot2)

vigiar_conectar()

# Baixar e processar PM2.5 do RJ
pm25_rj <- vigiar_baixar_rj("df_anual") |>
  process_vigiar(tabela = "df_anual")

# Municipios do RJ
vigiar_rj_municipios()  # 92 municipios

# Validar dados
vigiar_validar_rj(pm25_rj)

# Agregar por macrorregiao de saude
vigiar_rj_resumo(pm25_rj, agregacao = "macrorregiao")

vigiar_desconectar()
```

## Funcoes RJ

| Funcao | Descricao |
|--------|-----------|
| `vigiar_baixar_rj(tabela)` | Baixa tabela filtrada para municipios do RJ |
| `vigiar_rj_municipios()` | Lista os 92 municipios com codigos IBGE |
| `vigiar_rj_macrorregioes()` | Lista as 9 macrorregioes de saude |
| `vigiar_rj_regioes_saude()` | Lista as regioes de saude |
| `vigiar_rj_resumo(dados, agregacao)` | Agrega por municipio ou macrorregiao |
| `vigiar_rj_series(dados, agregacao)` | Series por macrorregiao |
| `vigiar_validar_rj(dados)` | Valida se so ha municipios do RJ |

## Macrorregioes de Saude do RJ

| Macrorregiao | Municipios |
|-------------|-----------|
| Baia da Ilha Grande | Angra dos Reis, Paraty |
| Baixada Litoranea | Araruama, Armacao dos Buzios, Arraial do Cabo, Cabo Frio, Casimiro de Abreu, Iguaba Grande, Rio das Ostras, Sao Pedro da Aldeia, Saquarema |
| Centro-Sul | Areal, Comendador Levy Gasparian, Engenheiro Paulo de Frontin, Mendes, Miguel Pereira, Paracambi, Paty do Alferes, Sapucaia, Tres Rios, Vassouras |
| Medio Paraiba | Barra do Pirai, Barra Mansa, Itatiaia, Pinheiral, Pirai, Porto Real, Quatis, Resende, Rio Claro, Rio das Flores, Valenca, Volta Redonda |
| Metropolitana I | Belford Roxo, Duque de Caxias, Itaguai, Japeri, Mage, Mesquita, Nilopolis, Nova Iguacu, Queimados, Rio de Janeiro, Sao Joao de Meriti, Seropedica |
| Metropolitana II | Cachoeiras de Macacu, Guapimirim, Itaborai, Marica, Niteroi, Rio Bonito, Sao Goncalo, Silva Jardim, Tangua |
| Noroeste | Aperibe, Bom Jesus do Itabapoana, Cambuci, Italva, Itaocara, Itaperuna, Laje do Muriae, Miracema, Natividade, Porciuncula, Santo Antonio de Padua, Sao Jose de Uba, Varre-Sai |
| Norte | Campos dos Goytacazes, Carapebus, Cardoso Moreira, Conceicao de Macabu, Macae, Quissama, Sao Fidelis, Sao Francisco de Itabapoana, Sao Joao da Barra |
| Serrana | Bom Jardim, Cantagalo, Carmo, Cordeiro, Duas Barras, Macuco, Nova Friburgo, Petropolis, Santa Maria Madalena, Sao Jose do Vale do Rio Preto, Sao Sebastiao do Alto, Sumidouro, Teresopolis, Trajano de Moraes |

## Estrutura para integracao futura

O pacote esta preparado para integracao com:
- **SIH** (Sistema de Informacoes Hospitalares)
- **SIM** (Sistema de Informacoes sobre Mortalidade)
- **DATASUS** (microdatasus, sql, etc.)
- **INMET** (dados meteorologicos)

A tabela `RJ_MUNICIPIOS` interna contem `codigo_ibge` compativel com todos esses sistemas.

## Fonte

Ministerio da Saude — VIGIAR. Dados publicos via Power BI.

## IA Disclosure

DeepSeek v4 Pro e ChatGPT GPT-5.5 para revisao de codigo e documentacao.

## Licenca

MIT © Ryan Santos
