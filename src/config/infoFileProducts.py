from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters
from src.model.entities.entitySourceData import SourceProduct, add_source_product, dictionary_source_products, remove_table
from src.script.tools.tools import getParameter


def infoFileProduct(identity):
    dfs = DataFrameHolderParameters()
    nameDf = 'df' + identity + '_sources'
    dfproducts = dfs.get_df(nameDf)

    for index, row in dfproducts.iterrows():
        # Adicionar o produto ao dicionário
        add_source_product(index, addInformationProduct(identity, index))

    return dictionary_source_products


def addInformationProduct(identity, product):
    nameDf = 'df' + identity + '_sources'
    commodity = getParameter(nameDf, product)

    importar = commodity[0]  # FLAG SE SERÁ REALIZADA A IMPORTAÇÃO DESSE COMMODITY OU NÃO (SIM / NAO)
    importMethod = commodity[1]  # METODO DE IMPORTAÇÃO (DOWNLOAD-XLS / DOWNLOAD-TABLE)
    item = commodity[2]  # NOME DO PRODUTO ANALISADO
    name = commodity[3]  # NOME E EXTENSÃO DO ARQUIVO DE ORIGEM
    url = commodity[4]  # URL DO ARQUIVO PARA DOWNLOAD
    address = commodity[5]  # ENDEREÇO DO ARQUIVO DE ORIGEM
    sheet = commodity[6]  # NOME DA PLANILHA DENTRO DO ARQUIVO DE ORIGEM
    header = commodity[7]  # LINHA DE CABEÇALHO NA PLANILHA ORIGEM
    columns = commodity[8]  # CABEÇALHO DAS COLUNAS NA PLANILHA ORIGEM
    conditionColumns = commodity[9]  # COLUNA PARA FILTRO
    conditionValue = commodity[10]  # VALOR PARA FILTRO
    conversionFactor = commodity[11]  # FATOR DE CONVERSÃO DO PRODUTO (VALOR NUMERICO PARA CALCULO DO PRODUTO)
    unitSource = commodity[12]  # UNIDADE COMERCIAL NA PLANILHA DE ENTRADA
    unitDestiny = commodity[13]  # UNIDADE COMERCIAL UTILIZADA NA MARVI
    SAPProduct = commodity[14]  # CÓDIGO DO PRODDUTO NO SAP

    return SourceProduct(importar, importMethod, item, name, url, address, sheet, header, columns, conditionColumns, conditionValue, conversionFactor, unitSource, unitDestiny,
                         SAPProduct)

def clearInformationProduct(infoTables):
    indexTable = []
    for index, (program, table) in enumerate(infoTables.items(), start=1):
        indexTable.append(program)

    for indexTable in indexTable:
        remove_table(indexTable)