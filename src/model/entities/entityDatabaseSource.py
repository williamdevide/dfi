from src.model.core.coreDatabaseInfo import DatabaseInfo


class DatabaseSourceInfo(DatabaseInfo):
    # Método sobrescrito
    def databaseType(self):
        return f"{self._DatabaseInfo__databaseType}"  # Adicionando um prefixo "Source:" ao tipo do banco de dados

    @staticmethod
    def create_source(databaseType, address, databaseName, username, password, port, stringConnection):
        return DatabaseSourceInfo(databaseType, address, databaseName, username, password, port, stringConnection)
