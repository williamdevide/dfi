from src.config.infoDataItems import infoDataItem
from src.config.infoDatabase import infoDatabaseSource, infoDatabaseDestiny
from src.controller.connections.connectDatabase import connectDatabase
from src.controller.connections.connectFile import connectFile
from src.controller.databaseManipulation.exportDataframeToDatabase import exportDataframeToDatabase
from src.controller.databaseManipulation.importDatabaseToDataframe import importDatabaseToDataframe
from src.controller.dataframeManipulation.createMainDataframe import createMainDataframe
from src.controller.dataframeManipulation.processingDataframe import processingDataframe
from src.controller.excelManipulation.importXlsToDataframe import importXlsFinalToDataframe
from src.controller.txtManipulation.exportDataframeToTxt import exportDataframeToTxt
from src.controller.txtManipulation.importTxtToDataframe import importTxtToDataframe
from src.script.tools.screenPrint import spLineBoxMiddle
from src.script.tools.tools import verifySuccess


def selectProfileDataProcessing(identity, dataframeHolder, infoParameters, infoOperations):
    typeConnect = 'Processamento'
    verifySuccess(processingDataframe(identity, dataframeHolder, infoParameters, infoOperations, typeConnect))

def selectProfileExportHistory(identity, dataframeHolder, infoParameters, infoOperations):
    typeConnect = 'Histórico'
    infoDbDestiny = infoDatabaseDestiny(identity)
    verifySuccess(exportDataframeToTxt(identity, dataframeHolder, infoParameters, infoDbDestiny, infoOperations, typeConnect))


def selectProfileExportDestiny(identity, dataframeHolder, infoParameters, infoOperations):
    typeConnect = 'Destino'
    # Verifica se o Destino dos dados está no Excel ou no SQL Server
    if infoParameters.tecnologyDatastoreDestiny == 'Txt':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(exportDataframeToTxt(identity, dataframeHolder, infoParameters, infoDbDestiny, infoOperations, typeConnect))

    elif infoParameters.tecnologyDatastoreDestiny == 'Excel':
        # infoFDestiny = infoFileDestiny(identity)
        spLineBoxMiddle()
        # verifySuccess(exportDataframeToXlsx(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))

    elif infoParameters.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(exportDataframeToDatabase(identity, dataframeHolder, infoParameters, infoDbDestiny, infoOperations, typeConnect))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreDestiny]")
        input()


def selectProfileImportSource(identity, dataframeHolder, infoParameters, infoOperations):
    typeConnect = 'Origem'
    if infoParameters.tecnologyDatastoreSource == 'Txt' or infoParameters.tecnologyDatastoreSource == 'Excel':
        infoItems = infoDataItem(identity)
        verifySuccess(createMainDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))
        spLineBoxMiddle()
        verifySuccess(connectFile(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))
        spLineBoxMiddle()
        if infoParameters.tecnologyDatastoreSource == 'Txt':
            verifySuccess(importTxtToDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect))
        elif infoParameters.tecnologyDatastoreSource == 'Excel':
            verifySuccess(importXlsFinalToDataframe(identity, dataframeHolder))
        else:
            print("Parâmetro [tecnolgyDatastoreSource] com valor inválido.")
            input()

    elif infoParameters.tecnologyDatastoreSource == 'SQL Server' or infoParameters.tecnologyDatastoreSource == 'PostgreSQL':
        infoDbSource = infoDatabaseSource(identity)
        verifySuccess(connectDatabase(identity, dataframeHolder, infoParameters, infoDbSource, infoOperations, typeConnect))
        spLineBoxMiddle()
        verifySuccess(importDatabaseToDataframe(identity, dataframeHolder, infoParameters, infoDbSource, infoOperations, typeConnect))

    else:
        print("Parâmetro [tecnolgyDatastoreSource] com valor inválido.")
        input()


def selectProfileImportDestiny(identity, dataframeHolder, infoParameters, infoOperations):
    typeConnect = 'Destino'
    # Verifica onde está o destino dos dados
    if infoParameters.tecnologyDatastoreDestiny == 'Excel':
        infoProduct = infoDataItem(identity)
        # verifySuccess(connectFile(identity, dataframeHolder, infoParameters, infoFDestiny, infoOperations, typeConnect))
        spLineBoxMiddle()
        # verifySuccess(importXlsFinalToDataframe(identity, dataframeHolder, infoParameters, infoFDestiny, infoOperations, typeConnect))

    elif infoParameters.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(connectDatabase(identity, dataframeHolder, infoParameters, infoDbDestiny, infoOperations, typeConnect))
        spLineBoxMiddle()
        verifySuccess(importDatabaseToDataframe(identity, dataframeHolder, infoParameters, infoDbDestiny, infoOperations, typeConnect))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreDestiny]")
        input()
