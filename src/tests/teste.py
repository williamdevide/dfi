import pandas as pd
import requests
from bs4 import BeautifulSoup

# Defina as datas iniciais e finais
dataIni = "2024-01-01"
dataFim = "2024-04-01"

# URL da página inicial
url = "https://celepar7.pr.gov.br/ceasa/cotprod_evolucao.asp"

# Dados do formulário
form_data = {
    'dataIni': dataIni,
    'dataFim': dataFim,
    'cmbProdutos': "701'1'2"
}

# Faz a solicitação POST
response = requests.post(url, data=form_data)

# Verifica se a solicitação foi bem-sucedida
if response.status_code == 200:
    # URL da página com os resultados
    result_url = "https://celepar7.pr.gov.br/ceasa/result_evolucao_precos.asp"

    # Faz a solicitação GET para a página de resultados
    result_response = requests.get(result_url)

    # Verifica se a solicitação foi bem-sucedida
    if result_response.status_code == 200:
        # Analisa o HTML da página de resultados
        soup = BeautifulSoup(result_response.content, 'html.parser')

        # Encontra todas as tabelas na página
        tables = soup.find_all('table')

        # Salva as tabelas em dataframes
        dfs = []
        for table in tables:
            dfs.append(pd.read_html(str(table))[0])

        # Imprime os dataframes
        for i, df in enumerate(dfs):
            print("DataFrame", i + 1)
            print(df)
            print()
    else:
        print("Erro ao obter página de resultados.")
else:
    print("Erro ao acessar a página inicial.")
