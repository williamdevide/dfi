# function para preparação do ambiente
from datetime import datetime
import pandas as pd
from src.config.infoParameters import infoParameters
from src.script.tools.screenPrint import spLineBoxTaskErrors
from src.script.tools.tools import getCurrentDate, getWeekdayName, convertAndOrderByData, mergeDataframesByData


def prepareAmbient(identity, dataframeHolder, infoParameter, tables, products):
    try:
        nameTable, table = next(iter(tables.items()))
        if dataframeHolder.count_regs_df('df' + table.get_programName() + '_Destiny') == 0:   # Se o total de registros do dfChargeDestiny for 0 importatodo o periodo desde a data default
            # Convert strings into date objects
            dateFieldValue = datetime.strptime(infoParameter.dateFieldValueDefault, infoParameter.dateFieldFormat).date()
        else:                   # caso contrario importa somente a partir do periodo definido
            # Convert strings into date objects
            dateFieldValue = datetime.strptime(infoParameter.dateFieldValue, infoParameter.dateFieldFormat).date()

        finalDate = getCurrentDate()

        # Create list of dates with one day increment
        dates = [date.strftime(infoParameter.dateFieldFormat) for date in pd.date_range(dateFieldValue, finalDate)]

        # Create DataFrame
        df = pd.DataFrame({
            infoParameter.dateField: dates,
            infoParameter.dayWeekField: [getWeekdayName(datetime.strptime(date, infoParameter.dateFieldFormat)) for date in dates]
        })

        # Ordenar DataFrame pela coluna 'Data'
        df = convertAndOrderByData(identity, df, infoParameter.dateField, infoParameter.dateFieldFormat)

        # Dataframe principal recebe os dados do dataframe local
        dfMain = dataframeHolder.get_df('dfMain')
        # totalRecordsMain = dfMain.shape[0]
        dfTemp = mergeDataframesByData(identity, dfMain, df)
        dataframeHolder.add_df('dfAmbient', dfTemp)

        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao preparar ambiente:', e)
        return False








