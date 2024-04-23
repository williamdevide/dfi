from src.model.core.coreDatabaseInfo import DatabaseInfo


class DatabaseDestinyInfo(DatabaseInfo):
    # Método sobrescrito
    def databaseType(self):
        return f"{self._DatabaseInfo__databaseType}"

    @staticmethod
    def create_destiny(databaseType, address, databaseName, username, password, port, stringConnection):
        return DatabaseDestinyInfo(databaseType, address, databaseName, username, password, port, stringConnection)