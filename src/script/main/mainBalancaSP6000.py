import logging

from src.config import infoDatabase
from src.config.infoDatabase import infoDatabaseDestiny
from src.config.infoDatabaseTables import infoDatabaseTableSourceAndDestiny, clearDatabaseTableSourceAndDestiny
from src.config.infoFile import infoFileSource, infoFileDestiny
from src.config.infoFileProducts import infoFileProduct
from src.config.infoParameters import infoParameters
from src.controller.selectProfile import selectProfileImportDestiny, selectProfileImportSource
from src.model.entities.entityDataframeHolder import DataFrameHolder
from src.script.tools.screenPrint import spLineBoxError, spLineBoxUp, spLineBoxTitle, spLineBoxText, spLineBoxMiddle, spLineBoxBlank, spHeader, spLineBoxDown, spLineBlank
from src.script.tools.tools import getParameter, verifySuccess


def mainBalancaSP6000():
    identity = getParameter('dfbalancasp6000_parameters_application', 'identity')

    # Registrando o início da execução no log
    logging.info("    => {} - Execução iniciada".format(identity))

    infoDatabase.dbSource = None
    infoDatabase.dbDestiny = None

    # Programa principal
    infoParameter = infoParameters(identity)
    dataframeHolder = DataFrameHolder()                                                     # Cria o dicionário de DFs
    infoTables = infoDatabaseTableSourceAndDestiny(identity)

    strInfoSource = ''
    if infoParameter.tecnologyDatastoreSource == 'Txt':
        infoFSource = infoFileSource(identity)
        strInfoSource = 'Local : Arquivo: ' + infoFSource.get_address() + ' : ' + infoFSource.get_name()
    else:
        spLineBoxError('Parâmetro encontrado com valor incorreto: Esse módulo aceita somente a origem [Excel]')
        input()

    strInfoDestiny = ''
    if infoParameter.tecnologyDatastoreDestiny == 'SQL Server':
        infoDbDestiny = infoDatabaseDestiny(identity)
        strInfoDestiny = 'Server:Database: ' + infoDbDestiny.get_address() + ":" + infoDbDestiny.get_databaseName()
    else:
        spLineBoxError('Parâmetro encontrado com valor incorreto: Esse módulo aceita somente o destino [SQL Server]')
        input()

    spLineBoxUp()
    spLineBoxTitle('ROTINA [0003-BALANCASP6000] - Importação de dados de pesagem de veículos de carga na Balança SP-6000 para geração de Histórico')
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


    print('Importar conteudo para dataframe')
    print('Exportar dados para database')
    print('gravar txt de historico de importação com conteudo do dados.txt')
    print('apagar conteudo do dados.txt')

    '''
    # verifySuccess(createMainDataframe(identity, dataframeHolder, infoParameter, infoTables))
    spLineBoxMiddle()
    verifySuccess(connectFileSource(identity, dataframeHolder, infoParameter, infoTables, infoProduct))
    spLineBoxMiddle()
    # verifySuccess(downloadXlsSeries(identity))
    spLineBoxMiddle()
    verifySuccess(importXlsSeriesToDataframe(identity, dataframeHolder, infoParameter, infoTables, infoProduct))
    spLineBoxMiddle()
    selectProfileExportDestiny(identity, dataframeHolder, infoParameter, infoTables)
    '''


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