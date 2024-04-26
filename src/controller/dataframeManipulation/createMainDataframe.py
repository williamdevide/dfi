from datetime import datetime

import pandas as pd

from src.script.tools.screenPrint import spLineBoxTaskUnique, spLineBoxTaskErrors
from src.script.tools.tools import getWeekdayName


# Cria o dataframe principal que irá receber os dados existentes ou será usado para inserção dos dados iniciais
def createMainDataframe(identity, dataframeHolder, infoParameter, tables, infoProduct, typeConnect):
    try:
        spLineBoxTaskUnique('Criando Dataframe principal:')

        if identity == 'commodities':
            nameTable, table = next(iter(tables.items()))
            if dataframeHolder.count_regs_df('df' + table.get_programName() + '_Destiny') == 0:
                infoParameter.dateFieldValue = infoParameter.dateFieldValueDefault
                infoParameter.dayWeekFieldValue = getWeekdayName(datetime.strptime(infoParameter.dateFieldValueDefault, infoParameter.dateFieldFormat))

            # Convert strings into date objects
            dateFieldValue = datetime.strptime(infoParameter.dateFieldValue, infoParameter.dateFieldFormat).date()
            dayWeekFieldValue = infoParameter.dayWeekFieldValue

            # Cria o dataframe principal que será usado durante toda a rotina
            df = pd.DataFrame({
                infoParameter.dateField: pd.to_datetime([dateFieldValue], format=infoParameter.dateFieldFormat),
                infoParameter.dayWeekField: [dayWeekFieldValue]})

        elif identity == 'balancasp6000':
            df = pd.DataFrame(columns=infoParameter.structureFieldsDataframeSource)

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
