import pandas as pd

from src.config.infoDatabase import infoDatabaseDestiny, infoDatabaseSource
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny
from src.config.infoFile import infoFileDestiny, infoFileSource
from src.config.infoParameters import infoParameters
from src.controller.databaseManipulation.operationsDB import readTableSQL
from src.controller.dataframeManipulation.fillMissingValues import fillMissingPrice, fillMissingDayOfWeek, fillMissingProduct
from src.script.tools.screenPrint import spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskItemWithRecords, spLineBoxTaskRecords, spLineBoxTaskErrors, \
    spLineBoxTaskItemWithOutRecords
from src.script.tools.tools import verifySuccess, convertAndOrderByData, mergeDataframesByData


def importDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDb, tables, typeConnect):
    try:
        strMsg = f'Carregando informações do(s) database(s) de {typeConnect} para Dataframe principal.'
        spLineBoxTaskOpen(strMsg)
        infoTables = infoDatabaseTableSourceAndDestiny(identity)

        # Iterate over the list and call downloadFile function for each item
        for index, (program, table) in enumerate(tables.items(), start=1):
            totalFiles = len(tables)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = table.get_source()
            if typeConnect == 'Destino':
                tableName = table.get_destiny()

            strMsg = 'Connecting..[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithRecords(strMsg)

            # Realiza a chamada para importação do database para o dataframe
            verifySuccess(executeImportDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect))

        strMsg = f'Final do carregamento das informações do(s) database(s) de {typeConnect} para Dataframe principal:'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Erro ao importar informações do(s) database(s) de {typeConnect}:'
        spLineBoxTaskErrors(strMsg, e)
        return False


def executeImportDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect):
    try:
        # Realiza a leitura do excel de origem caso existente
        success, dfTemp = readTableSQL(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect)

        if not success:
            return False

        # verifica se existe conteudo. se existir conteudo ordena e mescla com o dfMain criando o df[productName]]
        if not dfTemp.empty:

            if typeConnect == 'Origem':
                # condições para dftemp de origem com conteudo
                x = 1

            if typeConnect == 'Destino':
                # condições para dftemp de destino com conteudo
                x = 1

        else:
            if typeConnect == 'Origem':
                # condições para dftemp de origem sem conteudo
                x = 1

            if typeConnect == 'Destino':
                # condições para dftemp de destino sem conteudo
                dfTemp = pd.DataFrame()

        totalRecords = '[' + str(dfTemp.shape[0]).rjust(6) + ' records]'
        spLineBoxTaskRecords(totalRecords)

        if dataframeHolder.get_df('df' + table.get_programName() + '_Destiny') is None:
            dataframeHolder.add_df('df' + table.get_programName() + '_Destiny', dfTemp)
        else:
            dataframeHolder.set_df('df' + table.get_programName() + '_Destiny', dfTemp)

        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro durante a importação de dados:', str(e))
        return False
