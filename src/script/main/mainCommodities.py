import logging

from src.config.infoDataItems import infoDataItem, clearInformationDataItem
from src.config.infoDataOperations import infoDataOperation, clearInformationDataOperation
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.connections.connectFile import connectFile
from src.controller.dataframeManipulation.createMainDataframe import createMainDataframe
from src.controller.excelManipulation.importXlsToDataframe import importXlsSeriesToDataframe
from src.controller.httpManipulation.downloadXlsSeries import downloadXlsSeries
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileExportDestiny
from src.model.entities.entityDataframeHolder import DataFrameHolder
from src.script.tools.screenPrint import spLineBoxUp, spLineBoxTitle, spLineBoxDown, spLineBoxMiddle, spLineBoxText, spLineBlank, spHeader
from src.script.tools.tools import verifySuccess, getParameter


def mainCommodities():
    identity = getParameter('dfcommodities_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    # Programa principal
    dataframeHolder = DataFrameHolder()  # Cria o dicionário de DFs

    infoParameters = infoParametersApplication(identity)
    infoOperations = infoDataOperation(identity)
    infoItems = infoDataItem(identity)

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0001-COMMODITIES] - Importação de dados de Commodities para geração de Histórico')
    spLineBoxMiddle()
    spLineBoxText('Data de ínicio de busca:', infoParameters.dateFieldValue)
    spLineBoxText('Source Datastore.......:', infoParameters.tecnologyDatastoreSource)
    spLineBoxText('Destiny Datastore......:', infoParameters.tecnologyDatastoreDestiny)
    spLineBoxMiddle()
    spHeader()
    spLineBoxMiddle()

    selectProfileImportDestiny(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxMiddle()
    verifySuccess(createMainDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, 'Origem'))
    spLineBoxMiddle()
    verifySuccess(connectFile(identity, dataframeHolder, infoParameters, infoOperations, infoItems, 'Origem'))
    spLineBoxMiddle()
    verifySuccess(downloadXlsSeries(identity))
    spLineBoxMiddle()
    verifySuccess(importXlsSeriesToDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, 'Origem'))
    spLineBoxMiddle()
    selectProfileExportDestiny(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxMiddle()
    selectProfileImportDestiny(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxDown()

    spLineBoxUp()
    spLineBoxTitle('Final do processo de importação de dados de Commodities para geração de Histórico')
    spLineBoxDown()
    spLineBlank()

    clearInformationDataItem(infoItems)
    clearInformationDataOperation(infoOperations)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))
