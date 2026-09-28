# Pipeline de Preços de Combustíveis (ANP)

🇧🇷 Português | [🇺🇸 English](README.md)

Pipeline de engenharia de dados que ingere a série histórica de preços de combustíveis da ANP, organiza os dados em camadas e os transforma em tabelas analíticas confiáveis usando **Python**, **PostgreSQL** e **dbt**.

> Projeto pessoal de portfólio. Trabalha com dado público real e "sujo" do governo brasileiro (422 mil registros por semestre), aplicando limpeza, modelagem em camadas, testes de qualidade e transformações analíticas.

## Arquitetura

O pipeline separa a **ingestão** (Python) da **transformação** (dbt), seguindo o padrão ELT: traz o dado cru para o banco primeiro, transforma depois com SQL.

```
CSV da ANP  ──(Python/pandas)──►  raw_precos (PostgreSQL, cru)
                                       │
                                       ▼ (dbt)
                                  stg_precos  (staging: limpo e tipado)
                                       │
                        ┌──────────────┴──────────────┐
                        ▼                              ▼
              preco_medio_por_estado          evolucao_precos
              (mart: média por UF)            (mart: série temporal
                                               com média móvel 7 dias)
```

### Lineage (gerado automaticamente pelo dbt)

![Lineage do pipeline](docs/lineage.png)

## Tecnologias

- **Python / pandas** — ingestão e leitura do CSV bruto
- **PostgreSQL** — banco de dados relacional
- **dbt** — transformações em SQL, testes e documentação
- **dbt_utils** — pacote de testes de qualidade
- **SQLAlchemy** — conexão Python ↔ banco
- **Git / GitHub** — versionamento

## Destaques técnicos

- **Limpeza de dado real:** conversão de decimal com vírgula (`7,97` → `7.97`), datas no formato brasileiro (`dd/mm/aaaa` → `date`) e padronização de nomes de coluna.
- **Arquitetura em camadas** (medallion): dado cru preservado, staging limpa e reutilizável, marts analíticos.
- **Window functions:** média móvel de 7 dias sobre uma CTE de agregação diária.
- **Testes de qualidade automatizados** (dbt): não-nulos, faixa de valores válida (que também valida a própria transformação de decimais).

## Testes de qualidade

Executados com `dbt test`, bloqueiam o pipeline se o dado violar as regras:

| Coluna | Teste | Regra |
|--------|-------|-------|
| valor_venda | not_null | preço nunca nulo |
| valor_venda | accepted_range | preço entre 0 e 50 (positivo e plausível) |
| estado | not_null | UF sempre presente |
| produto | not_null | tipo de combustível sempre presente |
| data_coleta | not_null | data sempre presente |

## Como executar

1. Clone o repositório e prepare o ambiente:
```bash
   git clone https://github.com/juniorvas/anp-fuel-prices.git
   cd anp-fuel-prices
   python -m venv venv
   # Windows: .\venv\Scripts\Activate
   # Mac/Linux: source venv/bin/activate
   pip install pandas sqlalchemy "psycopg[binary]" python-dotenv dbt-postgres
```

2. Baixe um arquivo CSV da série histórica da ANP (link na seção abaixo) e salve em `data/`.

3. Crie um banco `anp` no PostgreSQL e um arquivo `.env` na raiz:
```
   DB_PASSWORD=sua_senha_aqui
```

4. Rode a ingestão e as transformações:
```bash
   python ingest_raw.py              # carrega o CSV cru no PostgreSQL
   cd anp_analytics
   dbt deps                          # instala pacotes dbt
   dbt run                           # constrói staging + marts
   dbt test                          # valida a qualidade dos dados
   dbt docs generate && dbt docs serve   # documentação + lineage
```

## Fonte dos dados

Série Histórica de Preços de Combustíveis — ANP (Agência Nacional do Petróleo, Gás Natural e Biocombustíveis), dados abertos:
https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis

## Autor

**Wallace Vasconcellos Junior**
[GitHub](https://github.com/juniorvas)