import pandas as pd

from src.config.infoFile import infoFileDestiny
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.dataframeManipulation.fillMissingValues import fillMissingFieldIntervals, fillMissingDayOfWeek, fillMissingFieldFull
from src.controller.dataframeManipulation.prepareAmbient import prepareAmbient
from src.controller.dataframeManipulation.unionDataframes import unionDataframes
from src.controller.dataframeManipulation.updateDataframe import updateDataframe
from src.controller.excelManipulation.operationsExcel import readFileExcel
from src.script.tools.screenPrint import spLineBoxTaskRecords, spLineBoxTaskOpen, spLineBoxTaskItemWithOutRecords, spLineBoxTaskItemWithRecords, spLineBoxTaskClose, \
    spLineBoxTaskErrors, spLineBoxTaskStatus
from src.script.tools.tools import verifySuccess, convertAndOrderByData, mergeDataframesOuter, mergeDataframesInner


def importXlsSeriesToDataframe(identity, dataframeHolder, infoParameter, tables, products, typeConnect):
    try:
        strMsg = 'Importação de arquivos em série Xlsx para Dataframe principal:'
        spLineBoxTaskOpen(strMsg)

        # Gerando dataframe inicial com todas as datas e dia da semana. Será usado para merge com cada um dos importSeriesProduct
        spLineBoxTaskItemWithOutRecords('Preparando Ambiente:')
        verifySuccess(prepareAmbient(identity, dataframeHolder, infoParameter, tables, products, typeConnect))

        totalFiles = len(products)
        totalFilesYes = sum(1 for df in products.values() if 'get_importar' in dir(df) and df.get_importar() == 'SIM')

        if totalFilesYes < totalFiles:
            strMsg = f'Informação: Encontrados parâmetros para {totalFiles} arquivo(s) de origem. {totalFilesYes} arquivo(s) a ser importados.'
            spLineBoxTaskItemWithOutRecords(strMsg)
            spLineBoxTaskStatus('')

        if totalFilesYes > 0:
            # Iterate over the list and call downloadFile function for each item
            for index, (product_name, product) in enumerate(products.items(), start=1):

                if product.get_importar() == 'SIM':

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Importing...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + product.get_name() + ']: '
                    spLineBoxTaskItemWithRecords(strMsg)

                    if product.get_importMethod() == 'Download-xls':
                        # Realiza a chamada para importação do xls para o dataframe
                        verifySuccess(executeImportXlsToDataframe(identity, dataframeHolder, product, 'Origem'))

            # Gerando dataframe final com a união dos dataframes de produtos
            verifySuccess(unionDataframes(identity, dataframeHolder, infoParameter, tables, products))

            # Atualizando dfChargeDestiny com os valores do dfUnion
            verifySuccess(updateDataframe(identity, dataframeHolder, infoParameter, tables, products))

        strMsg = 'Importação de arquivos em série Xlsx para Dataframe principal:'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = 'Importação de arquivos em série Xlsx para Dataframe principal:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False


def importXlsFinalToDataframe(identity, dataframeHolder):
    try:

        print(' => Carregando informações do arquivo de destino para Dataframe principal.')

        infoDestiny = infoFileDestiny(identity)

        # Exibindo o número do índice e o número total de produtos
        print(f'     -> Importing...[01/01]: Arquivo:[{infoDestiny.get_name():<20}]: ', end='')

        # Realiza a chamada para importação do xls para o dataframe
        verifySuccess(executeImportXlsToDataframe(identity, dataframeHolder, infoDestiny, 'Destino'))

        print('     /=> Final do carregamento das informações do arquivo de destino para Dataframe principal.', end='')
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao importar informações do arquivo de destino:', str(e))
        return False


def executeImportXlsToDataframe(identity, dataframeHolder, product, typeFile):
    try:
        # Realiza a leitura do excel de origem caso existente
        success, dfTemp = readFileExcel(identity, dataframeHolder, product, typeFile)

        if not success:
            return False

        # verifica se existe conteudo. se existir conteudo ordena e mescla com o dfMain criando o df[productName]]
        if not dfTemp.empty:
            info = infoParametersApplication(identity)

            if typeFile == 'Origem':
                # Ordenar DataFrame pela coluna 'Data'
                dfTemp = convertAndOrderByData(identity, dfTemp, info.dateField, info.dateFieldFormat)
                dfTemp = fillMissingDayOfWeek(identity, dfTemp, info.dateField, info.dayWeekField)

                # Dataframe principal recebe os dados do dataframe local
                dfAmbient = dataframeHolder.get_df('dfAmbient')
                dfTemp = mergeDataframesInner(identity, dfAmbient, dfTemp)
                dfTemp = fillMissingFieldIntervals(identity, dfTemp, info.priceField)
                dfTemp = fillMissingFieldIntervals(identity, dfTemp, 'comhis_price_unit')
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_conversion_factor', product.get_conversionFactor())
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_unit_destiny', product.get_unitDestiny())
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_unit_source', product.get_unitSource())
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_SAP_product', product.get_SAPProduct())
                dfTemp = fillMissingFieldFull(identity, dfTemp, info.structureFieldsDataframeSource[2], product.get_item())
        else:
            if typeFile == 'Destino':
                dfTemp = pd.DataFrame()

        totalRecords = '[' + str(dfTemp.shape[0]).rjust(6) + ' records]'
        spLineBoxTaskRecords(totalRecords)
        dataframeHolder.add_df('df' + product.get_item(), dfTemp)

        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro durante a importação de dados:', str(e))
        return False
