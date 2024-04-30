pip freeze > requeriments.txt


python setup_pyinstaller.py
pyinstaller --onefile d:\development\python\dfi\src\tests\teste.py







@PROGRAMS												guarda os programas disponíveis e se estão setados para execução
@GLOBAL_PARAMETERS_APPLICATION										guarda parametros globais de funcionamento da aplicação

@BALANCASP6000_PARAMETERS_APPLICATION			infoParameters					guarda o bloco de parametros da aplicação
@BALANCASP6000_DATABASE_DESTINY				infoDBSource					guarda o bloco de parametros de conexão com o DB de origem se existir
@BALANCASP6000_DATABASE_SOURCE				infoDBDestiny					guarda o bloco de parametros de conexão com o DB de destino se existir
@BALANCASP6000_DATA_ITEMS				infoItems		item			guarda o bloco de parametros dos items a serem coletados (adaptar para ler os comandos sql daqui tambem)
@BALANCASP6000_DATA_OPERATIONS				infoOperations		operation		guarda o bloco de parametros das operações de destino
							typeConnect					identifica se é 'Origem', 'Destino' ou 'Histórico'
DataframeHolder												dicionario onde são armazenados todos os dataframes de todos os itens
DataframeHolderParameters										dicionario onde são armazenados todos os blocos de parametros do ini antes de serem tratados




$Dolar: [NAO,,Dolar,serie_dolar.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]
$Amendoim: [NAO,,Amendoim,serie_amendoim.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]
$Papelão: [NAO,,Papelão,serie_papelao.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]
$Ipca: [NAO,,Ipca,serie_ipca.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]
$Igpm: [NAO,,Igpm,serie_igpm.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]
$Plástico: [NAO,,Plástico,serie_plastico.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]
$Glp: [NAO,,GLP,serie_glp.xls,,D:\Development\Python\dfi\arquivos\serie-historica\,,,,,,,,,]