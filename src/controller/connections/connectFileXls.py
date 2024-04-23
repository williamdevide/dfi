import sys

from src.config.infoFile import infoFileDestiny, infoFileSource
from src.config.infoFileProducts import infoFileProduct
from src.script.tools.screenPrint import spLineBoxTaskUnique, spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskStatus, spLineBoxTaskItemWithOutRecords, \
    spLineBoxTaskErrors
from src.script.tools.tools import verifyFile


def connectFileXlsDestiny(identity, dataframeHolder, infoParameter, tables):
    try:
        spLineBoxTaskUnique('Conexão com arquivo de destino:')
        infoDestiny = infoFileDestiny(identity)

        # Verifica se o arquivo é acessível (caso não exista será posteriormente criado)
        if verifyFile(infoDestiny.get_name(), infoDestiny.get_address()) == 2:
            input()

        # Retorna True se o arquivo foi encontrado e está disponível para conexão
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao conectar ao arquivo de destino:', e)
        return False


def connectFileXlsSource(identity, dataframeHolder, infoParameter, tables, products):
    try:
        spLineBoxTaskOpen('Conexão aos arquivos de origem:')

        for index, (item_name, item) in enumerate(products.items(), start=1):
            totalFiles = len(products)

            # Exibindo o número do índice e o número total de produtos
            strMsg = 'Connecting..[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + item.get_name() + ']:'
            spLineBoxTaskItemWithOutRecords(strMsg)

            # Verifica se o arquivo existe e é acessível
            returnVerifyFile = verifyFile(item.get_name(), item.get_address())
            if returnVerifyFile == 2:
                spLineBoxTaskStatus('[ERRO]')
                input()
            else:
                spLineBoxTaskStatus('[SUCESSO]')

        spLineBoxTaskClose('Final da conexão aos arquivos de origem:')
        # Retorna True se o arquivo foi encontrado e está disponível para conexão
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao conectar ao arquivo de origem:', e)
        return False
