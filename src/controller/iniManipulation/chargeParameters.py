import os
from datetime import datetime

import pandas as pd
import re

from src.script.tools.tools import verifyFile
from src.model.entities.entityDataframeHolderParameters import DataFrameHolderParameters

def _readParameterIni(file_path):
    dataframeHolderParameters = DataFrameHolderParameters()
    block_pattern = re.compile(r'@(\w+)')
    param_pattern = re.compile(r'\$(\w+):\s*(.*?)$')  # Alteração na expressão regular para capturar o valor do parâmetro como não-greedy
    list_pattern = re.compile(r'\[\[(.*?)\]\]')
    list_format_pattern = re.compile(r'\[(.*?)\]$')  # Verifica se o valor está entre colchetes
    quotes_pattern = re.compile(r'^[\'\"](.+)[\'\"]$')  # Verifica se o valor está entre aspas ou apóstrofos

    def parse_list(value_str):
        value_str = value_str.strip()[1:-1]  # Remove os colchetes de abertura e fechamento
        nested_level = 0
        current_list = []
        current_item = ''
        idx = 0
        while idx < len(value_str):
            char = value_str[idx]
            idx += 1
            if char == '[':
                if nested_level == 0:
                    nested_level += 1
                    sub_value_str = value_str[value_str.find('['):value_str.find(']')+1]
                    current_item = parse_list(sub_value_str)
                    idx += (len(sub_value_str) - 1)
                    nested_level -= 1
                    x= 2
                    continue
                nested_level += 1
            elif char == ']':
                nested_level -= 1
                if nested_level == 0:
                    current_list.append(current_item)
                    current_item = ''
                else:
                    current_item += char
            elif char == ',' and nested_level == 0:
                # Verifica se o valor é uma data no formato dd/mm/YYYY
                date_format = '%d/%m/%Y'
                try:
                    if not isinstance(current_item, list):
                        if current_item.isdigit():
                            current_item = int(current_item)
                        else:
                            # Se não for um número, verifica se é 'True' ou 'False'
                            if current_item.lower() == 'true':
                                current_item = True
                            elif current_item.lower() == 'false':
                                current_item = False
                        # current_item = datetime.strptime(current_item, date_format).date()
                        current_item = current_item
                except ValueError:
                    # Se não for uma data, verifica se é um número
                    if current_item.isdigit():
                        current_item = int(current_item)
                    else:
                        # Se não for um número, verifica se é 'True' ou 'False'
                        if current_item.lower() == 'true':
                            current_item = True
                        elif current_item.lower() == 'false':
                            current_item = False

                if isinstance(current_item, str):
                    current_item = current_item.strip()
                current_list.append(current_item)

                current_item = ''
                continue

            current_item += char
        if current_item or value_str.endswith(','):  # Adiciona o último item à lista, se não for vazio, ou se terminar com ','
            if isinstance(current_item, str):
                current_item = current_item.strip()
            current_list.append(current_item)
        return current_list

    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as file:
            current_block = None
            current_data = {}
            for line in file:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue

                block_match = block_pattern.match(line)
                if block_match:
                    if current_block:
                        dataframeHolderParameters.set_df('df' + current_block.lower(), pd.DataFrame(current_data).T)
                        current_data = {}
                    current_block = block_match.group(1)
                    continue
                param_match = param_pattern.match(line)
                if param_match:
                    param_name = param_match.group(1)
                    param_value = param_match.group(2)

                    if not param_value:
                        param_value = ""

                    # Remove aspas ou apóstrofos se presentes
                    quotes_match = quotes_pattern.match(param_value)
                    if quotes_match:
                        param_value = quotes_match.group(1)

                    # Verifica se o valor é uma lista
                    list_match = list_format_pattern.match(param_value)
                    if list_match:
                        # param_value = parse_list(list_match.group(1))
                        param_value = parse_list(param_value)
                    else:
                        # Verifica se o valor é uma data no formato dd/mm/YYYY
                        date_format = '%d/%m/%Y'
                        try:
                            if param_value.isdigit():
                                param_value = int(param_value)
                            else:
                                # Se não for um número, verifica se é 'True' ou 'False'
                                if param_value.lower() == 'true':
                                    param_value = True
                                elif param_value.lower() == 'false':
                                    param_value = False
                            # param_value = datetime.strptime(param_value, date_format).date()
                            param_value = param_value
                        except ValueError:
                            # Se não for uma data, verifica se é um número
                            if param_value.isdigit():
                                param_value = int(param_value)
                            else:
                                # Se não for um número, verifica se é 'True' ou 'False'
                                if param_value.lower() == 'true':
                                    param_value = True
                                elif param_value.lower() == 'false':
                                    param_value = False

                    data_type = type(param_value).__name__
                    current_data[param_name] = {'Value': param_value, 'DataType': data_type}
                else:
                    print(f"Warning: Invalid parameter format in line '{line}'")
            if current_block:
                dataframeHolderParameters.set_df('df' + current_block.lower(), pd.DataFrame(current_data).T)
    else:
        print("Error: File not found.")

    x=1
    # return dataframeHolderParameters


def _validateParameters(dataframeHolderParameters, valid_params_df):
    result_df = pd.DataFrame(columns=['Block', 'Parameter', 'Value', 'DataType', 'Filled', 'Valid'])
    for block, df in dataframeHolderParameters._dfs.items():
        for param, row in df.iterrows():
            filled = not pd.isna(row['Value'])
            valid = param in valid_params_df.index
            result_df = result_df.append({'Block': block, 'Parameter': param, 'Value': row['Value'], 'DataType': row['DataType'], 'Filled': filled, 'Valid': valid}, ignore_index=True)
    return result_df


# Example usage
def chargeParameters():
    # Read parameters from the INI file
    root_dir = os.getcwd()
    ini_file_path = os.path.join(root_dir, 'parameters.ini')

    # Verifica se o arquivo existe e é acessível
    returnVerifyFile = verifyFile('parameters.ini', root_dir + '\\')
    if returnVerifyFile == 2 or returnVerifyFile == 3:
        print(" -> Erro")
        input()

    dataframeHolderParameters = _readParameterIni(ini_file_path)

    '''
    # Define valid parameters
    valid_params_data = {
        'PARAMETRO_A': {'Valid': True},
        'PARAMETRO_B': {'Valid': True},
        'PARAMETRO_C': {'Valid': True},
        'PARAMETRO_D': {'Valid': True},
        'PARAMETRO_E': {'Valid': True}
    }
    valid_params_df = pd.DataFrame(valid_params_data).T

    # Compare with valid parameters
    result_df = compare_with_valid_parameters(dataframeHolderParameters, valid_params_df)
    print(result_df)
    '''

