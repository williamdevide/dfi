from src.controller.txtManipulation.operationTxt import writeFileTxt
from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskClose, spLineBoxTaskOpen, spLineBoxTaskItemWithOutRecords
from src.script.tools.tools import verifySuccess


def exportDataframeToTxt(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:
        strMsg = f'Exportando informações do Dataframe principal para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskOpen(strMsg)

        # Iterate over the list and call downloadFile function for each item
        for index, (item_name, item) in enumerate(infoItems.items(), start=1):
            totalFiles = len(infoItems)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = item.get_source()
            if typeConnect == 'Destino':
                tableName = item.get_destiny()

            strMsg = 'Exportando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithOutRecords(strMsg)

            # Grava DataFrame em um novo arquivo Excel
            success = writeFileTxt(identity, dataframeHolder, infoParameters, infoOperations, item, typeConnect)
            verifySuccess(success)

        strMsg = f'Exportando informações do Dataframe principal para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Exportando informações:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False




