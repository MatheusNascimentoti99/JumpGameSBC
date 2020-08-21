#Projeto desenvolvido para o problema 2 do MI - Sistemas Digitais

###Driver LCD16x2 utilizado: https://github.com/phanvandiem/LCD16x2_Driver

##Funções:

- write(char letra) - É utilizado o R9 como parâmetro. Sempre que chamar essa função deve-se atribuir a R9 o valor que deseja imprimir no LCD

- clear(void) - Limpa a display

- open(void) - Abre o arquivo lcd_1602

- close(void) - Fecha o arquivo lcd_1602

- home_title(void) - Imprime no LCD a mensagem inicial do jogo, "Pule para iniciar!".

- set_position_DOWN(void) - Altera o cursor para o início da segunda linha do display

- set_position_UP(void) - Altera o cursor para o início da primeira linha do display
