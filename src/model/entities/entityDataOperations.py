class TableSourceAndDestiny:
    def __init__(self, programName: str, source: str, destiny: str, destinyTemp: str, destinyMerge: str, daysFuture: int):
        self.programName = programName
        self.source = source
        self.destiny = destiny
        self.destinyTemp = destinyTemp
        self.destinyMerge = destinyMerge
        self.daysFuture = daysFuture

    # Getters
    def get_programName(self) -> str:
        return self.programName

    def get_source(self) -> str:
        return self.source

    def get_destiny(self) -> str:
        return self.destiny

    def get_destinyTemp(self) -> str:
        return self.destinyTemp

    def get_destinyMerge(self) -> str:
        return self.destinyMerge

    def get_daysFuture(self) -> int:
        return self.daysFuture

    # Setters
    def set_programName(self, programName: str):
        self.programName = programName

    def set_source(self, source: str):
        self.source = source

    def set_destiny(self, destiny: str):
        self.destiny = destiny

    def set_destinyTemp(self, destinyTemp: str):
        self.destinyTemp = destinyTemp

    def set_destinyMerge(self, destinyMerge: str):
        self.destinyMerge = destinyMerge

    def set_daysFuture(self, daysFuture: int):
        self.daysFuture = daysFuture

# Dicionário para armazenar os objetos DataItem
dictionary_tables = {}


# Função para adicionar uma nova tabela ao dicionário
def add_table(program, table):
    dictionary_tables[program] = table


def remove_table(program):
    """Remove uma tabela do dicionário."""
    if program in dictionary_tables:
        del dictionary_tables[program]
    else:
        print(f"Tabela '{program}' não encontrada no dicionário.")
