from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters
from src.model.entities.entityDataItem import DataItem, add_item_data, dictionary_data_items, remove_item_data
from src.script.tools.tools import getParameter


def infoDataItem(identity):
    dfs = DataFrameHolderParameters()
    nameDf = 'df' + identity + '_data_items'
    dfItem = dfs.get_df(nameDf)

    for index, row in dfItem.iterrows():
        # Adicionar o produto ao dicionário
        add_item_data(index, addInformationDataItem(identity, index))

    return dictionary_data_items


def addInformationDataItem(identity, item):
    nameDf = 'df' + identity + '_data_items'
    infoItem = getParameter(nameDf, item)

    importar = infoItem[0]  # FLAG SE SERÁ REALIZADA A IMPORTAÇÃO DESSE COMMODITY OU NÃO (SIM / NAO)
    importMethod = infoItem[1]  # METODO DE IMPORTAÇÃO (DOWNLOAD-XLS / DOWNLOAD-TABLE)
    item = infoItem[2]  # NOME DO PRODUTO ANALISADO
    filename = infoItem[3]  # NOME E EXTENSÃO DO ARQUIVO DE ORIGEM
    addressSource = infoItem[4]  # URL DO ARQUIVO PARA DOWNLOAD
    addressDestiny = infoItem[5]  # ENDEREÇO DO ARQUIVO DE ORIGEM
    sheet = infoItem[6]  # NOME DA PLANILHA DENTRO DO ARQUIVO DE ORIGEM
    header = infoItem[7]  # LINHA DE CABEÇALHO NA PLANILHA ORIGEM
    columns = infoItem[8]  # CABEÇALHO DAS COLUNAS NA PLANILHA ORIGEM
    conditionColumns = infoItem[9]  # COLUNA PARA FILTRO
    conditionValue = infoItem[10]  # VALOR PARA FILTRO
    conversionFactor = infoItem[11]  # FATOR DE CONVERSÃO DO PRODUTO (VALOR NUMERICO PARA CALCULO DO PRODUTO)
    unitSource = infoItem[12]  # UNIDADE COMERCIAL NA PLANILHA DE ENTRADA
    unitDestiny = infoItem[13]  # UNIDADE COMERCIAL UTILIZADA NA MARVI
    SAPProduct = infoItem[14]  # CÓDIGO DO PRODDUTO NO SAP

    return DataItem(importar, importMethod, item, filename, addressSource, addressDestiny, sheet, header, columns, conditionColumns, conditionValue, conversionFactor, unitSource, unitDestiny, SAPProduct)


def clearInformationProduct(infoItems):
    indexItem = []
    for index, (program, table) in enumerate(infoItems.items(), start=1):
        indexItem.append(program)

    for indexItem in indexItem:
        remove_item_data(indexItem)
