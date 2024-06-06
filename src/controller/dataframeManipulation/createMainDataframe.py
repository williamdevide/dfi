from datetime import datetime

import pandas as pd

from src.script.tools.screenPrint import spLineBoxTaskUnique, spLineBoxTaskErrors
from src.script.tools.tools import getWeekdayName


# Cria o dataframe principal que irá receber os dados existentes ou será usado para inserção dos dados iniciais
def createMainDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:
        spLineBoxTaskUnique('Criando Dataframe principal:')

        if identity == 'commodities':
            nameTable, table = next(iter(infoOperations.items()))
            if dataframeHolder.count_regs_df('df' + table.get_programName() + '_Destiny') == 0:
                infoParameters.dateFieldValue = infoParameters.dateFieldValueDefault
                infoParameters.dayWeekFieldValue = getWeekdayName(datetime.strptime(infoParameters.dateFieldValueDefault, infoParameters.dateFieldFormat))

            # Convert strings into date objects
            dateFieldValue = datetime.strptime(infoParameters.dateFieldValue, infoParameters.dateFieldFormat).date()
            dayWeekFieldValue = infoParameters.dayWeekFieldValue

            # Cria o dataframe principal que será usado durante toda a rotina
            df = pd.DataFrame({
                infoParameters.dateField: pd.to_datetime([dateFieldValue], format=infoParameters.dateFieldFormat),
                infoParameters.dayWeekField: [dayWeekFieldValue]})

        elif identity == 'balancasp6000':
            df = pd.DataFrame(columns=infoParameters.structureFieldsDataframeSource)

        else:
            df = pd.DataFrame()

        # adiciona no dicionario de dataframes
        dataframeHolder.add_df('dfMain', df)

        # Retorna True
        return True

    except Exception as e:
        strMsg = f'Criar Dataframe Principal:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False
