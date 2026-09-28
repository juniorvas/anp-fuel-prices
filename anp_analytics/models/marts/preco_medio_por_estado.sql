-- models/marts/preco_medio_por_estado.sql
-- Preco medio de cada combustivel, por estado.

select
    estado,
    produto,
    round(avg(valor_venda), 2)  as preco_medio,
    count(*)                    as qtd_coletas
from {{ ref('stg_precos') }}
group by estado, produto
order by estado, produto