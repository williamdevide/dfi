import requests

from src.controller.excelManipulation.operationsExcel import openAndSaveExcelFile
from src.script.tools.screenPrint import spLineBoxTaskStatus


def executeDownloadFile(identity, item, url, fileName, saveLocation, headersBrowser):
    try:
        # Make a GET request to fetch the file content
        response = requests.get(url, headers=headersBrowser)
        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            # Open the file in binary write mode and save the content
            with open(f'{saveLocation}/{fileName}', 'wb') as file:
                file.write(response.content)
            absolutePath = saveLocation + fileName
            openAndSaveExcelFile(identity, absolutePath, absolutePath)
            spLineBoxTaskStatus('[SUCESSO]')
        else:
            print(f' -> O download do arquivo {fileName} falhou. Código de status: {response.status_code}')
    except Exception as e:
        print(f' -> Ocorreu um erro durante o download do arquivo: {str(e)}')
