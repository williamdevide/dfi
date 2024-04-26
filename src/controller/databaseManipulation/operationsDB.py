import os
from datetime import datetime

import pandas as pd

from src.controller.databaseController.controllerDB import DataController
from src.script.tools.screenPrint import spLineBoxTaskErrors
from src.script.tools.tools import verifyExtensionSQL, verifyFile, getParameter


def readTableSQL(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect):
    # Instanciando o controlador de dados
    data_controller = DataController(identity, infoDb)

    # Abre a conexão com o banco de dados
    data_controller.open_connection()

    # Verifica se é possível a conexão com o banco de dados
    if not data_controller.verify_connection():
        strMsg = f'Erro ao conectar ao database de {typeConnect}'
        spLineBoxTaskErrors(strMsg)
        input()

    dfRead = None

    file = ''
    if typeConnect == 'Origem':
        file = table.get_source()
    if typeConnect == 'Destino':
        file = table.get_destiny()

    # Verifica se será usado tabela ou consulta sql
    if verifyExtensionSQL(file):
        # Verifica qual será o arquivo .sql, se ele existe e retorna o conteudo do arquivo já tratado as váriaveis
        file_sql = file
        sqlStatement = openSqlStatement(identity, dataframeHolder, infoParameter, infoDb, typeConnect, table, file_sql)

        data = data_controller.execute_query(sqlStatement)
        dfRead = pd.DataFrame(data)
    else:
        # Lendo dados de uma tabela
        table_name = file
        data = data_controller.read_data_from_table(table_name)
        dfRead = pd.DataFrame(data)

    # Fecha a conexão com o banco de dados
    data_controller.close_connection()

    df_res = pd.DataFrame(dfRead)
    return True, df_res


def writeTableSQL(identity, dataframeHolder, infoParameter, infoDb, table, typeConnect):
    # Instanciando o controlador de dados
    data_controller = DataController(identity, infoDb)

    # Abre a conexão com o banco de dados
    data_controller.open_connection()

    # Verifica se é possível a conexão com o banco de dados
    if not data_controller.verify_connection():
        strMsg = f'Erro ao conectar ao database de {typeConnect}'
        spLineBoxTaskErrors(strMsg)
        input()

    dataframe = dataframeHolder.get_df('df' + table.get_programName() + '_Destiny')
    if dataframe.empty:
        dataframe = dataframeHolder.get_df('df' + table.get_programName())

    # Gravando dataframe na tabela de destino
    if table.get_destinyTemp() != '':
        destinyTemp = table.get_destinyTemp()
        data_controller.write_data_to_table(dataframe, destinyTemp)

        # Verifica qual será o arquivo .sql de merge
        file_sql = table.get_destinyMerge()
        sqlStatement = openSqlStatement(identity, dataframeHolder, infoParameter, infoDb, typeConnect, table, file_sql)
        data_controller.execute_sql(sqlStatement)
        data_controller.delete_table(destinyTemp)
    else:
        destiny = table.get_destiny()
        data_controller.write_data_to_table(dataframe, destiny)

    # Fecha a conexão com o banco de dados
    data_controller.close_connection()

    return True, dataframe


def openSqlStatement(identity, dataframeHolder, infoParameter, infoDb, typeConnect, table, file_sql):
    sqlStatement = ''
    installationPath = getParameter('dfglobal_parameters_application', 'installationPath')
    root_dir = os.path.join(installationPath, 'src\\database\\sql')
    sql_file_path = os.path.join(root_dir, file_sql)

    # Verifica se o arquivo existe e é acessível
    returnVerifyFile = verifyFile(file_sql, root_dir + '\\')
    if returnVerifyFile == 2 or returnVerifyFile == 3:
        print(" -> Erro")
        input()

    if os.path.exists(sql_file_path):
        with open(sql_file_path, 'r', encoding='utf-8') as file:
            sqlStatement = file.read()

            # Substitui as variáveis pelos valores fornecidos
            sqlStatement = sqlStatement.replace('{initialDate}', infoParameter.dateFieldValueDefault)
            sqlStatement = sqlStatement.replace('{finalDate}', datetime.now().strftime('%Y-%m-%d'))

            if table.get_destinyTemp():
                sqlStatement = sqlStatement.replace('{var_table_name}', table.get_destiny())
                sqlStatement = sqlStatement.replace('{var_temp_table_name}', table.get_destinyTemp())

    return sqlStatement
