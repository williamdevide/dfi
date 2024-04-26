from src.model.entities.entityFileDestiny import FileDestiny
from src.script.tools.tools import getParameter


def infoFileDestiny(identity):
    # parâmetros do arquivo de saída
    nameDf = 'df' + identity + '_file_destiny'

    item = "ChargeDestiny"  # NOME DO PRODUTO ANALISADO
    name = getParameter(nameDf, 'file')  # NOME E EXTENSÃO DO ARQUIVO DE DESTINO
    address = getParameter(nameDf, 'address')  # ENDEREÇO DO ARQUIVO DE DESTINO
    url = ""
    sheet = "Índices"  # NOME DA PLANILHA DENTRO DO ARQUIVO DE DESTINO
    header = 1  # LINHA DE CABEÇALHO NA PLANILHA
    columns = ['Data']  # CABEÇALHO DAS COLUNAS NA PLANILHA ORIGEM
    conditionColumns = ''  # COLUNA PARA FILTRO
    conditionValue = ''  # VALOR PARA FILTRO

    return FileDestiny(item, name, url, address, sheet, header, columns, conditionColumns, conditionValue)


def infoFileSource(identity):
    # parâmetros do arquivo de saída
    nameDf = 'df' + identity + '_file_source'

    item = "ChargeSource"  # NOME DO PRODUTO ANALISADO
    name = getParameter(nameDf, 'file')  # NOME E EXTENSÃO DO ARQUIVO DE DESTINO
    address = getParameter(nameDf, 'address')  # ENDEREÇO DO ARQUIVO DE DESTINO
    url = ""
    sheet = "Índices"  # NOME DA PLANILHA DENTRO DO ARQUIVO DE DESTINO
    header = 1  # LINHA DE CABEÇALHO NA PLANILHA
    columns = ['Data']  # CABEÇALHO DAS COLUNAS NA PLANILHA ORIGEM
    conditionColumns = ''  # COLUNA PARA FILTRO
    conditionValue = ''  # VALOR PARA FILTRO

    return FileDestiny(item, name, url, address, sheet, header, columns, conditionColumns, conditionValue)
