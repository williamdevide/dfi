import logging
from datetime import datetime

from src.script.main.mainAvacorp import mainAvacorp
from src.script.main.mainBalancaSP6000 import mainBalancaSP6000
from src.script.main.mainCommodities import mainCommodities
from src.script.tools.tools import getParameter


def main():
    # Registrando o início da execução no log
    logging.info("    => Main - Execução iniciada")

    data_hora_atual = datetime.now()
    data_hora_formatada = data_hora_atual.strftime("%Y-%m-%d %H:%M:%S")
    print("Data e hora atual:", data_hora_formatada)

    # Definição de execução dos programas
    mainCommodities() if getParameter('dfprograms', 'commodities') else None
    mainAvacorp() if getParameter('dfprograms', 'avacorp') else None
    mainBalancaSP6000() if getParameter('dfprograms', 'balancasp6000') else None

    # Registrando a conclusão da execução no log
    logging.info("    => Main - Execução concluída")
