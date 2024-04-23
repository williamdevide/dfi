from src.model.middlewares.middleware import DatabaseManager


class DataController:
    def __init__(self, identity, infoDb):
        database_info = infoDb
        self.db_manager = DatabaseManager(identity, database_info)

    def verify_table_exists(self, table_name):
        """Verifica se a tabela existe no banco de dados."""
        return self.db_manager.verify_table_exists(table_name)

    def verify_connection(self):
        """Verifica se a conexão com o banco de dados foi estabelecida."""
        return self.db_manager.is_connection_established()

    def read_data_from_table(self, table_name):
        """Reads data from a table."""
        return self.db_manager.read_table(table_name)

    def write_data_to_table(self, dataframe, table_name):
        """Writes data to a table."""
        self.db_manager.write_dataframe_to_table(dataframe, table_name)

    def execute_query(self, query):
        """Executes a custom query."""
        return self.db_manager.execute_custom_query(query)

    def execute_sql(self, sql):
        """Executes a custom query."""
        return self.db_manager.execute_sql(sql)

    def delete_table(self, table_name):
        """Deletes a table."""
        self.db_manager.delete_table(table_name)

    def insert_into_table(self, data, table_name):
        """Inserts data into a table."""
        self.db_manager.insert_into_table(data, table_name)

    def update_table(self, data, table_name, condition):
        """Updates data in a table."""
        self.db_manager.update_table(data, table_name, condition)

    def delete_from_table(self, table_name, condition):
        """Deletes data from a table."""
        self.db_manager.delete_from_table(table_name, condition)

    def verify_dataframe_and_table(self, dataframe, table_name):
        """Verify data and table."""
        self.db_manager.verify_dataframe_and_table(dataframe, table_name)

    def verify_table_and_create(self, dataframe, table_name):
        """Verify data and table."""
        self.db_manager.verify_table_and_create(dataframe, table_name)

    def open_connection(self):
        """Estabelece a conexão com o banco de dados."""
        return self.db_manager.connect_to_database()

    def close_connection(self):
        """Fecha a conexão com o banco de dados."""
        self.db_manager.close_connection()
