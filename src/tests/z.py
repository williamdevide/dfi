from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import pandas as pd

# Definindo as datas de início e fim
dataIni = "01/01/2024"
dataFim = "20/04/2024"

# Inicializando o driver do Chrome
driver = webdriver.Firefox()

# Acessando a página
driver.get("https://celepar7.pr.gov.br/ceasa/cotprod_evolucao.asp")

try:
    # Esperando até que os elementos estejam presentes na página
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.NAME, "dataIni"))
    )
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.NAME, "dataFim"))
    )

    # Preenchendo as datas
    driver.find_element(By.NAME, "dataIni").send_keys(dataIni)
    driver.find_element(By.NAME, "dataFim").send_keys(dataFim)

    # Selecionando o produto "Amendoim Com Casca"
    produto_select = Select(driver.find_element(By.NAME, "cmbProdutos"))
    produto_select.select_by_value("701'1'2")

    # Acionando o botão "Pesquisar"
    driver.find_element(By.NAME, "btPesquisar").click()

    # Esperando que a página de resultados seja carregada
    WebDriverWait(driver, 10).until(
        EC.url_to_be("https://celepar7.pr.gov.br/ceasa/result_evolucao_precos.asp")
    )

    # Exibindo o conteúdo da página
    print(driver.page_source)

    # Obtendo todas as tabelas com base nos atributos específicos
    tables = driver.find_elements(By.XPATH, "//table[contains(@border, '1') and contains(@cellspacing, '1') and contains(@width, '616')]")

    # Convertendo as tabelas para DataFrames e salvando cada uma em um arquivo CSV
    for i, table in enumerate(tables):
        df = pd.read_html(table.get_attribute('outerHTML'))[0]
        df.to_csv(f"tabela_{i + 1}.csv", index=False)

finally:
    # Fechando o navegador
    driver.quit()
