import os
import sys
from cx_Freeze import setup, Executable

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

# Atualizar o requirements.txt com as dependências em uso no ambiente virtual
os.system('pip freeze > requirements.txt')

# Lendo o arquivo requirements.txt para obter as dependências
with open('requirements.txt') as f:
    requirements = f.read().splitlines()

# Dependencies are automatically detected, but it might need
# fine tuning.
build_options = {
    'packages': requirements,  # Incluindo as dependências do requirements.txt
    'excludes': [],
    'include_files': [(f, '') for f in ini_files] + [(f, os.path.join('src/database/sql/', os.path.relpath(f, 'src/database/sql/'))) for f in sql_files],
    # Outras opções podem ser adicionadas aqui, se necessário
}

base = 'console'

executables = [
    Executable(
        # os.path.join('pythonProject', 'app.py'),
        'app.py',
        base=base,
        target_name = 'dfi'
    )
]

setup(name='dfi-datafusion_insights',
      version = '1.0.0',
      description = 'Aplicativo para coleta de dados e inserção em banco de dados SQL Server',
      options = {'build_exe': build_options},
      executables = executables)
