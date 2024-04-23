from src.model.entities.entityDatabaseDestiny import DatabaseDestinyInfo
from src.model.entities.entityDatabaseSource import DatabaseSourceInfo
from src.script.tools.tools import getParameter

# Variável global para armazenar a instância
dbDestiny = None
dbSource = None


def infoDatabaseDestiny(identity):
    global dbDestiny

    # Verifica se a instância local dbDestiny já existe
    if dbDestiny is None:
        # Preenche as informações do banco de dados
        nameDf = 'df' + identity + '_database_destiny'

        databaseType = getParameter(nameDf, 'databaseType')
        address = getParameter(nameDf, 'address')
        databaseName = getParameter(nameDf, 'databaseName')
        username = getParameter(nameDf, 'username')
        password = getParameter(nameDf, 'password')
        port = getParameter(nameDf, 'port')
        driver = getParameter(nameDf, 'driver')
        stringConnection = f"DRIVER={{{driver}}};SERVER={address};PORT={port};DATABASE={databaseName};UID={username};PWD={password}"

        # Cria a instância de DatabaseDestinyInfo com as informações fornecidas
        dbDestiny = DatabaseDestinyInfo.create_destiny(databaseType, address, databaseName, username, password, port, stringConnection)

    return dbDestiny


def infoDatabaseSource(identity):
    global dbSource

    # Verifica se a instância local dbDestiny já existe
    if dbSource is None:
        # Preenche as informações do banco de dados
        nameDf = 'df' + identity + '_database_source'

        databaseType = getParameter(nameDf, 'databaseType')
        address = getParameter(nameDf, 'address')
        databaseName = getParameter(nameDf, 'databaseName')
        username = getParameter(nameDf, 'username')
        password = getParameter(nameDf, 'password')
        port = getParameter(nameDf, 'port')
        driver = getParameter(nameDf, 'driver')
        # stringConnection = f"DRIVER={{{driver}}};SERVER={address};PORT={port};DATABASE={databaseName};UID={username};PWD={password}"
        stringConnection = f"Driver={{{driver}}}; Server={address}; Port={port}; Database={databaseName}; Uid={username}; Pwd={password}"

        # Cria a instância de DatabaseDestinyInfo com as informações fornecidas
        dbSource = DatabaseSourceInfo.create_source(databaseType, address, databaseName, username, password, port, stringConnection)

    return dbSource
