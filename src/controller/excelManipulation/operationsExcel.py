from datetime import datetime

import pandas as pd
import win32com.client as win32

from src.config.infoParametersApplication import infoParametersApplication
from src.script.tools.tools import verifyFile


def readFileExcel(identity, dataframeHolder, infoParameters, infoOperations, item, typeConnect):
    file = item.get_filename()
    address = item.get_addressDestiny()
    sheet = item.get_sheet()
    header = item.get_header()
    columns = item.get_columns()
    productItem = item.get_item()
    condictionColumn = item.get_conditionColumns()
    condictionValue = item.get_conditionValue()
    conversionFactor = item.get_conversionFactor()
    unitSource = item.get_unitSource()
    unitDestiny = item.get_unitDestiny()
    SAPProduct = item.get_SAPProduct()

    # Monta o caminho completo do arquivo
    absolutePath = address + file

    if typeConnect == 'Origem':
        info = infoParametersApplication(identity)

        # criando df com estrutura do infoParameters
        dfRead = pd.DataFrame(columns=info.structureFieldsDataframeSource)

        # Filtrar o DataFrame com base na condição, se fornecida
        if condictionColumn and condictionValue:
            columns.append(condictionColumn)

        # Lê a planilha Excel e a armazena em um DataFrame
        df = pd.ExcelFile(absolutePath).parse(sheet_name=sheet, header=header - 1, usecols=columns)
        celTop = pd.read_excel(absolutePath, sheet_name=sheet, header=None, usecols="A", nrows=3)

        if columns[0] == 'Ano' and columns[1] == 'Mês':
            # Mapeando os nomes dos meses para números de 1 a 12
            month_map = {'JAN': 1, 'FEV': 2, 'MAR': 3, 'ABR': 4, 'MAI': 5, 'JUN': 6,
                         'JUL': 7, 'AGO': 8, 'SET': 9, 'OUT': 10, 'NOV': 11, 'DEZ': 12}

            # Criando a coluna
            df[info.dateField] = pd.to_datetime(df['Ano'].astype(str) + df['Mês'].map(month_map).astype(str).str.zfill(2) + '01',
                                                format='%Y%m%d').dt.strftime('%d/%m/%Y')
            df.insert(2, info.dateField, df.pop(info.dateField))

            # Elimina as colunas Ano e Mês
            df = df.drop(columns=['Ano', 'Mês'])

        # Filtrar o DataFrame com base na condição, se fornecida
        if condictionColumn and condictionValue:
            df = df.query(f"{condictionColumn} == '{condictionValue}'")
            df = df.drop(columns=[condictionColumn])

        # Montando df com a mesma estrutura do infoParameters
        df = df.reset_index(drop=True)
        dfRead[info.structureFieldsDataframeSource[0]] = pd.to_datetime(df[df.columns[0]], dayfirst=True)
        dfRead[info.structureFieldsDataframeSource[1]] = ''
        dfRead[info.structureFieldsDataframeSource[2]] = productItem
        dfRead[info.structureFieldsDataframeSource[3]] = SAPProduct
        dfRead[info.structureFieldsDataframeSource[4]] = df[df.columns[1]]
        dfRead[info.structureFieldsDataframeSource[5]] = celTop[0][0]
        dfRead[info.structureFieldsDataframeSource[6]] = conversionFactor
        dfRead[info.structureFieldsDataframeSource[7]] = unitSource
        dfRead[info.structureFieldsDataframeSource[8]] = unitDestiny
        dfRead[info.structureFieldsDataframeSource[9]] = df[df.columns[1]] * conversionFactor

        # Filtrar o DataFrame com base na data de importação
        totalRecords = dataframeHolder.count_regs_df('dfChargeDestiny')

        if totalRecords == 0:
            data = datetime.strptime(info.dateFieldValueDefault, '%d/%m/%Y')
        else:
            data = datetime.strptime(info.dateFieldValue, '%d/%m/%Y')

        dfRead = dfRead.query(f"{info.dateField} > @data")
        df.loc[:, info.structureFieldsDataframeSource[0]] = pd.to_datetime(df[df.columns[0]], dayfirst=True).dt.strftime('%d/%m/%Y')


    else:  # Destino
        returnVerifyFile = verifyFile(file, address)
        if returnVerifyFile == 1:
            dfRead = pd.ExcelFile(absolutePath).parse(sheet_name=sheet, header=header - 1)
        else:
            dfRead = pd.DataFrame()

    df_res = pd.DataFrame(dfRead)
    return True, df_res


# function para gravação do dataframe no xlsx de destino
def writeFileExcel(identity, file, address, sheet, header, columns, dataframe):
    destinyDf = dataframe

    # Monta o caminho completo do arquivo
    absolutePath = address + file

    # Verifica se o arquivo existe e é acessível
    returnVerifyFile = verifyFile(file, address)
    if returnVerifyFile == 2:
        print(" -> Erro")
        input()

    # Grava o DataFrame em um novo arquivo Excel
    destinyDf.to_excel(absolutePath, sheet_name=sheet, index=False)

    return True


# Function que abre o xls e efetua um save no mesmo para corrigir incompatibilidade de versão
def openAndSaveExcelFile(identity, filePath, newFilePath):
    # Open Excel
    excel = win32.Dispatch('Excel.Application')
    excel.Visible = False  # Don't display Excel during the process

    # Open the Excel file
    workbook = excel.Workbooks.Open(filePath)

    # Save the Excel file with a new name or location
    excel.DisplayAlerts = False
    workbook.SaveAs(newFilePath, FileFormat=56)
    excel.DisplayAlerts = True

    # Close the file and Excel
    workbook.Close()
    excel.Quit()
