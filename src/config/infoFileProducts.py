import os

from src.script.tools.tools import getParameter
from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters
from src.model.entities.entitySourceProduct import SourceProduct, add_source_product, dictionary_source_products


def infoFileProduct(identity):
    dfs = DataFrameHolderParameters()
    nameDf = 'df' + identity + '_file_source_products'
    dfproducts = dfs.get_df(nameDf)

    for index, row in dfproducts.iterrows():
        # Adicionar o produto ao dicionário
        add_source_product(index, addInformationProduct(identity, index))

    return dictionary_source_products


def addInformationProduct(identity, product):
    nameDf = 'df' + identity + '_file_source_products'
    commodity = getParameter(nameDf, product)

    item = commodity[0]                                             # NOME DO PRODUTO ANALISADO
    name = commodity[1]                                             # NOME E EXTENSÃO DO ARQUIVO DE ORIGEM
    url = commodity[2]                                              # URL DO ARQUIVO PARA DOWNLOAD
    address = commodity[3]                                          # ENDEREÇO DO ARQUIVO DE ORIGEM
    sheet = commodity[4]                                            # NOME DA PLANILHA DENTRO DO ARQUIVO DE ORIGEM
    header = commodity[5]                                           # LINHA DE CABEÇALHO NA PLANILHA ORIGEM
    columns = commodity[6]                                          # CABEÇALHO DAS COLUNAS NA PLANILHA ORIGEM
    conditionColumns = commodity[7]                                 # COLUNA PARA FILTRO
    conditionValue = commodity[8]                                   # VALOR PARA FILTRO
    conversionFactor = commodity[9]                                 # FATOR DE CONVERSÃO DO PRODUTO (VALOR NUMERICO PARA CALCULO DO PRODUTO)
    unitSource = commodity[10]                                      # UNIDADE COMERCIAL NA PLANILHA DE ENTRADA
    unitDestiny = commodity[11]                                     # UNIDADE COMERCIAL UTILIZADA NA MARVI
    SAPProduct = commodity[12]                                      # CÓDIGO DO PRODDUTO NO SAP

    return SourceProduct(item, name, url, address, sheet, header, columns, conditionColumns, conditionValue, conversionFactor, unitSource, unitDestiny, SAPProduct)

