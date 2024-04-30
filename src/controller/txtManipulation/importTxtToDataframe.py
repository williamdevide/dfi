import pandas as pd

from src.controller.dataframeManipulation.prepareAmbient import prepareAmbient
from src.controller.dataframeManipulation.unionDataframes import unionDataframes
from src.controller.dataframeManipulation.updateDataframe import updateDataframe
from src.controller.txtManipulation.operationTxt import readFileTxt
from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskOpen, spLineBoxTaskItemWithOutRecords, spLineBoxTaskStatus, spLineBoxTaskItemWithRecords, \
    spLineBoxTaskClose, spLineBoxTaskRecords
from src.script.tools.tools import verifySuccess


def importTxtToDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect):
    try:
        strMsg = f'Importando informações do(s) arquivo(s) de {typeConnect} para Dataframe principal.'
        spLineBoxTaskOpen(strMsg)

        # Gerando dataframe inicial com todas as datas e dia da semana. Será usado para merge com cada um dos importSeriesProduct
        spLineBoxTaskItemWithOutRecords('Preparando Ambiente:')
        verifySuccess(prepareAmbient(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect))

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
                        fileName = item.get_addressSource() + item.get_filename()
                    if typeConnect == 'Destino':
                        fileName = item.get_addressDestiny() + item.get_filename()

                    # Exibindo o número do índice e o número total de produtos
                    strMsg = 'Coletando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Arquivo:[' + fileName + ']:'
                    spLineBoxTaskItemWithRecords(strMsg)

                    if item.get_importMethod() == 'Download-txt':
                        # Realiza a chamada para importação do xls para o dataframe
                        verifySuccess(executeImportTxtToDataframe(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect))

            # Gerando dataframe final com a união dos dataframes de produtos
            verifySuccess(unionDataframes(identity, dataframeHolder, infoParameter, infoTables, infoProduct))

            # Atualizando dfChargeDestiny com os valores do dfUnion
            verifySuccess(updateDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct))

        strMsg = f'Importando informações do(s) arquivo(s) de {typeConnect} para Dataframe principal.'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Importando informações:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False

def executeImportTxtToDataframe(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect):
    try:
        # Realiza a leitura do excel de origem caso existente
        success, dfTemp = readFileTxt(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect)

        if not success:
            return False

        # NESSE TRECHO SÃO REALIZADAS TRATAMENTOS NECESSÁRIOS NO DFTEMP, COMO ORDENAÇÃO, PREENCHIMENTO DE CAMPOS VAZIOS, ETC...
        if not dfTemp.empty:
            if typeConnect == 'Origem':
                x = 1
            else:
                x = 1
        else:
            if typeConnect == 'Origem':
                x = 1
            else:
                x = 1

        totalRecords = '[' + str(dfTemp.shape[0]).rjust(6) + ' records]'
        spLineBoxTaskRecords(totalRecords)
        dataframeHolder.add_df('df' + item.get_item(), dfTemp)

        return True

    except Exception as e:
        strMsg = f'Executando importação de arquivo:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False
