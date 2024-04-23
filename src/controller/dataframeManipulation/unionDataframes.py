from src.script.tools.screenPrint import spLineBoxTaskErrors


def unionDataframes(identity, dataframeHolder, infoParameter, tables, products):
    try:
        dfUnion = dataframeHolder.concat_dfs(start_index=3)  # Concatena os dataframes a partir do índice 3

        # Dataframe principal recebe os dados do dataframe local
        dataframeHolder.add_df('dfUnion', dfUnion)

        return True
    except Exception as e:
        spLineBoxTaskErrors('Erro na união dos dataframes:', e)
        return False
