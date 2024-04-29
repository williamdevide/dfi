from datetime import datetime, timedelta

from src.model.entities.entityParametersApplication import ParametersApplication
from src.script.tools.tools import getWeekdayName, getParameter


# CONTEM OS PARAMETROS DO MÓDULO DA APLICAÇÃO.
def infoParametersApplication(identity, dateFieldValue=None):
    # parâmetros do arquivo de saída
    nameDf = 'df' + identity + '_parameters_application'

    tecnologyDatastoreSource = getParameter(nameDf, 'tecnologyDatastoreSource')
    tecnologyDatastoreDestiny = getParameter(nameDf, 'tecnologyDatastoreDestiny')
    structureFieldsDataframeSource = getParameter(nameDf, 'structureFieldsDataframeSource')
    dateField = structureFieldsDataframeSource[0] if structureFieldsDataframeSource and isinstance(structureFieldsDataframeSource, list) else ''  # CAMPO DATA
    dateFieldValueDefault = getParameter(nameDf, 'dateFieldValueDefault')  # DATA DEFAULT
    dateFieldValue = (datetime.now().date() - timedelta(days=15)).strftime("%d/%m/%Y")  # DATA INICIAL (HOJE - 15)
    dateFieldFormat = '%d/%m/%Y'  # FORMATO DA DATA INICIAL
    dayWeekField = structureFieldsDataframeSource[1] if structureFieldsDataframeSource and isinstance(structureFieldsDataframeSource, list) else ''  # CAMPO DAY_WEEK
    dayWeekFieldValue = getWeekdayName(datetime.strptime(dateFieldValue, '%d/%m/%Y'))  # DAY_WEEK INICIAL
    priceField = structureFieldsDataframeSource[4] if structureFieldsDataframeSource and isinstance(structureFieldsDataframeSource, list) else ''  # CAMPO PREÇO
    headersBrowser = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'}
    singleSourceTransferency = getParameter(nameDf, 'singleSourceTransferency')
    singleDestinyTransferency = getParameter(nameDf, 'singleDestinyTransferency')

    # Retorna um objeto DatabaseDestinyInfo com as informações fornecidas
    return ParametersApplication(tecnologyDatastoreSource, tecnologyDatastoreDestiny, structureFieldsDataframeSource, dateField, dateFieldValueDefault, dateFieldValue,
                                 dateFieldFormat, dayWeekField, dayWeekFieldValue, priceField, headersBrowser, singleSourceTransferency, singleDestinyTransferency)
