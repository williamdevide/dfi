import pandas as pd

from src.config.infoDataOperations import infoDataOperation
from src.controller.databaseManipulation.operationsDB import readTableSQL
from src.script.tools.screenPrint import spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskItemWithRecords, spLineBoxTaskRecords, spLineBoxTaskErrors
from src.script.tools.tools import verifySuccess


def importDatabaseToDataframe(identity, dataframeHolder, infoParameters, infoDb, infoOperations, typeConnect):
    try:
        strMsg = f'Importando dados do {typeConnect}: Server:Database:[{infoDb.get_address()}:{infoDb.get_databaseName()}] para Dataframe principal:'
        spLineBoxTaskOpen(strMsg)
        infoTables = infoDataOperation(identity)

        # Iterate over the list and call downloadFile function for each item
        for index, (operation_name, operation) in enumerate(infoOperations.items(), start=1):
            totalFiles = len(infoOperations)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = operation.get_source()
            if typeConnect == 'Destino':
                tableName = operation.get_destiny()

            strMsg = 'Importando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithRecords(strMsg)

            # Realiza a chamada para importação do database para o dataframe
            verifySuccess(executeImportDatabaseToDataframe(identity, dataframeHolder, infoParameters, infoDb, operation, typeConnect))

        strMsg = f'Importando dados do {typeConnect}: Server:Database:[{infoDb.get_address()}:{infoDb.get_databaseName()}] para Dataframe principal:'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Erro ao importar informações do(s) database(s) de {typeConnect}:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False


def executeImportDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect):
    try:
        # Realiza a leitura do excel de origem caso existente
        success, dfTemp = readTableSQL(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect)

        if not success:
            return False

        totalRecords = '[' + str(dfTemp.shape[0]).rjust(6) + ' records]'
        spLineBoxTaskRecords(totalRecords)

        # REALIZAR A IMPORTAÇÃO PARA O DATAFRAME _DESTINY SE FOR O IMPORT DESTINY, CASO CONTRARIO REALIZAR A IMPORTAÇÃO PARA O PROGRAMNAME
        if typeConnect == 'Origem':
            # VERIFICA SE EXISTE O DF
            if dataframeHolder.get_df('df' + table.get_programName()) is None:
                # SE NÃO EXISTIR CRIA A PARTIR DO DFTEMP
                dataframeHolder.add_df('df' + table.get_programName() + '_Source', dfTemp)
            else:
                # SE EXISTIR PREENCHE ELE COM OS DADOS DO DFTEMP
                dataframeHolder.set_df('df' + table.get_programName() + '_Source', dfTemp)

        if typeConnect == 'Destino':
            # VERIFICA SE EXISTE O DF _DESTINY
            if dataframeHolder.get_df('df' + table.get_programName() + '_Destiny') is None:
                # SE NÃO EXISTIR CRIA A PARTIR DO DFTEMP
                dataframeHolder.add_df('df' + table.get_programName() + '_Destiny', dfTemp)
            else:
                # SE EXISTIR PREENCHE ELE COM OS DADOS DO DFTEMP
                dataframeHolder.set_df('df' + table.get_programName() + '_Destiny', dfTemp)

        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro durante a importação de dados:', str(e))
        return False
