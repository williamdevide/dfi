from src.controller.txtManipulation.operationTxt import writeFileTxt
from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskClose, spLineBoxTaskOpen
from src.script.tools.tools import verifySuccess


def exportDataframeToTxt(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect):
    try:
        strMsg = f'Exportando informações do Dataframe principal para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskOpen(strMsg)


        '''
        ESSE VEIO DO DATAFRAME TO XLS
        infoDestiny = infoFileDestiny(identity)

        dfFinal = dataframeHolder.get_df('dfFinal')

        # Exibindo o número do índice e o número total de produtos
        strMsg = 'Exportando..[01/01]: Arquivo:[' + infoDestiny.get_name() + ']:'
        spLineBoxTaskItemWithOutRecords(strMsg)
        '''


        '''
        ESSE VEIO DO DATAFRAME TO DATABASE
        # Iterate over the list and call downloadFile function for each item
        for index, (program, table) in enumerate(tables.items(), start=1):
            totalFiles = len(tables)

            # Exibindo o número do índice e o número total de registros
            tableName = ''
            if typeConnect == 'Origem':
                tableName = table.get_source()
            if typeConnect == 'Destino':
                tableName = table.get_destiny()

            strMsg = 'Exportando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + tableName + ']: '

            spLineBoxTaskItemWithRecords(strMsg)

            # Grava DataFrame em um novo arquivo Excel
            success, dfResult = writeTableSQL(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect)

            totalRecords = '[' + str(dfResult.shape[0]).rjust(6) + ' records]'
            spLineBoxTaskRecords(totalRecords)

            verifySuccess(success)
        '''
        # Grava DataFrame em um novo arquivo txt
        success = writeFileTxt(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect)
        verifySuccess(success)



        strMsg = f'Exportando informações do Dataframe principal para o(s) arquivo(s) de {typeConnect}.'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        strMsg = f'Exportando informações:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False