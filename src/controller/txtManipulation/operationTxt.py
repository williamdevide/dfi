import os
from datetime import datetime

import pandas as pd

from src.config.infoFileProducts import infoDataItem
from src.script.tools.screenPrint import spLineBoxTaskErrors
from src.script.tools.tools import getParameter, verifyFile, deleteLinesTxt


def readFileTxt(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect):

    # Monta o caminho completo do arquivo
    absolutePath = item.get_addressDestiny() + item.get_filename()

    if typeConnect == 'Origem':

        # criando df com estrutura do infoParameters
        dfRead = pd.DataFrame(columns=infoParameter.structureFieldsDataframeSource)

        # Lê o arquivo e a armazena em um DataFrame
        if os.path.exists(absolutePath) and os.path.getsize(absolutePath) > 0:
            df = pd.read_csv(absolutePath, sep='|', header=None)
        else:
            df = pd.DataFrame(dfRead)

        # Montando df com a mesma estrutura do infoParameters
        dfRead = structureTxtDataframe(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect, dfRead, df)

    else:  # Destino
        # TRECHO PARA LEITURA DE TXT DE DESTINO
        x = 1
        dfRead = pd.DataFrame()

    df_res = pd.DataFrame(dfRead)
    return True, df_res


def writeFileTxt(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect):

    address = ''
    file = ''

    dataframe = dataframeHolder.get_df('df' + item.get_programName())
    if isinstance(dataframe, pd.DataFrame):
        if dataframe.empty:
            dataframe = dataframeHolder.get_df('df' + item.get_programName() + '_Destiny')
    else:
        dataframe = dataframeHolder.get_df('df' + item.get_programName() + '_Destiny')

    if typeConnect == 'Histórico':
        installationPath = getParameter('dfglobal_parameters_application', 'installationPath')
        # Criando a subpasta 'arquivos-historico' se ainda não existir
        if not os.path.exists(os.path.join(installationPath, 'arquivos-historico')):
            os.makedirs(os.path.join(installationPath, 'arquivos-historico'))

        if not os.path.exists(os.path.join(installationPath, 'arquivos-historico', identity)):
            os.makedirs(os.path.join(installationPath, 'arquivos-historico', identity))

        address = os.path.join(installationPath, 'arquivos-historico', identity)
        file = datetime.now().strftime(f'dfi_{identity}_log-%Y-%m-%d.log')

        clearTxt(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect)

    destinyDf = dataframe

    # Monta o caminho completo do arquivo
    # noinspection PyTypeChecker
    absolutePath = os.path.join(address, file)

    # Verifica se o arquivo existe e é acessível
    returnVerifyFile = verifyFile(file, address)
    if returnVerifyFile == 2:
        print(" -> Erro")
        input()

    # Grava o DataFrame em um novo arquivo Excel
    destinyDf.to_csv(absolutePath, sep='|', header=None, index=False)

    return True


def structureTxtDataframe(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect, dfRead, df):
    # AQUI VÃO AS SUBROTINAS DE IMPORTAÇÃO TRANSFORMANDO OS DADOS DA ORIGEM NO FORMATO DO DATAFRAME COM ESTRUTURA IGUAL AO DESTINO
    # ADEQUAÇÕES DE TIPOS, OPERAÇÕES MATEMÁTICAS E QUAIS ALTERAÇÕES OCORREM AQUI

    df = df.reset_index(drop=True)

    if identity == 'commodities':
        x = 1

    elif identity == 'avacorp':
        x = 1

    elif identity == 'balancasp6000':
        dfRead[dfRead.columns[0]] = df[df.columns[0]]
        dfRead[dfRead.columns[1]] = df[df.columns[1]]
        dfRead[dfRead.columns[2]] = df[df.columns[2]]
        dfRead[dfRead.columns[3]] = df[df.columns[3]]
        dfRead[dfRead.columns[4]] = df[df.columns[4]]
        dfRead[dfRead.columns[5]] = df[df.columns[5]]
        dfRead[dfRead.columns[6]] = df[df.columns[6]]
        dfRead[dfRead.columns[7]] = df[df.columns[7]]
        dfRead[dfRead.columns[8]] = df[df.columns[8]]
        dfRead[dfRead.columns[9]] = df[df.columns[9]]
        dfRead[dfRead.columns[10]] = df[df.columns[10]]
        dfRead[dfRead.columns[11]] = df[df.columns[11]]
        dfRead[dfRead.columns[12]] = df[df.columns[12]]
        dfRead[dfRead.columns[13]] = df[df.columns[13]]
        dfRead[dfRead.columns[14]] = df[df.columns[14]]
        dfRead[dfRead.columns[15]] = df[df.columns[15]]
        dfRead[dfRead.columns[16]] = df[df.columns[16]]
        dfRead[dfRead.columns[17]] = df[df.columns[17]]

    else:
        strMsg = f'Não foi possível traduzir a estrutura do dataframe:'
        spLineBoxTaskErrors(strMsg)

    return dfRead


def clearTxt(identity, dataframeHolder, infoParameter, infoTables, item, typeConnect):
    address = ''
    file = ''

    dataframe = dataframeHolder.get_df('df' + item.get_programName())
    if isinstance(dataframe, pd.DataFrame):
        if dataframe.empty:
            dataframe = dataframeHolder.get_df('df' + item.get_programName() + '_Destiny')
    else:
        dataframe = dataframeHolder.get_df('df' + item.get_programName() + '_Destiny')

    if typeConnect == 'Histórico':
        infoProduct = infoDataItem(identity)
        for index, (item_name, item) in enumerate(infoProduct.items(), start=1):
            address = item.get_addressDestiny()
            file = item.get_filename()

    destinyDf = dataframe

    # Monta o caminho completo do arquivo
    # noinspection PyTypeChecker
    absolutePath = os.path.join(address, file)

    # Verifica se o arquivo existe e é acessível
    returnVerifyFile = verifyFile(file, address)
    if returnVerifyFile == 2:
        print(" -> Erro")
        input()

    # deleta as linhas já existentes
    deleteLinesTxt(destinyDf, absolutePath)