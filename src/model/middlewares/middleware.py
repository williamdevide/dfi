import urllib
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine, text


class DatabaseManager:
    def __init__(self, identity, database_info):
        self.identity = identity
        self.database_info = database_info
        self.connection = None

    def verify_table_exists(self, table_name):
        """Verifica se uma tabela existe no banco de dados."""
        if self.database_info.get_databaseType() == "SQLServer":
            query = f"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{table_name}'"
        elif self.database_info.get_databaseType() == "PostgreSQL":
            query = f"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = '{table_name}'"
        else:
            # Adicione suporte para outros tipos de banco de dados conforme necessário
            return False

        result = self.connection.execute(text(query)).scalar()

        # Se o resultado for maior que zero, a tabela existe
        if result > 0:
            return True
        else:
            return False

    def is_connection_established(self):
        """Verifica se a conexão com o banco de dados foi estabelecida."""
        return self.connection is not None

    def _connect_to_sql_server(self):
        """Connects to the SQL Server database."""
        connection_string = self.database_info.get_stringConnection()
        quoted = urllib.parse.quote_plus(connection_string)
        return create_engine('mssql+pyodbc:///?odbc_connect={}'.format(quoted)).connect()

    def _connect_to_postgresql(self):
        host = self.database_info.get_address()
        database = self.database_info.get_databaseName()
        user = self.database_info.get_username()
        password = self.database_info.get_password()
        port = self.database_info.get_port()
        encoded_password = quote_plus(password)
        connection_string = f'postgresql+psycopg2://{user}:{encoded_password}@{host}:{port}/{database}'
        return create_engine(connection_string).connect()

    def connect_to_database(self):
        """Connects to the database."""
        if self.database_info.get_databaseType() == "SQLServer":
            self.connection = self._connect_to_sql_server()
        elif self.database_info.get_databaseType() == "PostgreSQL":
            self.connection = self._connect_to_postgresql()
        # Add support for other databases as needed

    def close_connection(self):
        """Fecha a conexão com o banco de dados."""
        if self.connection is not None:
            self.connection.close()
            self.connection = None

    def read_table(self, table_name):
        """Reads a table from the database."""
        import sqlalchemy as sa

        # Verifica se a tabela existe no banco de dados
        if not sa.inspect(self.connection).has_table(table_name, schema='dbo'):
            # Se a tabela não existir, cria-a com a estrutura do DataFrame
            return pd.DataFrame()
        else:
            query = f"SELECT * FROM {table_name}"
            return pd.read_sql_query(query, self.connection)

    def write_dataframe_to_table(self, dataframe, table_name):
        """Writes a DataFrame to a table in the database."""
        dataframe.to_sql(table_name, schema='dbo', con=self.connection, chunksize=10, method='multi', index=False, if_exists='replace')

    def get_table_structure(self, table_name):
        # Consulta SQL para obter a estrutura da tabela do banco de dados
        query = f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}'"
        table_structure = pd.read_sql_query(query, self.connection)
        return table_structure

    def compare_table_structure_with_dataframe(self, table_structure, dataframe):
        # Comparar a estrutura da tabela com a estrutura do DataFrame
        if len(table_structure) != len(dataframe.columns):
            return False
        for col_name, col_type in table_structure.values:
            if col_name not in dataframe.columns or str(dataframe[col_name].dtype) != col_type:
                return False
        return True

    def alter_table_to_match_dataframe(self, table_name, dataframe):
        # Alterar a tabela para corresponder à estrutura do DataFrame
        for col_name, col_type in dataframe.dtypes.iteritems():
            # Consulta SQL para adicionar a coluna à tabela se não existir
            query = f"IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' AND COLUMN_NAME = '{col_name}') " \
                    f"ALTER TABLE {table_name} ADD {col_name} {col_type}"
            self.connection.execute(query)

    def verify_dataframe_and_table(self, dataframe, table_name):
        """Writes a DataFrame to a table in the database."""
        # Obter a estrutura da tabela do banco de dados
        table_structure = self.get_table_structure(table_name)

        # Comparar a estrutura da tabela com a estrutura do DataFrame
        if not self.compare_table_structure_with_dataframe(table_structure, dataframe):
            # Se a estrutura da tabela for diferente, alterar a tabela para corresponder à estrutura do DataFrame
            self.alter_table_to_match_dataframe(table_name, dataframe)

    def verify_table_and_create(self, dataframe, table_name):
        import sqlalchemy as sa

        # Verifica se a tabela existe no banco de dados
        if not sa.inspect(self.connection).has_table(table_name, schema='dbo'):
            # Se a tabela não existir, cria-a com a estrutura do DataFrame
            dataframe.iloc[:0].to_sql(table_name, schema='dbo', con=self.connection, chunksize=1, method='multi', index=False, if_exists='replace')

    def execute_custom_query(self, query):
        """Executes a custom query in the database."""
        return pd.read_sql_query(query, self.connection)

    def execute_sql(self, sql):
        """Executes a SQL command in the database."""
        try:
            # Check if a transaction is active
            if not self.connection.in_transaction():
                with self.connection.begin() as trans:
                    self.connection.execute(text(sql))
                    trans.commit()
            else:
                # If a transaction is active, execute the statement without starting a new transaction
                self.connection.execute(text(sql))
        finally:
            # self.connection.close()
            x = 1

    def delete_table(self, table_name):
        """Deletes a table from the database."""
        try:
            # Check if a transaction is active
            if not self.connection.in_transaction():
                with self.connection.begin() as trans:
                    delete_statement = text(f"DROP TABLE IF EXISTS {table_name}")
                    self.connection.execute(delete_statement)
                    trans.commit()
            else:
                # If a transaction is active, execute the statement without starting a new transaction
                delete_statement = text(f"DROP TABLE IF EXISTS {table_name}")
                self.connection.execute(delete_statement)
        finally:
            # self.connection.close()
            x = 1

    def insert_into_table(self, data, table_name):
        """Inserts data into a table in the database."""
        cursor = self.connection.cursor()
        placeholders = ", ".join(["?"] * len(data.columns))
        insert_statement = f"INSERT INTO {table_name} VALUES ({placeholders})"
        cursor.executemany(insert_statement, data.values.tolist())
        cursor.commit()
        cursor.close()

    def update_table(self, data, table_name, condition):
        """Updates data in a table in the database."""
        update_statement = f"UPDATE {table_name} SET "
        update_statement += ", ".join([f"{column} = ?" for column in data.columns])
        update_statement += f" WHERE {condition}"
        cursor = self.connection.cursor()
        cursor.execute(update_statement, data.values.tolist())
        cursor.commit()
        cursor.close()

    def delete_from_table(self, table_name, condition):
        """Deletes data from a table in the database."""
        delete_statement = f"DELETE FROM {table_name} WHERE {condition}"
        cursor = self.connection.cursor()
        cursor.execute(delete_statement)
        cursor.commit()
        cursor.close()
