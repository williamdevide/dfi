import warnings

import pandas as pd

from src.config.infoParameters import infoParameters
from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskItemWithOutRecords


def updateDataframe(identity, dataframeHolder, infoParameter, tables, products):
    try:
        strMsg = f'Operação: Update dos Dataframes:'
        spLineBoxTaskItemWithOutRecords(strMsg)

        with warnings.catch_warnings():
            warnings.filterwarnings("ignore", category=FutureWarning)

            info = infoParameters(identity)
            nameTable, table = next(iter(tables.items()))

            df1 = dataframeHolder.get_df('dfChargeDestiny')
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
                dataframeHolder.add_df(nameDf, df2)

        return True

    except Exception as e:
        strMsg = f'Update dos dataframes:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False
