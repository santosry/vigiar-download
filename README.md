# vigiar

<!-- badges: start -->
<!-- badges: end -->

Pacote R para download automatizado dos dados do dashboard
[VIGIAR](https://app.powerbi.com/view?r=eyJrIjoiNmRhODQwNzItNThlOS00ZmQ4LWJjZmItZDYxOTNhOTRmYmFhIiwidCI6IjlhNTU0YWQzLWI1MmItNDg2Mi1hMzZmLTg0ZDg5MWU1YzcwNSJ9)
(Vigilância em Saúde Ambiental — Ministério da Saúde) publicado no Power BI.

---

## O que é o VIGIAR?

O VIGIAR é o sistema de vigilância em saúde ambiental do Ministério da
Saúde brasileiro. O dashboard público fornece dados sobre:

- **Qualidade do ar** — concentração de PM2.5 por município (médias anuais
  e mensais)
- **Dias críticos** — número de dias acima dos limites recomendados (OMS
  e CONAMA)
- **População exposta** — estimativas de população por faixa de concentração
- **Indicadores de saúde** — fração atribuível, internações, desfechos
  respiratórios
- **Exposição indoor** — uso de combustíveis sólidos em domicílios

## Instalação

```r
# Instalar do GitHub (recomendado)
# install.packages("remotes")
remotes::install_github("santosry/vigiar-download")

# Ou instalar do arquivo .tar.gz local
# install.packages("caminho/vigiar_0.1.0.tar.gz",
#   repos = NULL, type = "source")
```

Dependências (instaladas automaticamente):

- `httr2` — requisições HTTP modernas
- `jsonlite` — parsing JSON
- `tibble` — data frames organizados

Requer R ≥ 4.0.0.

## Uso Básico

```r
library(vigiar)

# 1. Conectar ao dashboard (obtém sessão e carrega o esquema)
vigiar_conectar()
#> Sessão VIGIAR estabelecida. Carregando esquema de dados...
#> Sessão pronta! 32 tabelas disponíveis.

# 2. Ver tabelas disponíveis
vigiar_tabelas()
#>  [1] "DateTableTemplate_..." "medidas"              
#>  [3] "Ano"                   "Selecao"              
#>  [5] "df_mensal"             "df_ano"               
#>  ...

# 3. Ver estrutura de uma tabela
vigiar_esquema("df_anual")
#> === Tabela: df_anual ===
#>   coluna         tipo
#>   muni        integer
#>   UF        character
#>   ano         integer
#>   Media_pm25  numeric
#>   ...

# 4. Baixar dados
dados_anuais <- vigiar_baixar("df_anual")

# 5. Baixar apenas algumas colunas
df_mensal <- vigiar_baixar("df_mensal",
  colunas = c("ano", "mes", "UF", "Município", "pm25"))

# 6. Baixar todas as tabelas principais de uma vez
tudo <- vigiar_baixar_principais()
names(tudo)

# 7. Encerrar sessão
vigiar_desconectar()
```

## Tabelas Disponíveis

| Tabela | Descrição | Linhas (~) |
|--------|-----------|-----------|
| `df_anual` | Médias anuais PM2.5 por município | ~28k |
| `df_mensal` | Médias mensais PM2.5 por município | ~336k |
| `df_muni` | Cadastro de municípios com coordenadas | ~5.6k |
| `df_dias` | Dias acima do limite OMS (PM2.5 > 15 µg/m³) | ~67k |
| `df_dias_conama` | Dias acima do limite CONAMA (PM2.5 > 50 µg/m³) | ~67k |
| `pop` | População residente por município e ano | ~34k |
| `tb_brasil` | Indicadores de saúde agregados — Brasil | |
| `tb_uf` | Indicadores de saúde agregados — UF | |
| `tb_muni` | Indicadores de saúde por município | |
| `tb_fracao` | Fração atribuível por indicador e desfecho | |
| `tb_quartis` | Quartis dos indicadores | |
| `df_indoor` | Exposição a combustíveis sólidos (indoor) | |
| `df_indoor_desfecho` | Desfechos de saúde — poluição indoor | |
| `medidas` | Tabela de medidas calculadas | |

*Lista completa: `vigiar_tabelas()` | Detalhes: `vigiar_esquema("tabela")`*

## Exemplos de Análise

### PM2.5 médio por UF ao longo dos anos

```r
library(vigiar)
library(dplyr)
library(ggplot2)

vigiar_conectar()
dados <- vigiar_baixar("df_anual")

dados |>
  filter(ano >= 2015) |>
  group_by(UF, ano) |>
  summarise(pm25_medio = mean(Media_pm25, na.rm = TRUE), .groups = "drop") |>
  ggplot(aes(ano, pm25_medio, color = UF)) +
  geom_line() +
  labs(title = "PM2.5 médio por UF",
       x = "Ano", y = expression(PM[2.5] ~ (µg/m³))) +
  theme_minimal()
```

### Top 10 municípios com maior PM2.5

```r
dados |>
  filter(ano == max(ano)) |>
  slice_max(Media_pm25, n = 10) |>
  select(UF, Media_pm25)
```

### Download seletivo com ordenação

```r
# Apenas dados recentes, ordenados por município
df_recente <- vigiar_baixar("df_mensal",
  colunas = c("ano", "mes", "UF", "Município", "pm25"),
  ordenar_por = "Município")
```

## Funções Exportadas

| Função | Descrição |
|--------|-----------|
| `vigiar_conectar()` | Estabelece sessão com o Power BI |
| `vigiar_desconectar()` | Encerra a sessão |
| `vigiar_sessao_ativa()` | Verifica se há sessão ativa |
| `vigiar_tabelas()` | Lista tabelas disponíveis |
| `vigiar_esquema(tabela)` | Mostra colunas e tipos |
| `vigiar_baixar(tabela, ...)` | Baixa uma tabela específica |
| `vigiar_baixar_tudo(tabelas)` | Baixa múltiplas tabelas |
| `vigiar_baixar_principais()` | Atalho para as tabelas mais usadas |

## Como Funciona

O pacote implementa o protocolo da API Power BI "Publish to Web":

```
Usuário
  │
  ├─ vigiar_conectar()
  │   └─ GET app.powerbi.com/view → cookies + sessionId
  │   └─ GET /conceptualschema → tabelas e colunas
  │
  ├─ vigiar_baixar("tabela")
  │   └─ Monta query SemanticQueryDataShapeCommand (JSON)
  │   └─ POST /querydata → resposta DSR comprimida
  │   └─ Decodifica DSR: ValueDicts + DM0 + referências
  │   └─ Retorna tibble limpo
  │
  └─ vigiar_desconectar()
      └─ Limpa sessão e cache
```

### O protocolo DSR (Data Shape Response)

O Power BI comprime dados usando:

1. **DM0 array**: cada entrada representa uma linha. A primeira entrada
   contém o schema (`S`) + a primeira linha (`C`). Entradas subsequentes
   usam `R` (referência 1-indexada) para indicar quantas colunas repetem
   da linha anterior + `C` com os novos valores.
2. **ValueDicts**: dicionários que mapeiam índices numéricos para strings,
   usados em colunas de texto para economizar espaço.

Exemplo:
```
Linha 1: {S: [ano, UF, muni, pm25], C: [2010, 0, 120001, 29.99]}
Linha 2: {R: 3, C: [120005, 18.37]}
         → mantém 2 colunas (R-1=2): [2010, 0, ...]
         → + C: [2010, 0, 120005, 18.37]
```

## Limitações

- A sessão expira após algumas horas. Use `vigiar_conectar(atualizar = TRUE)`.
- Tabelas muito grandes (>300k linhas) podem demorar alguns minutos.
- O download depende da disponibilidade do servidor Power BI do Datasus.
- O parser assume o formato DSR padrão. Mudanças na API do Power BI podem
  exigir atualização do pacote.

## Solução de Problemas

| Erro | Provável Causa | Solução |
|------|---------------|---------|
| "Não foi possível extrair o telemetrySessionId" | Dashboard fora do ar | Tentar novamente mais tarde |
| "Nenhuma sessão ativa" | Não conectou | `vigiar_conectar()` primeiro |
| Tabela vazia | Tabela sem dados no modelo | Normal para algumas tabelas auxiliares |
| Timeout | Conexão lenta | `vigiar_conectar(timeout = 60)` |
| Erro 403 Forbidden | Sessão expirada | `vigiar_conectar(atualizar = TRUE)` |

## Contribuindo

Contribuições são bem-vindas! Abra uma issue ou envie um pull request no
[GitHub](https://github.com/santosry/vigiar-download).

## Licença

MIT. Os dados baixados pertencem ao Ministério da Saúde / Datasus — VIGIAR.
