import logging

from src.config.infoDatabase import infoDatabaseDestiny, infoDatabaseSource
from src.config import infoDatabase, infoDatabaseTables
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny, removeDatabaseTableSourceAndDestiny, clearDatabaseTableSourceAndDestiny
from src.config.infoFileProducts import infoFileProduct
from src.config.infoParameters import infoParameters
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
    infoParameter = infoParameters(identity)
    dataframeHolder = DataFrameHolder()  # Cria o dicionário de DFs
    infoTables = infoDatabaseTableSourceAndDestiny(identity)
    infoProduct = infoFileProduct(identity)

    strInfoSource = ''
    if infoParameter.tecnologyDatastoreSource == 'PostgreSQL':
        infoDbSource = infoDatabaseSource(identity)
        strInfoSource = 'Server:Database: ' + infoDbSource.get_address() + ":" + infoDbSource.get_databaseName()
    else:
        spLineBoxError('Parâmetro encontrado com valor incorreto: Esse módulo aceita somente a origem [PostgreSQL]')
        input()

    strInfoDestiny = ''
    if infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        strInfoDestiny = 'Server:Database: ' + infoDbDestiny.get_address() + ":" + infoDbDestiny.get_databaseName()
    else:
        spLineBoxError('Parâmetro encontrado com valor incorreto: Esse módulo aceita somente o destino [SQL Server]')
        input()

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0002-AVACORP] - Importação de dados do Avacorp')
    spLineBoxMiddle()
    spLineBoxText('Data de ínicio de busca:', infoParameter.dateFieldValue)
    spLineBoxBlank()
    spLineBoxText('Source Datastore:', infoParameter.tecnologyDatastoreSource)
    spLineBoxText('Connection =', strInfoSource)
    spLineBoxBlank()
    spLineBoxText('Destiny Datastore:', infoParameter.tecnologyDatastoreDestiny)
    spLineBoxText('Connection =', strInfoDestiny)
    spLineBoxMiddle()
    # spCount()
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

    clearDatabaseTableSourceAndDestiny(infoTables)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))
