import warnings

import pandas as pd

from src.config.infoParametersApplication import infoParametersApplication
from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskItemWithOutRecords


def updateDataframe(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:
        strMsg = f'Operação: Update dos Dataframes:'
        spLineBoxTaskItemWithOutRecords(strMsg)

        with warnings.catch_warnings():
            warnings.filterwarnings("ignore", category=FutureWarning)

            info = infoParametersApplication(identity)
            nameTable, table = next(iter(infoOperations.items()))

            df1 = dataframeHolder.get_df('df' + table.get_programName() + '_Destiny')
            df2 = dataframeHolder.get_df('dfUnion')

            if info.tecnologyDatastoreDestiny == 'Excel':
                atualiza_local = True
            if info.tecnologyDatastoreDestiny == 'SQL Server':
                atualiza_local = False

            if atualiza_local:
                primary_keys = [info.structureFieldsDataframeSource[0], info.structureFieldsDataframeSource[1], info.structureFieldsDataframeSource[2]]
                # Ensure primary keys are in both dataframes
                assert all(key in df1.columns and key in df2.columns for key in primary_keys), "Primary key columns not found in both dataframes"

                # Remove primary keys from columns to be updated
                update_columns = df1.columns.difference(primary_keys)

                # Iterate over rows in df2 to find differences
                for index, row in df2.iterrows():
                    # Get corresponding row in df1 based on primary keys
                    mask = pd.Series([True] * len(df1))
                    for key in primary_keys:
                        mask &= df1[key] == row[key]

                    # Update values in df1 with values from df2 for non-primary key columns
                    df1.loc[mask, update_columns] = row[update_columns].values

                # Dataframe principal recebe os dados do dataframe local
                nameDf = table.get_programName()
                dataframeHolder.add_df(nameDf, df1)
            else:
                # Dataframe principal recebe os dados do dataframe local
                nameDf = 'df' + table.get_programName()

                # Loop através das colunas do df2
                for coluna in df1.columns:
                    # Verificar se a coluna existe no df1
                    if coluna in df2.columns:
                        # Converter a coluna correspondente do df1 para o mesmo tipo que a coluna do df2
                        df2[coluna] = df2[coluna].astype(df1[coluna].dtype)

                if identity == 'commodities':
                    dfTemp = df2.set_index(['comhis_date', 'comhis_day_week', 'comhis_commodity']).combine_first(df1.set_index(['comhis_date', 'comhis_day_week', 'comhis_commodity'])).reset_index()
                    dataframeHolder.add_df(nameDf, dfTemp)
                elif identity == 'balancasp6000':
                    dfTemp = df2.set_index(df2.columns[8]).combine_first(df1.set_index(df2.columns[8])).reset_index()
                    dfTemp = dfTemp.sort_values(by=dfTemp.columns[0])
                    cols = dfTemp.columns.tolist()
                    cols = cols[1:8] + [cols[0]] + cols[8:]
                    dfTemp = dfTemp[cols]

                    dataframeHolder.add_df(nameDf, dfTemp)
                else:
                    dfTemp = df2.set_index(df2.columns[0]).combine_first(df1.set_index(df2.columns[0])).reset_index()
                    dataframeHolder.add_df(nameDf, dfTemp)

        return True

    except Exception as e:
        strMsg = f'Update dos dataframes:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False
