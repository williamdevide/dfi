import logging

from src.config import infoDatabase, infoDatabaseTables
from src.config.infoDatabase import infoDatabaseDestiny, dbDestiny, dbSource
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny, removeDatabaseTableSourceAndDestiny, clearDatabaseTableSourceAndDestiny
from src.config.infoFile import infoFileDestiny, infoFileSource
from src.config.infoFileProducts import infoFileProduct
from src.config.infoParameters import infoParameters
from src.controller.dataframeManipulation.createMainDataframe import createMainDataframe

from src.controller.excelManipulation.importXlsToDataframe import importXlsSeriesToDataframe
from src.controller.connections.connectFile import connectFile
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileExportDestiny

from src.script.tools.screenPrint import spLineBoxUp, spLineBoxTitle, spLineBoxDown, spLineBoxMiddle, spLineBoxText, spLineBoxBlank, spLineBlank, spCount, spHeader, \
    spLineBoxError
from src.script.tools.tools import verifySuccess, getParameter
from src.model.entities.entityDataframeHolder import DataFrameHolder


def mainCommodities():
    identity = getParameter('dfcommodities_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    infoDatabase.dbSource = None
    infoDatabase.dbDestiny = None

    # Programa principal
    infoParameter = infoParameters(identity)
    dataframeHolder = DataFrameHolder()                                                     # Cria o dicionário de DFs
    infoTables = infoDatabaseTableSourceAndDestiny(identity)
    infoProduct = infoFileProduct(identity)

    strInfoSource = ''
    if infoParameter.tecnologyDatastoreSource == 'Excel':
        infoFSource = infoFileSource(identity)
        strInfoSource = 'Local : Arquivo: ' + infoFSource.get_address() + " : " + infoFSource.get_name()
    else:
        spLineBoxError('Parâmetro encontrado com valor incorreto: Esse módulo aceita somente a origem [Excel]')
        input()

    strInfoDestiny = ''
    if infoParameter.tecnologyDatastoreDestiny == 'Excel':
        infoFDestiny = infoFileDestiny(identity)
        strInfoDestiny = 'Local\\Arquivo: ' + infoFDestiny.get_address() + infoFDestiny.get_name()
    elif infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        strInfoDestiny = 'Server:Database: ' + infoDbDestiny.get_address() + ":" + infoDbDestiny.get_databaseName()
    else:
        spLineBoxError('Parâmetro encontrado com valor incorreto: Esse módulo aceita somente o destino [SQL Server]')
        input()

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0001-COMMODITIES] - Importação de dados de Commodities para geração de Histórico')
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

    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)                            # Seleciona o tipo de importação da base de destino e
    # realiza a importação para o dfChargeDestiny
    spLineBoxMiddle()
    verifySuccess(createMainDataframe(identity, dataframeHolder, infoParameter, infoTables))                    # Cria mainDF
    spLineBoxMiddle()
    verifySuccess(connectFile(identity, dataframeHolder, infoParameter, infoTables, infoProduct, 'Origem'))      # Cria a matriz com os objetos contendo as informações dos produtos
    spLineBoxMiddle()
    # verifySuccess(downloadXlsSeries(identity))                                                                  # Realiza download dos arquivos de séries xls
    spLineBoxMiddle()
    verifySuccess(importXlsSeriesToDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct))
    spLineBoxMiddle()
    selectProfileExportDestiny(identity, dataframeHolder, infoParameter, infoTables)                             # Seleciona o tipo de exportação da base de destino e
    # realiza a exp
    spLineBoxMiddle()
    selectProfileImportDestiny(identity, dataframeHolder, infoParameter, infoTables)                             # Seleciona o tipo de importação da base de destino e
    # realiza a importação para o dfChargeDestiny
    spLineBoxDown()

    spLineBoxUp()
    spLineBoxTitle('Final do processo de importação de dados de Commodities para geração de Histórico')
    spLineBoxDown()
    spLineBlank()

    clearDatabaseTableSourceAndDestiny(infoTables)

    # Registrando a conclusão da execução no log
    logging.info("    => {} - Execução concluída".format(identity))



