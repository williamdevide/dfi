from src.config.infoDatabase import infoDatabaseSource, infoDatabaseDestiny
from src.config.infoDataItems import infoDataItem
from src.controller.connections.connectDatabase import connectDatabase
from src.controller.connections.connectFile import connectFile
from src.controller.databaseManipulation.exportDataframeToDatabase import exportDataframeToDatabase
from src.controller.databaseManipulation.importDatabaseToDataframe import importDatabaseToDataframe
from src.controller.dataframeManipulation.createMainDataframe import createMainDataframe
from src.controller.excelManipulation.importXlsToDataframe import importXlsFinalToDataframe
from src.controller.txtManipulation.exportDataframeToTxt import exportDataframeToTxt
from src.controller.txtManipulation.importTxtToDataframe import importTxtToDataframe
from src.script.tools.screenPrint import spLineBoxMiddle
from src.script.tools.tools import verifySuccess


def selectProfileExportHistory(identity, dataframeHolder, infoParameter, tables):
    infoDbDestiny = infoDatabaseDestiny(identity)
    verifySuccess(exportDataframeToTxt(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Histórico'))


def selectProfileExportDestiny(identity, dataframeHolder, infoParameter, tables):
    # Verifica se o Destino dos dados está no Excel ou no SQL Server
    if infoParameter.tecnologyDatastoreDestiny == 'Txt':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(exportDataframeToTxt(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))

    elif infoParameter.tecnologyDatastoreDestiny == 'Excel':
        # infoFDestiny = infoFileDestiny(identity)
        spLineBoxMiddle()
        # verifySuccess(exportDataframeToXlsx(identity, dataframeHolder, infoParameter, infoFDestiny, tables, 'Destino'))

    elif infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(exportDataframeToDatabase(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreDestiny]")
        input()


def selectProfileImportSource(identity, dataframeHolder, infoParameter, infoTables):
    typeConnect = 'Origem'
    if infoParameter.tecnologyDatastoreSource == 'Txt' or infoParameter.tecnologyDatastoreSource == 'Excel':
        infoProduct = infoDataItem(identity)
        verifySuccess(createMainDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect))
        spLineBoxMiddle()
        verifySuccess(connectFile(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect))
        spLineBoxMiddle()
        # mexer nesse agora
        if infoParameter.tecnologyDatastoreSource == 'Txt':
            verifySuccess(importTxtToDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct, typeConnect))
        elif infoParameter.tecnologyDatastoreSource == 'Excel':
            verifySuccess(importXlsFinalToDataframe(identity, dataframeHolder))
        else:
            print("Parâmetro [tecnolgyDatastoreSource] com valor inválido.")
            input()

    elif infoParameter.tecnologyDatastoreSource == 'SQL Server' or infoParameter.tecnologyDatastoreSource == 'PostgreSQL':
        infoDbSource = infoDatabaseSource(identity)
        verifySuccess(connectDatabase(identity, dataframeHolder, infoParameter, infoDbSource, infoTables, typeConnect))
        spLineBoxMiddle()
        verifySuccess(importDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDbSource, infoTables, typeConnect))

    else:
        print("Parâmetro [tecnolgyDatastoreSource] com valor inválido.")
        input()


def selectProfileImportDestiny(identity, dataframeHolder, infoParameter, tables):
    typeConnect = 'Destino'
    # Verifica onde está o destino dos dados
    if infoParameter.tecnologyDatastoreDestiny == 'Excel':
        infoProduct = infoDataItem(identity)
        # verifySuccess(connectFile(identity, dataframeHolder, infoParameter, infoFDestiny, tables, 'Destino'))
        spLineBoxMiddle()
        # verifySuccess(importXlsFinalToDataframe(identity, dataframeHolder, infoParameter, infoFDestiny, tables, 'Destino'))

    elif infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(connectDatabase(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))
        spLineBoxMiddle()
        verifySuccess(importDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreDestiny]")
        input()
