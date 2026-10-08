-- models/stg_precos.sql
-- Camada staging: limpa e padroniza o dado cru de raw_precos.

select
    "Regiao - Sigla"                                  as regiao,
    "Estado - Sigla"                                  as estado,
    "Municipio"                                       as municipio,
    "Produto"                                         as produto,
    "Bandeira"                                        as bandeira,
    to_date("Data da Coleta", 'DD/MM/YYYY')           as data_coleta,
    cast(replace("Valor de Venda", ',', '.') as numeric)  as valor_venda,
    "Unidade de Medida"                               as unidade

from raw_precos