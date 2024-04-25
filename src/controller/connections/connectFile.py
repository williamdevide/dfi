import sys

from src.config.infoFile import infoFileDestiny, infoFileSource
from src.config.infoFileProducts import infoFileProduct
from src.script.tools.screenPrint import spLineBoxTaskUnique, spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskStatus, spLineBoxTaskItemWithOutRecords, \
    spLineBoxTaskErrors
from src.script.tools.tools import verifyFile


def connectFile(identity, dataframeHolder, infoParameter, infoTables, infoProducts, typeConnect):
    try:
        spLineBoxTaskOpen('Conexão com arquivo(s) de origem:')

        totalFiles = len(infoProducts)
        totalFilesYes = sum(1 for df in infoProducts.values() if 'get_importar' in dir(df) and df.get_importar() == 'SIM')
        if totalFilesYes < totalFiles:
            strMsg = f'Informação: Encontrados parâmetros para {totalFiles} arquivo(s) de origem. {totalFilesYes} arquivo(s) a ser importados.'
            spLineBoxTaskItemWithOutRecords(strMsg)
            spLineBoxTaskStatus('')

        if totalFilesYes > 0:
            for index, (item_name, item) in enumerate(infoProducts.items(), start=1):
                if item.get_importar() == 'SIM':

                    fileName = ''
                    if typeConnect == 'Origem':
                        fileName = item.get_url() + item.get_name()
                    if typeConnect == 'Destino':
                        fileName = item.get_address() + item.get_name()

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Connecting..[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + fileName + ']:'
                    spLineBoxTaskItemWithOutRecords(strMsg)

                    # Filtra pelos importMethods permitidos
                    if item.get_importMethod() == 'Download-xls' or item.get_importMethod() == 'Download-txt':
                        # Verifica se o arquivo existe e é acessível
                        returnVerifyFile = verifyFile(item.get_name(), item.get_address())
                        if returnVerifyFile == 2:
                            spLineBoxTaskStatus('[ERRO]')
                            input()
                        else:
                            spLineBoxTaskStatus('[SUCESSO]')

        spLineBoxTaskClose('Final da conexão com arquivo(s) de origem:')
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao conectar com arquivo(s) de origem:', e)
        return False
