import os
from PyInstaller.__main__ import run

# Função para listar todos os arquivos .ini na mesma pasta do executável
def find_ini_files():
    ini_files = []
    for file in os.listdir('.'):
        if file.endswith('.ini'):
            ini_files.append(file)
    return ini_files

# Função para listar todos os arquivos .sql na subpasta \src\database\sql\
def find_sql_files():
    sql_files = []
    sql_folder = 'src/database/sql/'
    for foldername, _, filenames in os.walk(sql_folder):
        for filename in filenames:
            if filename.endswith('.sql'):
                sql_files.append(os.path.join(foldername, filename))
    return sql_files

# Lista de arquivos .ini na mesma pasta do executável
ini_files = find_ini_files()

# Lista de arquivos .sql na subpasta \src\database\sql\
sql_files = find_sql_files()

# Definindo os arquivos a serem excluídos
excluded_files = ini_files + sql_files

# Atualizar o requirements.txt com as dependências em uso no ambiente virtual
os.system('pip freeze > requirements.txt')

# Configuração do PyInstaller
opts = [
        'app.py',  # Substitua 'your_script.py' pelo nome do seu script principal
        '--name=dfi',  # Nome do executável
        '--onefile',  # Empacotar em um único arquivo
        '--console',  # Abrir console na execução
        # '--noconsole',  # Não abrir console na execução
        '--hidden-import=pyodbc', # força inserção do pyodbc, pois ele é chamado de forma indireta
        '--distpath', 'dist',  # Define o diretório de saída para a raiz do projeto
]  # Substitua 'your_script.py' pelo nome do seu script principal e 'myapp' pelo nome desejado para o executável

for file in excluded_files:
    opts.extend(['--exclude-module', os.path.splitext(file)[0]])

# Executando o PyInstaller
run(opts)

