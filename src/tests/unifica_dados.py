import pandas as pd
import os

# Diretório onde estão os arquivos txt
diretorio = 'd:/corrigirdados'

# Lista para armazenar os dados de todos os arquivos
dados = []

# Iterar sobre os arquivos no diretório
for arquivo in os.listdir(diretorio):
    if arquivo.endswith('.txt') or arquivo.endswith('.log'):
        caminho_arquivo = os.path.join(diretorio, arquivo)
        with open(caminho_arquivo, 'r') as f:
            # Lendo cada linha do arquivo
            linhas = f.readlines()
            # Adicionando as linhas aos dados
            dados.extend(linhas)

# Convertendo os dados em um único dataframe
dfdados = pd.DataFrame([linha.strip().split('|') for linha in dados], columns=None)

# Removendo registros duplicados
dfdados.drop_duplicates(subset=[8], inplace=True)

# Salvando o dataframe em um novo arquivo txt
caminho_novo_arquivo = os.path.join(diretorio, 'novo_dados.txt')
with open(caminho_novo_arquivo, 'w') as f:
    for index, row in dfdados.iterrows():
        f.write('|'.join(row) + '\n')
