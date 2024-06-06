import pandas as pd

from src.script.tools.screenPrint import spLineBoxTaskErrors, spLineBoxTaskClose, spLineBoxTaskRecords, spLineBoxTaskOpen, spLineBoxTaskItemWithRecords
from src.script.tools.tools import verifySuccess


def processingDataframe(identity, dataframeHolder, infoParameters, infoOperations, typeConnect):
    try:
        strMsg = f'Processando informações do(s) dataframe(s).'
        spLineBoxTaskOpen(strMsg)

        # Iterate over the list and call downloadFile function for each item
        for index, (program, operation) in enumerate(infoOperations.items(), start=1):
            totalFiles = len(infoOperations)

            # Exibindo o número do índice e o número total de registros
            programName = operation.get_programName()

            strMsg = 'Processando...[' + str(index).zfill(2) + '/' + str(totalFiles).zfill(2) + ']: Tabela:[' + programName + ']: '

            spLineBoxTaskItemWithRecords(strMsg)

            # trecho de atuação nos dataframes de acordo com as regras necessárias
            dfDestiny = dataframeHolder.get_df('df' + operation.get_programName() + '_Destiny')
            dfSource = dataframeHolder.get_df('df' + operation.get_programName() + '_Source')

            # criar condições de escolha nos parameters do operations
            # por enquanto a condição é se a operação tem o parametro daysFuture > 0. com o tempo pode ser necessário alteração
            if operation.get_daysFuture > 0:
                # Esse trecho cria o df a ser exportado para o BD com os dados capturados no source, realizando o tratamento e mesclando com os dados já existentes no destiny.

                # Convertendo a coluna 'data' para date
                dfDestiny['data'] = pd.to_datetime(dfDestiny['data']).dt.date
                dfSource['data'] = pd.to_datetime(dfSource['data']).dt.date

                # Gerar dffiltered com os últimos 14 dias do dfsource
                last_date_source = dfSource['data'].max()
                start_date_filtered = last_date_source - pd.Timedelta(days=13)
                dffiltered = dfSource[dfSource['data'] >= start_date_filtered].reset_index(drop=True)

                # Determinar as datas comuns em dfdestiny e dffiltered
                common_dates = set(dfDestiny['data']).intersection(set(dffiltered['data']))

                # Eliminar os dados de dfdestiny nas datas comuns
                dfdestiny_filtered = dfDestiny[~dfDestiny['data'].isin(common_dates)]

                # Concatenar dfdestiny_filtered e dffiltered
                dfFinal = pd.concat([dfdestiny_filtered, dffiltered]).sort_values(by='data').reset_index(drop=True)

            else:
                # Esse trecho somente cria o df a ser exportado para o BD com os dados capturados no source, sem qualquer tratamento. sobreescrevendo totalmente os dados já existentes no destiny
                dfFinal = dfSource

            # inserção do dfFinal no dataframeHolder
            if dataframeHolder.get_df('df' + operation.get_programName()) is None:
                # SE NÃO EXISTIR CRIA A PARTIR DO DFTEMP
                dataframeHolder.add_df('df' + operation.get_programName(), dfFinal)
            else:
                # SE EXISTIR PREENCHE ELE COM OS DADOS DO DFTEMP
                dataframeHolder.set_df('df' + operation.get_programName(), dfFinal)

            totalRecords = '[' + str(dfFinal.shape[0]).rjust(6) + ' records]'
            spLineBoxTaskRecords(totalRecords)
            success = True
            verifySuccess(success)

        strMsg = f'Processando informações do(s) dataframe(s).'
        spLineBoxTaskClose(strMsg)
        return True

    except Exception as e:
        spLineBoxTaskErrors('Erro ao processar Dataframe:', str(e))
        return False
