import sys
from src.controller.databaseController.controllerDB import DataController
from src.script.tools.screenPrint import spLineBoxTaskUnique, spLineBoxTaskErrors, spLineBoxTaskItemWithRecords, spLineBoxTaskClose, spLineBoxTaskOpen, \
    spLineBoxTaskItemWithOutRecords
from src.script.tools.tools import verifyExtensionSQL, verifySuccess


def connectDatabase(identity, dataframeHolder, infoParameter, infoDb, tables, typeConnect):
    try:
        strMsg = 'Conexão com database(s) e tabela(s) de ' + typeConnect + ':'
        spLineBoxTaskOpen(strMsg)
        # Instanciando o controlador de dados
        data_controller = DataController(identity, infoDb)

        # Abre a conexão com o banco de dados
        data_controller.open_connection()

        # Verifica se é possível a conexão com o banco de dados
        if not data_controller.verify_connection():
            strMsg = 'Erro ao conectar ao database de ' + typeConnect
            spLineBoxTaskErrors(strMsg)
            input()

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

            spLineBoxTaskItemWithOutRecords(strMsg)

            # Verifica se será usado tabela ou consulta sql
            if not verifyExtensionSQL(tableName):
                # Caso seja tabela, verifica se a tabela existe no banco de dados
                verifySuccess(data_controller.verify_table_exists(tableName))
            else:
                verifySuccess(True)

        strMsg = f'Final do conexão com database(s) e tabela(s) de {typeConnect}:'
        spLineBoxTaskClose(strMsg)

        # Fecha a conexão com o banco de dados
        data_controller.close_connection()

        # Retorna True se o arquivo foi encontrado e está disponível para conexão
        return True

    except Exception as e:
        strMsg = 'Erro ao conectar ao database de ' + typeConnect + ': '
        spLineBoxTaskErrors(strMsg, str(e))
        return None
