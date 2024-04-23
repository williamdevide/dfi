# Chamada para o preenchimento dos valores nas datas vazias
import pandas as pd
from src.script.tools.tools import getColumnIndex, getWeekdayName


# Function para preencher os dias sem valor com o valor do próximo dia com valor
def fillMissingPrice(identity, df, columnName):
    column = getColumnIndex(df, columnName)
    first_value = df.iloc[:, column].first_valid_index()

    nextValue = None
    for index, row in df[::-1].iterrows():  # Iterate over the DataFrame from end to start
        if pd.isnull(row[columnName]):
            if index >= first_value:
                df.at[index, columnName] = nextValue
            else:
                df.at[index, columnName] = 0
        else:
            nextValue = row[columnName]
    return df


def fillMissingProduct(identity, df, fieldProduct, product):
    df[fieldProduct] = product
    return df


def fillMissingDayOfWeek(identity, df, fieldDate, fieldDayOfWeek):
    df[fieldDayOfWeek] = df[fieldDate].apply(getWeekdayName)
    return df
