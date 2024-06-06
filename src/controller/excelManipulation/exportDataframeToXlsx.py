# function para gravação do dataframe no xlsx de destino
from src.config.infoFile import infoFileDestiny
from src.controller.excelManipulation.operationsExcel import writeFileExcel
from src.script.tools.screenPrint import spLineBoxTaskOpen, spLineBoxTaskClose, spLineBoxTaskItemWithOutRecords, spLineBoxTaskErrors
from src.script.tools.tools import verifySuccess


def exportDataframeToXlsx(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:
        spLineBoxTaskOpen('Exportando dataframe final para destino:')
        infoDestiny = infoFileDestiny(identity)

        dfFinal = dataframeHolder.get_df('dfFinal')

        # Exibindo o número do índice e o número total de produtos
        strMsg = 'Exporting...[01/01]: Arquivo:[' + infoDestiny.get_name() + ']:'
        spLineBoxTaskItemWithOutRecords(strMsg)

        # Grava DataFrame em um novo arquivo Excel
        success = writeFileExcel(identity, infoDestiny.get_name(), infoDestiny.get_addressDestiny(), infoDestiny.get_sheet(),
                                 infoDestiny.get_header(), infoDestiny.get_columns(), dfFinal)
        verifySuccess(success)

        spLineBoxTaskClose('Final da exportação do dataframe final para destino:')
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao exportar arquivo de destino:', str(e))
        return False
