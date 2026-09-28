import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

# lê o CSV da ANP com as instruções pra lidar com a bagunça
df = pd.read_csv(
    "data/precos_2026_01.csv",
    sep=";",                 # colunas separadas por ponto-e-vírgula
    encoding="utf-8-sig",    # lida com o BOM do arquivo
    dtype=str,               # lê TUDO como texto (preserva o cru)
)

print(f"Lido: {df.shape[0]} linhas, {df.shape[1]} colunas")
print(df.columns.tolist())   # mostra os nomes das colunas

load_dotenv()
senha = os.getenv("DB_PASSWORD")
engine = create_engine(f"postgresql://postgres:{senha}@localhost:5432/anp")

# carrega o DataFrame numa tabela raw, cru, do jeito que veio
df.to_sql("raw_precos", engine, if_exists="replace", index=False)

print("Carregado no Postgres: tabela raw_precos")