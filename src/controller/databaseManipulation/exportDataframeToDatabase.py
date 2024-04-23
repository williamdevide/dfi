from src.config.infoDatabase import infoDatabaseDestiny
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny
from src.config.infoFile import infoFileDestiny
from src.controller.databaseManipulation.operationsDB import writeTableSQL
from src.script.tools.screenPrint import spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskItemWithOutRecords, spLineBoxTaskErrors, spLineBoxTaskRecords, \
    spLineBoxTaskItemWithRecords
from src.script.tools.tools import verifySuccess


def exportDataframeToDatabase(identity, dataframeHolder, infoParameter, infoDb, tables, typeConnect):
    try:
        strMsg = f'Exportando informações do(s) dataframe(s) para os database(s) de {typeConnect}.'
        spLineBoxTaskOpen(strMsg)

        # Iterate over the list and call downloadFile function for each item
        for index, (program, table) in enumerate(tables.items(), start=1):
            totalFiles = len(tables)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = table.get_source()
            if typeConnect == 'Destino':
                tableName = table.get_destiny()

            strMsg = 'Exporting..[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithRecords(strMsg)

            # Grava DataFrame em um novo arquivo Excel
            success, dfResult = writeTableSQL(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect)

            totalRecords = '[' + str(dfResult.shape[0]).rjust(6) + ' records]'
            spLineBoxTaskRecords(totalRecords)

            verifySuccess(success)

        strMsg = f'Final da exportação das informações do(s) dataframe(s) para os database(s) de {typeConnect}:'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Erro ao exportar informações para o(s) database(s) de {typeConnect}:'
        spLineBoxTaskErrors(strMsg, e)
        return False
