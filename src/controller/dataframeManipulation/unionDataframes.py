from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskItemWithOutRecords


def unionDataframes(identity, dataframeHolder, infoParameters, infoOperations, infoItems, typeConnect):
    try:
        strMsg = f'Operação: União dos Dataframes:'
        spLineBoxTaskItemWithOutRecords(strMsg)

        dfUnion = dataframeHolder.concat_dfs(start_index=3)  # Concatena os dataframes a partir do índice 3

        # Dataframe principal recebe os dados do dataframe local
        dataframeHolder.add_df('dfUnion', dfUnion)

        return True
    except Exception as e:
        strMsg = f'União dos dataframes:'
        spLineBoxTaskErrors(strMsg, str(e))
        return False
