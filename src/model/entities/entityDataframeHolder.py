import pandas as pd


class DataFrameHolder:
    def __init__(self):
        self._dfs = {}

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
        dfs_to_concat = []
        for nome in list(self._dfs.keys())[start_index:]:
            df = self._dfs[nome]
            # if not df.empty:
            dfs_to_concat.append(df)
        if dfs_to_concat:
            return pd.concat(dfs_to_concat, ignore_index=True)
        else:
            return None

    def add_content_to_df(self, nome, content):
        """
        Adds content to an existing DataFrame.

        Args:
            nome (str): The name of the DataFrame.
            content (dict): Dictionary containing data to add to the DataFrame.
        """
        if nome in self._dfs:
            self._dfs[nome] = self._dfs[nome].append(pd.DataFrame(content), ignore_index=True)
        else:
            print(f" -> DataFrame '{nome}' does not exist.")

    def count_regs_df(self, nome):
        if nome in self._dfs:
            return len(self._dfs[nome])
        else:
            return 0
