class SourceProduct:
    def __init__(self, item: str, name: str, url: str, address: str, sheet: str, header: int,
                 columns: list[str], conditionColumns: str, conditionValue: str, conversionFactor: float, unitSource: str, unitDestiny: str, SAPProduct: str):
        self.__item = item
        self.__name = name
        self.__url = url
        self.__address = address
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
    def get_item(self) -> str:
        return self.__item

    def get_name(self) -> str:
        return self.__name

    def get_url(self) -> str:
        return self.__url

    def get_address(self) -> str:
        return self.__address

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
    def set_item(self, item: str):
        self.__item = item

    def set_name(self, name: str):
        self.__name = name

    def set_url(self, url: str):
        self.__url = url

    def set_address(self, address: str):
        self.__address = address

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


# Dicionário para armazenar os objetos SourceProduct
dictionary_source_products = {}


# Função para adicionar um novo SourceProduct ao dicionário
def add_source_product(product_name, source_product):
    dictionary_source_products[product_name] = source_product

