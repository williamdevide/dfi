import logging

from src.config import infoDatabase
from src.config.infoDatabase import infoDatabaseDestiny, infoDatabaseSource
from src.config.infoDataOperations import infoDatabaseTableSourceAndDestiny, clearDatabaseTableSourceAndDestiny
from src.config.infoDataItems import infoDataItem, clearInformationDataItem
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileImportSource, selectProfileExportDestiny
from src.model.entities.entityDataframeHolder import DataFrameHolder
from src.script.tools.screenPrint import spLineBoxUp, spLineBoxTitle, spLineBoxDown, spLineBoxMiddle, spLineBoxText, spLineBoxBlank, spLineBlank, spHeader, \
    spLineBoxError
from src.script.tools.tools import getParameter


def mainAvacorp():
    identity = getParameter('dfavacorp_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    infoDatabase.dbSource = None
    infoDatabase.dbDestiny = None

    # Programa principal
    infoParameter = infoParametersApplication(identity)
    dataframeHolder = DataFrameHolder()  # Cria o dicionário de DFs
    infoTables = infoDatabaseTableSourceAndDestiny(identity)
    infoProduct = infoDataItem(identity)

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0002-AVACORP] - Importação de dados do Avacorp')
    spLineBoxMiddle()
    spLineBoxText('Data de ínicio de busca:', infoParameter.dateFieldValue)
    spLineBoxText('Source Datastore.......:', infoParameter.tecnologyDatastoreSource)
    spLineBoxText('Destiny Datastore......:', infoParameter.tecnologyDatastoreDestiny)
    spLineBoxMiddle()
    spHeader()
    spLineBoxMiddle()

    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxMiddle()
    selectProfileImportSource(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxMiddle()
    selectProfileExportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxMiddle()
    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxDown()

    spLineBoxUp()
    spLineBoxTitle('Final do processo de importação de dados do Avacorp')
    spLineBoxDown()
    spLineBlank()

    clearInformationDataItem(infoProduct)
    clearDatabaseTableSourceAndDestiny(infoTables)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))
