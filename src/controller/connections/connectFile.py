from src.script.tools.screenPrint import spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskStatus, spLineBoxTaskItemWithOutRecords, \
    spLineBoxTaskErrors
from src.script.tools.tools import verifyFile


def connectFile(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect):
    try:
        strMsg = f'Conexão com {typeConnect}:'
        spLineBoxTaskOpen(strMsg)

        totalFiles = len(infoProduct)
        totalFilesYes = sum(1 for df in infoProduct.values() if 'get_importar' in dir(df) and df.get_importar() == 'SIM')
        if totalFilesYes < totalFiles:
            strMsg = f'Informação: Encontrados parâmetros para {totalFiles} arquivo(s) de origem. {totalFilesYes} arquivo(s) a ser importados.'
            spLineBoxTaskItemWithOutRecords(strMsg)
            spLineBoxTaskStatus('')

        if totalFilesYes > 0:
            for index, (item_name, item) in enumerate(infoProduct.items(), start=1):
                if item.get_importar() == 'SIM':

                    fileName = ''
                    if typeConnect == 'Origem':
                        fileName = item.get_url() + item.get_name()
                    if typeConnect == 'Destino':
                        fileName = item.get_address() + item.get_name()

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Conectando..[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + fileName + ']:'
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

        strMsg = f'Conexão com {typeConnect}:'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Conexão com {typeConnect}:'
        spLineBoxTaskErrors(strMsg, e)
        return False
