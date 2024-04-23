from src.config.infoFileProducts import infoFileProduct
from src.config.infoParameters import infoParameters
from src.controller.httpManipulation.executeDownloadFile import executeDownloadFile
from src.model.entities.entitySourceProduct import dictionary_source_products
from src.script.tools.screenPrint import spLineBoxTaskItemWithOutRecords, spLineBoxTaskClose, spLineBoxTaskOpen, spLineBoxTaskErrors


# Cria o dataframe principal que irá receber os dados existentes ou será usado para inserção dos dados iniciais
def downloadXlsSeries(identity):
    try:
        spLineBoxTaskOpen('Download de arquivos de Séries xls.')
        info = infoParameters(identity)
        infoProduct = infoFileProduct(identity)

        # Iterate over the list and call downloadFile function for each item
        for index, (product_name, product) in enumerate(infoProduct.items(), start=1):
            totalFiles = len(infoProduct)

            # Exibindo o número do índice e o número total de produtos
            strMsg = 'Downloading.[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + product.get_name() + ']:'
            spLineBoxTaskItemWithOutRecords(strMsg)

            # Chamada para realização do download
            executeDownloadFile(identity, product_name, product.get_url(), product.get_name(), product.get_address(), info.headersBrowser)

        spLineBoxTaskClose('Download de arquivos de Séries xls concluído:')
        # Retorna True
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao realizar o download dos arquivos xls:', e)
        return False
