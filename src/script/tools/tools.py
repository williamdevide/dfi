from datetime import datetime
from typing import Literal

import pandas as pd

from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters
from src.script.tools.screenPrint import spLineBoxTaskStatus, spLineBoxTaskErrors


def getCurrentDate():
    # Obter a data atual
    current_date = datetime.today().date()
    return current_date


def findByTag(fieldName, info):
    for field, value in info:
        if field == fieldName:
            return value
    return None  # Retorna None se o campo não for encontrado


# Function to return the header of a column in a DataFrame
def getColumnIndex(dataframe, column_name):
    try:
        return dataframe.columns.get_loc(column_name)
    except KeyError:
        print(f"A coluna '{column_name}' não existe no DataFrame.")
        return None


# Function to return the header of a column in a DataFrame
def getColumnHeader(df, column_number):
    if column_number < len(df.columns):
        return df.columns[column_number]
    else:
        return None


# Converte o campo 'Data' de um dataframe para xxx e ordena o dataframe por esse campo
def convertAndOrderByData(identity, df, fieldData, formatData):
    # Ordenar DataFrame pela coluna 'Data'
    df[fieldData] = pd.to_datetime(df[fieldData], format=formatData)  # Converter 'Data' para formato de data
    df = df.sort_values(by=fieldData).reset_index(drop=True)  # Ordenar por 'Data' e redefinir índices
    return df


# Função para unir os DataFrames
def mergeDataframesByData(identity, df1, df2):
    dfTemp = None
    # dfTemp = pd.merge(df1, df2, on=['comhis_date', 'comhis_day_week'], how="outer")
    dfTemp = pd.merge(df1, df2, on=[df1.columns[0], df1.columns[1]], how="outer")

    # trecho para outros valores de origin futuros

    return dfTemp


# Function para obter o dia da semana em formato de string com três caracteres
def getWeekdayName(date):
    weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM']
    return weekdays[date.weekday()]


# function para verificação de existência/acesso à arquivo
def verifyFile(file, address):
    # Verifica se o arquivo existe e é acessível. Retorna True se o arquivo existe e é acessível, False caso contrário.
    # Retornos: 1. Existe e pode ser acessado | 2. Existe e está em uso | 3. Não existe
    absolutePath = address + file
    try:
        with open(absolutePath) as f:
            pass
        return 1  # Acesso liberado
    except FileNotFoundError:
        strMsg = f'O arquivo {file} não foi encontrado no caminho {address}.'
        spLineBoxTaskErrors(strMsg)
        return 3  # Arquivo não existe
    except IOError:
        strMsg = f'O arquivo {file} não pôde ser acessado no caminho {address}. Verifique se você tem permissão para acesso.'
        spLineBoxTaskErrors(strMsg)
        return 2  # Acesso bloqueado


def verifySuccess(success):
    if not success:
        # print(' -> Erro')
        spLineBoxTaskStatus('[ERRO]')
        input()
    # print(' -> Sucesso')
    spLineBoxTaskStatus('[SUCESSO]')


def getParameter(dataframeName, parameterName, typeReturn: Literal['Value', 'DataType', 'Both'] = 'Value'):
    dfhp = DataFrameHolderParameters()
    value, dataType = dfhp.get_value_and_data_type_columns(dataframeName, parameterName)
    if typeReturn.lower() == 'value':
        return value
    if typeReturn.lower() == 'datatype':
        return dataType
    if typeReturn.lower() == 'both':
        return value, dataType


def verifyExtensionSQL(string):
    return string[-4:] == '.sql'
