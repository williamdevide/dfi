import logging

from src.config import infoDatabase
from src.config.infoDatabase import infoDatabaseDestiny
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny, clearDatabaseTableSourceAndDestiny
from src.config.infoFile import infoFileSource
from src.config.infoParametersApplication import infoParametersApplication
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileImportSource, selectProfileExportDestiny, selectProfileExportHistory
from src.model.entities.entityDataframeHolder import DataFrameHolder
from src.script.tools.screenPrint import spLineBoxError, spLineBoxUp, spLineBoxTitle, spLineBoxText, spLineBoxMiddle, spLineBoxBlank, spHeader, spLineBoxDown, spLineBlank
from src.script.tools.tools import getParameter


def mainBalancaSP6000():
    identity = getParameter('dfbalancasp6000_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    infoDatabase.dbSource = None
    infoDatabase.dbDestiny = None

    # Programa principal
    infoParameter = infoParametersApplication(identity)
    dataframeHolder = DataFrameHolder()  # Cria o dicionário de DFs
    infoTables = infoDatabaseTableSourceAndDestiny(identity)

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0003-BALANCASP6000] - Importação de dados de pesagem de veículos de carga na Balança SP-6000 para geração de Histórico')
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
    selectProfileExportHistory(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxMiddle()
    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    spLineBoxDown()

    spLineBoxUp()
    spLineBoxTitle('Final do processo de importação de dados de dados de pesagem de veículos de carga na Balança SP-6000 para geração de Histórico')
    spLineBoxDown()
    spLineBlank()


    clearDatabaseTableSourceAndDestiny(infoTables)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))
