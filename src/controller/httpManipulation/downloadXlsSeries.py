from src.config.infoDataItems import infoDataItem
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.httpManipulation.executeDownloadFile import executeDownloadFile
from src.script.tools.screenPrint import spLineBoxTaskItemWithOutRecords, spLineBoxTaskClose, spLineBoxTaskOpen, spLineBoxTaskErrors, spLineBoxTaskStatus


# Cria o dataframe principal que irá receber os dados existentes ou será usado para inserção dos dados iniciais
def downloadXlsSeries(identity):
    try:
        spLineBoxTaskOpen('Download de arquivos de Séries xls.')
        infoParameters = infoParametersApplication(identity)
        infoItems = infoDataItem(identity)

        totalFiles = len(infoItems)
        totalFilesYes = sum(1 for df in infoItems.values() if 'get_importar' in dir(df) and df.get_importar() == 'SIM')

        if totalFilesYes < totalFiles:
            if totalFilesYes == 0:
                strMsg = f'Informação: Foram encontrados parâmetros para {totalFiles} commodities, mas nenhum será importado.'
            else:
                strMsg = f'Informação: Foram encontrados parâmetros para {totalFiles} commodities, mas somente {totalFilesYes} serão importados.'
            spLineBoxTaskItemWithOutRecords(strMsg)
            spLineBoxTaskStatus('')

        if totalFilesYes > 0:

            # Iterate over the list and call downloadFile function for each item
            for index, (item_name, item) in enumerate(infoItems.items(), start=1):

                if item.get_importar() == 'SIM':

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Downloading.[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + item.get_filename() + ']:'
                    spLineBoxTaskItemWithOutRecords(strMsg)

                    if item.get_importMethod() == 'Download-xls':
                        # Chamada para realização do download
                        executeDownloadFile(identity, item_name, item.get_addressSource(), item.get_filename(), item.get_addressDestiny(), infoParameters.headersBrowser)

        spLineBoxTaskClose('Download de arquivos de Séries xls concluído:')
        # Retorna True
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao realizar o download dos arquivos xls:', str(e))
        return False
