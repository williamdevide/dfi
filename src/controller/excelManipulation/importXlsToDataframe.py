import pandas as pd

from src.config.infoFile import infoFileDestiny
from src.controller.dataframeManipulation.fillMissingValues import fillMissingFieldIntervals, fillMissingDayOfWeek, fillMissingFieldFull
from src.controller.dataframeManipulation.prepareAmbient import prepareAmbient
from src.controller.dataframeManipulation.unionDataframes import unionDataframes
from src.controller.dataframeManipulation.updateDataframe import updateDataframe
from src.controller.excelManipulation.operationsExcel import readFileExcel
from src.script.tools.screenPrint import spLineBoxTaskRecords, spLineBoxTaskOpen, spLineBoxTaskItemWithOutRecords, spLineBoxTaskItemWithRecords, spLineBoxTaskClose, \
    spLineBoxTaskErrors, spLineBoxTaskStatus
from src.script.tools.tools import verifySuccess, convertAndOrderByData, mergeDataframesInner


def importXlsSeriesToDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:
        strMsg = 'Importação de arquivos em série Xlsx para Dataframe principal:'
        spLineBoxTaskOpen(strMsg)

        # Gerando dataframe inicial com todas as datas e dia da semana. Será usado para merge com cada um dos importSeriesProduct
        spLineBoxTaskItemWithOutRecords('Preparando Ambiente:')
        verifySuccess(prepareAmbient(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))

        totalFiles = len(infoItems)
        totalFilesYes = sum(1 for df in infoItems.values() if 'get_importar' in dir(df) and df.get_importar() == 'SIM')

        if totalFilesYes < totalFiles:
            strMsg = f'Informação: Encontrados parâmetros para {totalFiles} arquivo(s) de origem. {totalFilesYes} arquivo(s) a ser importados.'
            spLineBoxTaskItemWithOutRecords(strMsg)
            spLineBoxTaskStatus('')

        if totalFilesYes > 0:
            # Iterate over the list and call downloadFile function for each item
            for index, (item_name, item) in enumerate(infoItems.items(), start=1):

                if item.get_importar() == 'SIM':

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Importing...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + item.get_filename() + ']: '
                    spLineBoxTaskItemWithRecords(strMsg)

                    if item.get_importMethod() == 'Download-xls':
                        # Realiza a chamada para importação do xls para o dataframe
                        verifySuccess(executeImportXlsToDataframe(identity, dataframeHolder, infoParameters, infoOperations, item, typeConnect))

            # Gerando dataframe final com a união dos dataframes de produtos
            verifySuccess(unionDataframes(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))

            # Atualizando dfChargeDestiny com os valores do dfUnion
            verifySuccess(updateDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))

        strMsg = 'Importação de arquivos em série Xlsx para Dataframe principal:'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = 'Importação de arquivos em série Xlsx para Dataframe principal:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False


def importXlsFinalToDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:

        print(' => Carregando informações do arquivo de destino para Dataframe principal.')

        infoDestiny = infoFileDestiny(identity)

        # Exibindo o número do índice e o número total de produtos
        print(f'     -> Importing...[01/01]: Arquivo:[{infoDestiny.get_name():<20}]: ', end='')

        # Realiza a chamada para importação do xls para o dataframe
        verifySuccess(executeImportXlsToDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoDestiny, typeConnect))

        print('     /=> Final do carregamento das informações do arquivo de destino para Dataframe principal.', end='')
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao importar informações do arquivo de destino:', str(e))
        return False


def executeImportXlsToDataframe(identity, dataframeHolder, infoParameters, infoOperations, item, typeConnect):
    try:
        # Realiza a leitura do excel de origem caso existente
        success, dfTemp = readFileExcel(identity, dataframeHolder, infoParameters, infoOperations, item, typeConnect)

        if not success:
            return False

        # verifica se existe conteudo. se existir conteudo ordena e mescla com o dfMain criando o df[productName]]
        if not dfTemp.empty:

            if typeConnect == 'Origem':
                # Ordenar DataFrame pela coluna 'Data'
                dfTemp = convertAndOrderByData(identity, dfTemp, infoParameters.dateField, infoParameters.dateFieldFormat)
                dfTemp = fillMissingDayOfWeek(identity, dfTemp, infoParameters.dateField, infoParameters.dayWeekField)

                # Dataframe principal recebe os dados do dataframe local
                dfAmbient = dataframeHolder.get_df('dfAmbient')
                dfTemp = mergeDataframesInner(identity, dfAmbient, dfTemp)
                dfTemp = fillMissingFieldIntervals(identity, dfTemp, infoParameters.priceField)
                dfTemp = fillMissingFieldIntervals(identity, dfTemp, 'comhis_price_unit')
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_conversion_factor', item.get_conversionFactor())
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_unit_destiny', item.get_unitDestiny())
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_unit_source', item.get_unitSource())
                dfTemp = fillMissingFieldFull(identity, dfTemp, 'comhis_SAP_product', item.get_SAPProduct())
                dfTemp = fillMissingFieldFull(identity, dfTemp, infoParameters.structureFieldsDataframeSource[2], item.get_item())
        else:
            if typeConnect == 'Destino':
                dfTemp = pd.DataFrame()

        totalRecords = '[' + str(dfTemp.shape[0]).rjust(6) + ' records]'
        spLineBoxTaskRecords(totalRecords)
        dataframeHolder.add_df('df' + item.get_item(), dfTemp)

        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro durante a importação de dados:', str(e))
        return False
