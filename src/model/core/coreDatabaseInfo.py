class DatabaseInfo:
    def __init__(self, databaseType, address, databaseName, username, password, port, stringConnection):
        self.__databaseType = databaseType
        self.__address = address
        self.__databaseName = databaseName
        self.__username = username
        self.__password = password
        self.__port = port
        self.__stringConnection = stringConnection

    # Métodos getter
    def get_databaseType(self):
        return self.__databaseType

    def get_address(self):
        return self.__address

    def get_databaseName(self):
        return self.__databaseName

    def get_username(self):
        return self.__username

    def get_password(self):
        return self.__password

    def get_port(self):
        return self.__port

    def get_stringConnection(self):
        return self.__stringConnection

    # Métodos setter
    def set_databaseType(self, databaseType):
        self.__databaseType = databaseType

    def set_address(self, address):
        self.__address = address

    def set_databaseName(self, databaseName):
        self.__databaseName = databaseName

    def set_username(self, username):
        self.__username = username

    def set_password(self, password):
        self.__password = password

    def set_port(self, port):
        self.__port = port

    def set_stringConnection(self, stringConnection):
        self.__stringConnection = stringConnection

    # Metodos
    @property
    def databaseType(self):
        return self.__databaseType
