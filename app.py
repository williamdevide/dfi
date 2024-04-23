import logging
import os
from datetime import datetime

from src.controller.iniManipulation.chargeParameters import chargeParameters
from src.script.tools.tools import getParameter
from src.main import main

import schedule
import time

# Criando a subpasta 'logs' se ainda não existir
if not os.path.exists('logs'):
    os.makedirs('logs')

# Configurando o logger
log_file = os.path.join('logs', datetime.now().strftime('dfi_log-%Y-%m-%d.log'))
logging.basicConfig(filename=log_file, level=logging.INFO, format='%(asctime)s - %(message)s')

# Registrando o início da execução no log
logging.info("DFI => Execução iniciada")

# Importa os parametros de trabalho
chargeParameters()

# Agende a execução da tarefa a cada x horas
timeMinutesToUpdate = getParameter('dfglobal_parameters_application','timeMinutesToUpdate')

if timeMinutesToUpdate == 0:
    main()
else:
    main()

    schedule.every(timeMinutesToUpdate).minutes.do(main)

    while True:
        # Verifique se há tarefas agendadas para executar
        schedule.run_pending()
        time.sleep(1)

# Registrando o final da execução no log
logging.info("DFI => Execução encerrada")