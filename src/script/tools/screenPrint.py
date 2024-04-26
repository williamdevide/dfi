import inspect
import logging
import os

lengthLine = 200  # Tamanho total da linha entre os | |
lengthTask = lengthLine - 20  # Espaço reservado para as tarefas
lengthTaskItem = lengthTask - 60  # Espaço reservado para os itens de tarefas
lengthTaskRecords = 60  # Espaço reservado para impressão dos records
lengthTaskStatus = 20  # Espaço reservado para o status


def rp(character, length):
    return character * length


def ft(text, length, align='left'):
    if len(text) >= lengthLine:
        return text[:length]

    lengthUtil = length - 2

    padding_length = lengthUtil - len(text)
    if align == 'left':
        textReturn = text + ' ' * padding_length
    elif align == 'right':
        textReturn = ' ' * padding_length + text
    elif align == 'center':
        left_padding = padding_length // 2
        right_padding = padding_length - left_padding
        textReturn = ' ' * left_padding + text + ' ' * right_padding
    else:
        raise ValueError("Alignment must be 'left', 'right', or 'center'")

    textReturn = ' ' + textReturn + ' '
    return textReturn


# criar as funções de print nesse arquivo e passar a utilizar elas:


# print linha
def spLineBoxUp():
    print(f'┌{rp('-', lengthLine)}┐')


def spLineBoxDown():
    print(f'└{rp('-', lengthLine)}┘')


def spLineBoxMiddle():
    print(f'├{rp('-', lengthLine)}┤')


def spLineBoxBlank():
    print(f'|{rp(' ', lengthLine)}|')


def spLineBoxTitle(text):
    print(f'|{ft(text, lengthLine)}|')


def spLineBoxText(text, variable):
    formatedText = text + ' ' + variable
    print(f'|{ft(formatedText, lengthLine)}|')


def spLineBoxTaskUnique(text):
    prefix = '=> '
    formatedText = prefix + text + rp(' ', lengthTask - len(text) - len(prefix) - 1)
    print(f'|{ft(formatedText, len(formatedText))}', end='')


def spLineBoxTaskOpen(text):
    prefix = '=> Início: '
    formatedText = prefix + text + rp(' ', lengthLine - len(text) - len(prefix) - 2)
    print(f'|{ft(formatedText, len(formatedText))}|')


def spLineBoxTaskClose(text):
    prefix = '   => Final: '
    formatedText = prefix + text + rp(' ', lengthTask - len(text) - len(prefix) - 1)
    print(f'|{ft(formatedText, len(formatedText))}', end='')


def spLineBoxTaskItemWithRecords(text):
    prefix = '   -> '
    formatedText = prefix + text + rp(' ', lengthTaskItem - len(text) - len(prefix) - 1)
    print(f'|{ft(formatedText, len(formatedText))}', end='')


def spLineBoxTaskItemWithOutRecords(text):
    prefix = '   -> '
    formatedText = prefix + text + rp(' ', lengthTask - len(text) - len(prefix) - 1)
    print(f'|{ft(formatedText, len(formatedText))}', end='')


def spLineBoxTaskRecords(text):
    prefix = ''
    formatedText = prefix + text + rp(' ', lengthTaskRecords - len(text) - len(prefix) - 2)
    print(f'{ft(formatedText, len(formatedText), 'center')}', end='')


def spLineBoxTaskStatus(text):
    print(f'{ft(text, lengthTaskStatus - 1, 'center')}|')


def spLineBoxTaskErrors(text, msg=''):
    spLineBoxTaskStatus('[FALHA]')
    errorLine1 = ('      (X) ' + os.path.basename(inspect.stack()[1].filename) + ".[" + inspect.stack()[1].function + ']: ' + text + ': ' + msg)
    print(f'|{ft(errorLine1, lengthTask)} ', end='')
    logging.info("      => Error: {}".format(errorLine1))


def spLineBoxError(text):
    prefix = ''
    formatedText = prefix + text + rp(' ', lengthLine - len(prefix) - len(text))
    print(f'|{ft(formatedText, len(formatedText))}')
    logging.info("      => Error: {}".format(formatedText))


def spLineBlank():
    print(f' {rp(' ', lengthLine + 2)} ')


def spCount():
    print(f'|{rp('1234567890', 20)}|')


def spHeader():
    print(f'|{rp(' ', 4)}TAREFA{rp(' ', 115)}REGISTROS{rp(' ', 53)}STATUS{rp(' ', 7)}|')

# print titulo
# print mensagem
# print abertura bloco
# print fechamento bloco
# print passo
# print erro
# print sucesso
