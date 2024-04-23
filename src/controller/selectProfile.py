import sys

from src.config.infoDatabase import infoDatabaseSource, infoDatabaseDestiny
from src.config.infoFile import infoFileDestiny, infoFileSource
from src.controller.connections.connectDatabase import connectDatabase
from src.controller.connections.connectFileXls import connectFileXlsDestiny, connectFileXlsSource
from src.controller.databaseManipulation.exportDataframeToDatabase import exportDataframeToDatabase
from src.controller.databaseManipulation.importDatabaseToDataframe import importDatabaseToDataframe
from src.controller.excelManipulation.exportDataframeToXlsx import exportDataframeToXlsx
from src.controller.excelManipulation.importXlsToDataframe import importXlsFinalToDataframe
from src.script.tools.screenPrint import spLineBoxMiddle
from src.script.tools.tools import verifySuccess


def selectProfileImportDestiny(identity, dataframeHolder, infoParameter, tables):
    # Verifica onde está o destino dos dados
    if infoParameter.tecnologyDatastoreDestiny == 'Excel':
        infoFDestiny = infoFileDestiny(identity)
        verifySuccess(connectFileXlsDestiny(identity, dataframeHolder, infoParameter, infoFDestiny, tables, 'Destino'))
        spLineBoxMiddle()
        verifySuccess(importXlsFinalToDataframe(identity, dataframeHolder, infoParameter, infoFDestiny, tables, 'Destino'))

    elif infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(connectDatabase(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))
        spLineBoxMiddle()
        verifySuccess(importDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreDestiny]")
        input()


def selectProfileExportDestiny(identity, dataframeHolder, infoParameter, tables):
    # Verifica se o Destino dos dados está no Excel ou no SQL Server
    if infoParameter.tecnologyDatastoreDestiny == 'Excel':
        # infoFDestiny = infoFileDestiny(identity)
        spLineBoxMiddle()
        # verifySuccess(exportDataframeToXlsx(identity, dataframeHolder, infoParameter, infoFDestiny, tables, 'Destino'))

    elif infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        verifySuccess(exportDataframeToDatabase(identity, dataframeHolder, infoParameter, infoDbDestiny, tables, 'Destino'))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreDestiny]")
        input()


def selectProfileImportSource(identity, dataframeHolder, infoParameter, tables):
    # Verifica se a Origem dos dados está no Excel / SQL Server / PostgreSQL
    if infoParameter.tecnologyDatastoreSource == 'Excel':
        infoFSource = infoFileSource(identity)        # Arrumar quando for usar
        # verifySuccess(connectFileXlsSource(identity, infoSource))                                                   # Carrega informações de acesso ao arquivo de destino
        spLineBoxMiddle()
        # verifySuccess(importXlsFinalToDataframe(identity, dataframeHolder))                                         # Carrega conteúdo do arquivo destino no ChargeDestiny

    elif infoParameter.tecnologyDatastoreSource == 'SQL Server' or infoParameter.tecnologyDatastoreSource == 'PostgreSQL':
        infoDbSource = infoDatabaseSource(identity)
        verifySuccess(connectDatabase(identity, dataframeHolder, infoParameter, infoDbSource, tables, 'Origem'))
        spLineBoxMiddle()
        verifySuccess(importDatabaseToDataframe(identity, dataframeHolder, infoParameter, infoDbSource, tables, 'Origem'))

    else:
        print("Falha na leitura do parâmetro [tecnolgyDatastoreSource]")
        input()