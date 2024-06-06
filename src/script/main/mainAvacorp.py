import logging

from src.config import infoDatabase
from src.config.infoDataItems import infoDataItem, clearInformationDataItem
from src.config.infoDataOperations import infoDataOperation, clearInformationDataOperation
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileImportSource, selectProfileExportDestiny, selectProfileDataProcessing
from src.model.entities.entityDataframeHolder import DataFrameHolder
from src.script.tools.screenPrint import spLineBoxUp, spLineBoxTitle, spLineBoxDown, spLineBoxMiddle, spLineBoxText, spLineBlank, spHeader
from src.script.tools.tools import getParameter


def mainAvacorp():
    identity = getParameter('dfavacorp_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    infoDatabase.dbSource = None
    infoDatabase.dbDestiny = None

    # Programa principal
    dataframeHolder = DataFrameHolder()  # Cria o dicionário de DFs

    infoParameters = infoParametersApplication(identity)
    infoOperations = infoDataOperation(identity)
    infoItems = infoDataItem(identity)

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0002-AVACORP] - Importação de dados do Avacorp')
    spLineBoxMiddle()
    spLineBoxText('Data de ínicio de busca:', infoParameters.dateFieldValue)
    spLineBoxText('Source Datastore.......:', infoParameters.tecnologyDatastoreSource)
    spLineBoxText('Destiny Datastore......:', infoParameters.tecnologyDatastoreDestiny)
    spLineBoxMiddle()
    spHeader()
    spLineBoxMiddle()

    selectProfileImportDestiny(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxMiddle()
    selectProfileImportSource(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxMiddle()
    selectProfileDataProcessing(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxMiddle()
    selectProfileExportDestiny(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxMiddle()
    selectProfileImportDestiny(identity, dataframeHolder, infoParameters, infoOperations)
    spLineBoxDown()

    spLineBoxUp()
    spLineBoxTitle('Final do processo de importação de dados do Avacorp')
    spLineBoxDown()
    spLineBlank()

    clearInformationDataItem(infoItems)
    clearInformationDataOperation(infoOperations)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))
