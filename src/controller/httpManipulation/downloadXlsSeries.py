from src.config.infoFileProducts import infoFileProduct
from src.config.infoParameters import infoParameters
from src.controller.httpManipulation.executeDownloadFile import executeDownloadFile
from src.script.tools.screenPrint import spLineBoxTaskItemWithOutRecords, spLineBoxTaskClose, spLineBoxTaskOpen, spLineBoxTaskErrors, spLineBoxTaskStatus


# Cria o dataframe principal que irá receber os dados existentes ou será usado para inserção dos dados iniciais
def downloadXlsSeries(identity):
    try:
        spLineBoxTaskOpen('Download de arquivos de Séries xls.')
        info = infoParameters(identity)
        infoProduct = infoFileProduct(identity)

        totalFiles = len(infoProduct)
        totalFilesYes = sum(1 for df in infoProduct.values() if 'get_importar' in dir(df) and df.get_importar() == 'SIM')

        if totalFilesYes < totalFiles:
            if totalFilesYes == 0:
                strMsg = f'Informação: Foram encontrados parâmetros para {totalFiles} commodities, mas nenhum será importado.'
            else:
                strMsg = f'Informação: Foram encontrados parâmetros para {totalFiles} commodities, mas somente {totalFilesYes} serão importados.'
            spLineBoxTaskItemWithOutRecords(strMsg)
            spLineBoxTaskStatus('')

        if totalFilesYes > 0:

            # Iterate over the list and call downloadFile function for each item
            for index, (product_name, product) in enumerate(infoProduct.items(), start=1):

                if product.get_importar() == 'SIM':

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Downloading.[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + product.get_name() + ']:'
                    spLineBoxTaskItemWithOutRecords(strMsg)

                    if product.get_importMethod() == 'Download-xls':
                        # Chamada para realização do download
                        executeDownloadFile(identity, product_name, product.get_url(), product.get_name(), product.get_address(), info.headersBrowser)

        spLineBoxTaskClose('Download de arquivos de Séries xls concluído:')
        # Retorna True
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao realizar o download dos arquivos xls:', e)
        return False
