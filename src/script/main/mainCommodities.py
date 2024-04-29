import logging

from src.config import infoDatabase
from src.config.infoDatabase import infoDatabaseDestiny
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny, clearDatabaseTableSourceAndDestiny
from src.config.infoFile import infoFileDestiny, infoFileSource
from src.config.infoFileProducts import infoFileProduct, clearInformationProduct
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.connections.connectFile import connectFile
from src.controller.dataframeManipulation.createMainDataframe import createMainDataframe
from src.controller.excelManipulation.importXlsToDataframe import importXlsSeriesToDataframe
from src.controller.httpManipulation.downloadXlsSeries import downloadXlsSeries
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileExportDestiny
from src.model.entities.entityDataframeHolder import DataFrameHolder
from src.script.tools.screenPrint import spLineBoxUp, spLineBoxTitle, spLineBoxDown, spLineBoxMiddle, spLineBoxText, spLineBoxBlank, spLineBlank, spHeader, \
    spLineBoxError
from src.script.tools.tools import verifySuccess, getParameter


def mainCommodities():
    identity = getParameter('dfcommodities_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    infoDatabase.dbSource = None
    infoDatabase.dbDestiny = None

    # Programa principal
    infoParameter = infoParametersApplication(identity)
    dataframeHolder = DataFrameHolder()  # Cria o dicionário de DFs
    infoTables = infoDatabaseTableSourceAndDestiny(identity)
    infoProduct = infoFileProduct(identity)

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0001-COMMODITIES] - Importação de dados de Commodities para geração de Histórico')
    spLineBoxMiddle()
    spLineBoxText('Data de ínicio de busca:', infoParameter.dateFieldValue)
    spLineBoxText('Source Datastore.......:', infoParameter.tecnologyDatastoreSource)
    spLineBoxText('Destiny Datastore......:', infoParameter.tecnologyDatastoreDestiny)
    spLineBoxMiddle()
    spHeader()
    spLineBoxMiddle()

    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxMiddle()
    verifySuccess(createMainDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct, 'Origem'))
    spLineBoxMiddle()
    verifySuccess(connectFile(identity, dataframeHolder, infoParameter, infoTables, infoProduct, 'Origem'))
    spLineBoxMiddle()
    # verifySuccess(downloadXlsSeries(identity))
    spLineBoxMiddle()
    verifySuccess(importXlsSeriesToDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct, 'Origem'))
    spLineBoxMiddle()
    selectProfileExportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxMiddle()
    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxDown()

    spLineBoxUp()
    spLineBoxTitle('Final do processo de importação de dados de Commodities para geração de Histórico')
    spLineBoxDown()
    spLineBlank()

    clearInformationProduct(infoProduct)
    clearDatabaseTableSourceAndDestiny(infoTables)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))
