class TableSourceAndDestiny:
    def __init__(self, programName: str, source: str, destiny: str, destinyTemp: str, destinyMerge: str):
        self.__programName = programName
        self.__source = source
        self.__destiny = destiny
        self.__destinyTemp = destinyTemp
        self.__destinyMerge = destinyMerge

    # Getters
    def get_programName(self) -> str:
        return self.__programName

    def get_source(self) -> str:
        return self.__source

    def get_destiny(self) -> str:
        return self.__destiny

    def get_destinyTemp(self) -> str:
        return self.__destinyTemp

    def get_destinyMerge(self) -> str:
        return self.__destinyMerge

    # Setters
    def set_programName(self, programName: str):
        self.__programName = programName

    def set_source(self, source: str):
        self.__source = source

    def set_destiny(self, destiny: str):
        self.__destiny = destiny

    def set_destinyTemp(self, destinyTemp: str):
        self.__destinyTemp = destinyTemp

    def set_destinyMerge(self, destinyMerge: str):
        self.__destinyMerge = destinyMerge

# Dicionário para armazenar os objetos SourceProduct
dictionary_tables = {}


# Função para adicionar uma nova tabela ao dicionário
def add_table(program, table):
    dictionary_tables[program] = table


def remove_table(self, program):
    """Remove uma tabela do dicionário."""
    if program in dictionary_tables:
        del dictionary_tables[program]
    else:
        print(f"Tabela '{program}' não encontrada no dicionário.")