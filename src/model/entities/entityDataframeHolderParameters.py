import sys

import pandas as pd

class DataFrameHolderParameters:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super().__new__(cls, *args, **kwargs)
            cls._instance._dfs = {}
        return cls._instance

    def __getitem__(self, nome):
        return self._dfs.get(nome, None)

    def create_df(self, nome):
        data = {'A': [1, 2, 3], 'B': [4, 5, 6]}
        self._dfs[nome] = pd.DataFrame(data)

    def get_df(self, nome):
        return self._dfs.get(nome, None)

    def set_df(self, nome, df):
        self._dfs[nome] = df

    def add_df(self, nome, df):
        if nome not in self._dfs:
            self._dfs[nome] = df
        else:
            print(f" -> Já existe um DataFrame com o nome '{nome}'. Use 'set_df' para substituir ou outro nome para adicionar.")

    def list_dfs(self):
        return list(self._dfs.keys())

    def concat_dfs(self, start_index=0):
        dfs_to_concat = [self._dfs[nome] for nome in list(self._dfs.keys())[start_index:]]
        return pd.concat(dfs_to_concat, ignore_index=True)

    def add_content_to_df(self, nome, content):
        """
        Adds content to an existing DataFrame.

        Args:
            nome (str): The name of the DataFrame.
            content (dict): Dictionary containing data to add to the DataFrame.
        """
        if nome in self._dfs:
            self._dfs[nome] = self._dfs[nome].append(pd.DataFrame(content), ignore_index=True)
            return True
        else:
            print(f" -> DataFrame '{nome}' does not exist.")
            return False

    def get_value_and_data_type_columns(self, dataframeName, parameterName):
        df = self.get_df(dataframeName)
        value = ''
        data_type = ''
        if df is not None:
            if parameterName in df.index:
                value = df.loc[parameterName, 'Value']
                data_type = df.loc[parameterName, 'DataType']
                return value, data_type
            else:
                print(f" -> A tag {parameterName} não foi encontrada no bloco {dataframeName}.")
                input()
        else:
            print(f" -> DataFrame '{dataframeName}' não existe.")

        return value, data_type
