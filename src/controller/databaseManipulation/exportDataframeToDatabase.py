from src.controller.databaseManipulation.operationsDB import writeTableSQL
from src.script.tools.screenPrint import spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskErrors, spLineBoxTaskRecords, \
    spLineBoxTaskItemWithRecords
from src.script.tools.tools import verifySuccess


def exportDataframeToDatabase(identity, dataframeHolder, infoParameter, infoDb, infoOperations, typeConnect):
    try:
        strMsg = f'Exportando informações do(s) dataframe(s) para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskOpen(strMsg)

        # Iterate over the list and call downloadFile function for each item
        for index, (program, operation) in enumerate(infoOperations.items(), start=1):
            totalFiles = len(infoOperations)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = operation.get_source()
            if typeConnect == 'Destino':
                tableName = operation.get_destiny()

            strMsg = 'Exportando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithRecords(strMsg)

            # Grava DataFrame em um novo arquivo Excel
            success, dfResult = writeTableSQL(identity, dataframeHolder, infoParameter, infoDb, operation, typeConnect)

            totalRecords = '[' + str(dfResult.shape[0]).rjust(6) + ' records]'
            spLineBoxTaskRecords(totalRecords)

            verifySuccess(success)

        strMsg = f'Exportando informações do(s) dataframe(s) para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Erro ao exportar informações para o(s) database(s) de {typeConnect}:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False
