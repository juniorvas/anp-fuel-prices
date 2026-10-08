-- models/marts/evolucao_precos.sql
-- Evolucao do preco medio diario, com media movel de 7 dias.

with precos_por_dia as (

    -- Passo 1: um preco medio por dia (junta as varias coletas do mesmo dia)
    select
        estado,
        produto,
        data_coleta,
        round(avg(valor_venda), 2) as preco_medio_dia
    from {{ ref('stg_precos') }}
    group by estado, produto, data_coleta

)

-- Passo 2: media movel de 7 dias sobre os precos diarios
select
    estado,
    produto,
    data_coleta,
    preco_medio_dia,
    round(
        avg(preco_medio_dia) over (
            partition by estado, produto
            order by data_coleta
            rows between 6 preceding and current row
        ),
    2) as media_movel_7d
from precos_por_dia
order by estado, produto, data_coleta