import os

import requests

'''
print('Teste ini')

root_dir = os.getcwd()
ini_file_path = os.path.join(root_dir, 'parameters.ini')

with open(ini_file_path, 'r', encoding=None) as file:
    for line in file:
        line = line.strip()
        print(line)


print('')
print('Final do arquivo.')
input()
'''

print('Teste download')

try:
    headersBrowser = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'}
    url = 'https://www.cepea.esalq.usp.br/br/indicador/series/acucar.aspx?id=53'
    response = requests.get(url, headers=headersBrowser)
    print(response.status_code)
    if response.status_code == 200:
        # Open the file in binary write mode and save the content
        saveLocation = 'D:\\dfi\\arquivos\\serie-historica\\'
        fileName = 'serie_acucar.xls'
        with open(f'{saveLocation}/{fileName}', 'wb') as file:
            file.write(response.content)
    else:
        print(f' -> O download do arquivo falhou. Código de status: {response.status_code}')

except Exception as e:
    print(f' -> Erro capturado: {str(e)}')

print('')
print('Final do arquivo.')
input()
