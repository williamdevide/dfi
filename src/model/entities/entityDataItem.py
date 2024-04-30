class DataItem:
    def __init__(self, importar: str, importMethod: str, item: str, filename: str, addressSource: str, addressDestiny: str, sheet: str, header: int,
                 columns: list[str], conditionColumns: str, conditionValue: str, conversionFactor: float, unitSource: str, unitDestiny: str, SAPProduct: str):
        self.__importar = importar
        self.__importMethod = importMethod
        self.__item = item
        self.__filename = filename
        self.__addressSource = addressSource
        self.__addressDestiny = addressDestiny
        self.__sheet = sheet
        self.__header = header
        self.__columns = columns
        self.__conditionColumns = conditionColumns
        self.__conditionValue = conditionValue
        self.__conversionFactor = conversionFactor
        self.__unitSource = unitSource
        self.__unitDestiny = unitDestiny
        self.__SAPProduct = SAPProduct

    # Getters
    def get_importar(self) -> str:
        return self.__importar

    def get_importMethod(self) -> str:
        return self.__importMethod

    def get_item(self) -> str:
        return self.__item

    def get_filename(self) -> str:
        return self.__filename

    def get_addressSource(self) -> str:
        return self.__addressSource

    def get_addressDestiny(self) -> str:
        return self.__addressDestiny

    def get_sheet(self) -> str:
        return self.__sheet

    def get_header(self) -> int:
        return self.__header

    def get_columns(self) -> list[str]:
        return self.__columns

    def get_conditionColumns(self) -> str:
        return self.__conditionColumns

    def get_conditionValue(self) -> str:
        return self.__conditionValue

    def get_conversionFactor(self) -> float:
        return self.__conversionFactor

    def get_unitSource(self) -> str:
        return self.__unitSource

    def get_unitDestiny(self) -> str:
        return self.__unitDestiny

    def get_SAPProduct(self) -> str:
        return self.__SAPProduct

    # Setters
    def set_importar(self, importar: str):
        self.__importar = importar

    def set_importMethod(self, importMethod: str):
        self.__importMethod = importMethod

    def set_item(self, item: str):
        self.__item = item

    def set_filename(self, filename: str):
        self.__filename = filename

    def set_addressSource(self, addressSource: str):
        self.__addressSource = addressSource

    def set_addressDestiny(self, addressDestiny: str):
        self.__addressDestiny = addressDestiny

    def set_sheet(self, sheet: str):
        self.__sheet = sheet

    def set_header(self, header: int):
        self.__header = header

    def set_columns(self, columns: str):
        self.__columns = columns

    def set_conditionColumns(self, conditionColumns: str):
        self.__conditionColumns = conditionColumns

    def set_conditionValue(self, conditionValue: str):
        self.__conditionValue = conditionValue

    def set_conversionFactor(self, conversionFactor: float):
        self.__conversionFactor = conversionFactor

    def set_unitSource(self, unitSource: str):
        self.__unitSource = unitSource

    def set_unitDestiny(self, unitDestiny: str):
        self.__unitDestiny = unitDestiny

    def set_SAPProduct(self, SAPProduct: str):
        self.__SAPProduct = SAPProduct


# Dicionário para armazenar os objetos DataItem
dictionary_data_items = {}


# Função para adicionar um novo DataItem ao dicionário
def add_item_data(item_name, item_data):
    dictionary_data_items[item_name] = item_data


def remove_item_data(item_name):
    """Remove uma tabela do dicionário."""
    if item_name in dictionary_data_items:
        del dictionary_data_items[item_name]
    else:
        print(f"Item '{item_name}' não encontrada no dicionário.")