import logging

def setup_logging():
    # Configurar o logger para gravar no arquivo geral.log
    logging.basicConfig(filename='geral.log', level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    # Iniciar logging
    logging.info('Programa iniciado')

    # Seu código aqui...

    # Criar um logger separado para gravar "boa tarde" no arquivo teste.log
    boa_tarde_logger = logging.getLogger('boa_tarde')
    boa_tarde_logger.setLevel(logging.INFO)
    boa_tarde_handler = logging.FileHandler('teste.log')
    boa_tarde_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    boa_tarde_logger.addHandler(boa_tarde_handler)

    # Registrar "boa tarde" usando o logger separado
    boa_tarde_logger.info('Boa tarde')

    # Continuar com seu código...

    # Finalizar logging
    logging.info('Programa finalizado')

if __name__ == "__main__":
    setup_logging()
    main()
