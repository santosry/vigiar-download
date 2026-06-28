# vigiar

Pacote R para download, validacao, auditoria e analise dos dados do dashboard
[VIGIAR](https://app.powerbi.com/view?r=eyJrIjoiNmRhODQwNzItNThlOS00ZmQ4LWJjZmItZDYxOTNhOTRmYmFhIiwidCI6IjlhNTU0YWQzLWI1MmItNDg2Mi1hMzZmLTg0ZDg5MWU1YzcwNSJ9)
(Vigilancia em Saude Ambiental) do Power BI, com foco no estado do Rio de Janeiro.

**Versao 0.7.0** -- Benchmark | Auditoria | Compliance | Logging | Snapshots | Cache | Schema Lock

## Funcionalidades

| Categoria | Ferramentas |
|-----------|------------|
| **Download** | `vigiar_baixar()`, `vigiar_baixar_tudo()`, `vigiar_baixar_principais()`, `vigiar_baixar_rj()` |
| **Processamento** | `process_vigiar()`, `process_pm25()`, `process_populacao_exposta()`, `process_indicadores_saude()`, `process_fracao_atribuivel()`, `process_exposicao_indoor()`, `process_municipios()` |
| **Validacao** | `vigiar_validar_ibge()`, `vigiar_validar_datas()`, `vigiar_validar_unidades()`, `vigiar_checar_dados()`, `vigiar_diagnostico()` |
| **RJ** | `vigiar_rj_municipios()` (92 municipios), `vigiar_rj_macrorregioes()` (9 regioes), `vigiar_validar_rj()`, `vigiar_rj_resumo()` |
| **Series Temporais** | `vigiar_agregar_tempo()`, `vigiar_tendencia_descritiva()`, `vigiar_serie_temporal()` |
| **Dicionario** | `vigiar_dicionario()`, `vigiar_variaveis()`, `vigiar_descrever_variavel()`, `vigiar_convencoes()` |
| **Exportacao** | CSV, RDS, Parquet (`vigiar_exportar_csv/rds/parquet()`) |
| **Benchmark** | `vigiar_benchmark()`, `vigiar_benchmark_tabelas()`, `vigiar_health_check()` |
| **Auditoria** | `vigiar_auditar()`, `vigiar_auditar_tudo()`, `vigiar_compliance_check()`, `vigiar_checksum()` |
| **Logging** | `vigiar_log()`, `vigiar_exportar_log()`, `vigiar_resumo_log()`, `vigiar_historico_downloads()` |
| **Snapshots** | `vigiar_snapshot()`, `vigiar_verificar_snapshot()`, `vigiar_salvar/carregar_snapshot()`, `vigiar_comparar_snapshots()` |
| **Cache** | `vigiar_cache_dir()`, `vigiar_baixar_com_cache()`, `vigiar_cache_info()`, `vigiar_limpar_cache()` |
| **Schema Lock** | `vigiar_esquema_lock()`, `vigiar_esquema_verificar()`, `vigiar_esquema_carregar_lock()` |

## O que e o VIGIAR?

O VIGIAR e um sistema do Ministerio da Saude brasileiro para vigilancia em
saude ambiental, que fornece dados sobre:

- **Qualidade do ar** (PM2.5) por municipio brasileiro
- **Dados populacionais** expostos a poluicao
- **Indicadores de saude** associados (doencas respiratorias, internacoes)
- **Combustiveis solidos** e exposicao indoor
- **Indicadores agrupados** por Brasil, UF e municipio

## Instalacao

```r
# Instalar do GitHub
# devtools::install_github("santosry/vigiar")

# Ou do diretorio local
install.packages("caminho/para/vigiar", repos = NULL, type = "source")
```

### Dependencias

```r
install.packages(c("httr2", "jsonlite", "tibble", "dplyr", "cli", "openssl"))
```

## Uso Basico

```r
library(vigiar)

# 1. Conectar ao dashboard
vigiar_conectar()

# 2. Ver tabelas disponiveis
vigiar_tabelas()

# 3. Baixar dados do RJ (particionado por ano)
dados_rj <- vigiar_baixar_rj("df_anual")
head(dados_rj)

# 4. Baixar todas as tabelas principais
tudo <- vigiar_baixar_principais()

# 5. Processar e validar
pm25 <- process_pm25(tudo$df_anual, tipo = "anual")

# 6. Auditar dados
audit <- vigiar_auditar(pm25, tabela = "df_anual")

# 7. Criar snapshot para reprodutibilidade
snap <- vigiar_snapshot(dados = pm25, tabela = "df_anual")
vigiar_salvar_snapshot(snap, "pm25_rj.rds")

# 8. Encerrar sessao
vigiar_desconectar()
```

## Tabelas Disponiveis

| Tabela | Descricao | Principais Colunas |
|--------|-----------|-------------------|
| `df_anual` | Medias anuais PM2.5 por municipio | muni, UF, ano, Media_pm25, Categoria_pm25 |
| `df_mensal` | Medias mensais PM2.5 por municipio | muni, UF, ano, mes, pm25, LAT, LON |
| `df_muni` | Cadastro de municipios | REGIAO, UF_SIGLA, UF_COD, MUN_NOME, LAT, LON |
| `df_dias` | Dias criticos PM2.5 | ID_MUNI, mes, ano, n_dias, t_dias |
| `df_dias_conama` | Dias criticos (padrao CONAMA) | ID_MUNI, mes, ano, n_dias_conama |
| `pop` | Populacao por municipio | muni, ano, pop, categoria, UF |
| `tb_brasil` | Indicadores agregados Brasil | Indicador, n, est, low, high, ano |
| `tb_uf` | Indicadores agregados UF | Indicador, n, est, low, high, ano, loc |
| `tb_muni` | Indicadores por municipio | Indicador, n, est, low, high, ano, loc |
| `tb_fracao` | Fracao atribuivel | Indicador, n, est, low, high, desfecho |
| `tb_quartis` | Quartis dos indicadores | Indicador, desfecho, q1, q2, q3 |
| `df_indoor` | Exposicao combustiveis solidos | Code, Ano, comb_sol, pop_exposta |
| `df_indoor_desfecho` | Desfechos indoor | Code, State.x, Ano, parametro, sexo |

## Exemplos

### Analise de PM2.5 anual no RJ

```r
library(vigiar)
library(dplyr)
library(ggplot2)

vigiar_conectar()
dados <- vigiar_baixar_rj("df_anual")

# Media de PM2.5 por ano
dados |>
  group_by(ano) |>
  summarise(
    pm25_medio = mean(as.numeric(Media_pm25), na.rm = TRUE),
    n_municipios = n()
  )

# Top 10 municipios com maior PM2.5 em 2022
dados |>
  filter(ano == 2022) |>
  slice_max(as.numeric(Media_pm25), n = 10) |>
  select(muni, UF, Media_pm25)
```

### Auditoria e Compliance

```r
# Auditoria completa
audit <- vigiar_auditar(pm25, tabela = "df_anual")
print(audit)

# Multiplos perfis de compliance
compliance <- vigiar_compliance_check(
  pm25, tabela = "df_anual",
  profiles = c("basico", "rigoroso", "rj", "corrupcao")
)

# Exportar auditoria em JSON para compliance
vigiar_exportar_auditoria(audit, "auditoria_pm25.json")
```

### Logging e Historico

```r
# Visualizar log de operacoes
vigiar_log()
vigiar_resumo_log()

# Historico de downloads
vigiar_historico_downloads()
vigiar_resumo_downloads()

# Exportar log
vigiar_exportar_log("log_operacoes.json")
```

### Cache e Reprodutibilidade

```r
# Configurar cache local
vigiar_cache_dir("~/vigiar_cache")

# Download com cache (reusa se < 24h)
dados <- vigiar_baixar_com_cache("df_anual")

# Congelar schema para detectar mudancas
vigiar_esquema_lock("schema_v1.json")
vigiar_esquema_verificar("schema_v1.json")  # Verifica se mudou

# Snapshots com checksums SHA256
snap <- vigiar_snapshot(dados = dados, tabela = "df_anual")
vigiar_verificar_snapshot(snap)  # Confirma integridade
```

### Benchmark

```r
# Comparar estrategias de download
bench <- vigiar_benchmark("df_anual",
  strategies = c("direct", "year_asc_desc", "minimal_columns"))

# Health check completo
vigiar_health_check()
```

## Como Funciona

O pacote implementa o protocolo de API do Power BI "Publish to Web":

1. **Sessao**: Obtem cookies (`WFESessionId`, `ARRAffinity`) e o
   `telemetrySessionId` da pagina do dashboard.

2. **Esquema**: Consulta o endpoint `/conceptualschema` para obter a
   estrutura de tabelas e colunas.

3. **Query**: Monta queries no formato Semantic Query (JSON) e as envia
   para o endpoint `/querydata`.

4. **Parse**: Decodifica o formato comprimido DSR (Data Shape Response)
   do Power BI para data.frames R.

### Diagrama

```
Usuario -> vigiar_conectar() -> Power BI Page -> obtem cookies/session
              |
         vigiar_baixar("tabela")
              |
         .vigiar_construir_query()  -> monta JSON da query
              |
         .vigiar_executar_query()   -> POST /querydata
              |
         .vigiar_parse_dados()      -> decodifica DSR -> data.frame
              |
         process_vigiar()           -> padroniza, valida, tipifica
              |
         vigiar_auditar()           -> audita compliance
```

## Limitacoes

- A sessao expira apos algumas horas sem uso. Execute `vigiar_conectar(refresh = TRUE)` para renovar.
- O download de tabelas muito grandes (>100k linhas) pode ser lento devido
  ao formato comprimido.
- A API do Power BI limita respostas a ~30K linhas. Use `vigiar_baixar_rj()`
  para tabelas grandes (faz download ASC + DESC para cobrir todo o range).
- O pacote depende da disponibilidade do servidor Power BI do Ministerio da Saude.
- Mudancas no layout do dashboard podem exigir atualizacao do pacote.

## Solucao de Problemas

| Erro | Solucao |
|------|---------|
| "Nao foi possivel extrair o telemetrySessionId" | O dashboard pode estar fora do ar. Tente novamente mais tarde. |
| "Nenhuma sessao ativa" | Execute `vigiar_conectar()` primeiro. |
| Tabela retorna vazia | A tabela pode estar listada no esquema mas sem dados populados. |
| Timeout | Aumente o timeout: `vigiar_conectar(timeout = 60)` |
| Erro 403 / Forbidden | Sessao expirada. Execute `vigiar_conectar(refresh = TRUE)`. |
| 0 linhas com filtro UF='RJ' | Use `vigiar_baixar_rj("tabela")` em vez de `vigiar_baixar("tabela")` |

## Licenca

MIT. Os dados baixados pertencem ao Ministerio da Saude / VIGIAR.
