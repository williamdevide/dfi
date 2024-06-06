from src.model.entities.entityDataOperations import TableSourceAndDestiny, dictionary_tables, add_table, remove_table
from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters
from src.script.tools.tools import getParameter


def infoDataOperation(identity):
    dfs = DataFrameHolderParameters()
    nameDf = 'df' + identity + '_data_operations'
    dfTables = dfs.get_df(nameDf)

    for index, row in dfTables.iterrows():
        # Adicionar o produto ao dicionário
        add_table(index, addInformationDataOperation(identity, index))

    return dictionary_tables


def removeDataOperation(table):
    # Adicionar o produto ao dicionário
    remove_table(table)

    return dictionary_tables


def addInformationDataOperation(identity, program):
    nameDf = 'df' + identity + '_data_operations'
    tables = getParameter(nameDf, program)

    programName = tables[0]  # NOME DA ROTINA
    source = tables[1]  # NOME DA TABELA DE ORIGEM OU ARQUIVO SQL
    destiny = tables[2]  # NOME DA TABELA DE DESTINO
    destinyTemp = tables[3]  # NOME DA TABELA TEMPORÁRIA DE DESTINO
    destinyMerge = tables[4]  # NOME DA ROTINA SQL PARA MERGE DE DESTINO ENTRE TEMPORÁRIA E FINAL
    daysFuture = int(tables[5]) # NÚMERO DE DIAS A FRENTE DE HOJE PARA DATA FINAL (PADRÃO 0: RETORNA CONSULTAS ATÉ HOJE)

    return TableSourceAndDestiny(programName, source, destiny, destinyTemp, destinyMerge, daysFuture)


def clearInformationDataOperation(infoTables):
    indexTable = []
    for index, (program, table) in enumerate(infoTables.items(), start=1):
        indexTable.append(program)

    for indexTable in indexTable:
        remove_table(indexTable)
