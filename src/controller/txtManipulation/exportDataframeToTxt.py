from src.controller.txtManipulation.operationTxt import writeFileTxt
from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskClose, spLineBoxTaskOpen, spLineBoxTaskItemWithRecords, spLineBoxTaskRecords, spLineBoxTaskItemWithOutRecords
from src.script.tools.tools import verifySuccess, deleteLinesTxt


def exportDataframeToTxt(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect):
    try:
        strMsg = f'Exportando informações do Dataframe principal para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskOpen(strMsg)

        # Iterate over the list and call downloadFile function for each item
        for index, (program, table) in enumerate(infoProduct.items(), start=1):
            totalFiles = len(infoProduct)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = table.get_source()
            if typeConnect == 'Destino':
                tableName = table.get_destiny()

            strMsg = 'Exportando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithOutRecords(strMsg)

            # Grava DataFrame em um novo arquivo Excel
            success = writeFileTxt(identity, dataframeHolder, infoParameter, infoTables, table, typeConnect)
            verifySuccess(success)

        strMsg = f'Exportando informações do Dataframe principal para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Exportando informações:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False




