from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait

# Definindo as datas de início e fim
dataIni = "2022-01-01"
dataFim = "2022-12-31"

# Inicializando o driver do Chrome
driver = webdriver.Chrome()

# Acessando a página
driver.get("https://celepar7.pr.gov.br/ceasa/cotprod_evolucao.asp")

try:
    # Preenchendo as datas
    data_ini_input = driver.find_element(By.NAME, "dataIni")
    data_ini_input.send_keys(dataIni)

    data_fim_input = driver.find_element(By.NAME, "dataFim")
    data_fim_input.send_keys(dataFim)

    # Selecionando o produto "Amendoim Com Casca"
    produto_select = Select(driver.find_element(By.NAME, "cmbProdutos"))
    produto_select.select_by_value("701'1'2")

    # Acionando o botão "Pesquisar"
    bt_pesquisar_button = driver.find_element(By.NAME, "btPesquisar")
    bt_pesquisar_button.click()

    # Esperando que a página de resultados seja carregada
    WebDriverWait(driver, 10).until(
        EC.url_to_be("https://celepar7.pr.gov.br/ceasa/result_evolucao_precos.asp")
    )

    # Obtendo todas as tabelas existentes
    tables = driver.find
