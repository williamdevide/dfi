from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters
from src.model.entities.entityDatabaseTableSourceAndDestiny import TableSourceAndDestiny, dictionary_tables, add_table, remove_table
from src.script.tools.tools import getParameter


def infoDatabaseTableSourceAndDestiny(identity):

    dfs = DataFrameHolderParameters()
    nameDf = 'df' + identity + '_table_source_and_destiny'
    dfTables = dfs.get_df(nameDf)

    for index, row in dfTables.iterrows():
        # Adicionar o produto ao dicionário
        add_table(index, addInformationTable(identity, index))

    return dictionary_tables


def removeDatabaseTableSourceAndDestiny(table):

    # Adicionar o produto ao dicionário
    remove_table(table)

    return dictionary_tables

def addInformationTable(identity, program):
    nameDf = 'df' + identity + '_table_source_and_destiny'
    tables = getParameter(nameDf, program)

    programName = tables[0]  # NOME DA ROTINA
    source = tables[1]  # NOME DA TABELA DE ORIGEM OU ARQUIVO SQL
    destiny = tables[2]  # NOME DA TABELA DE DESTINO
    destinyTemp = tables[3]  # NOME DA TABELA TEMPORÁRIA DE DESTINO
    destinyMerge = tables[4]  # NOME DA ROTINA SQL PARA MERGE DE DESTINO ENTRE TEMPORÁRIA E FINAL


    return TableSourceAndDestiny(programName, source, destiny, destinyTemp, destinyMerge)
