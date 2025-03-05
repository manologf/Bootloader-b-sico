ORG 7C00h  ; Dirección donde la BIOS carga el código

CLI  ; Ignorar las interrupciones
MOV SI, Prompt
MOV AH, 0Eh  ; Función de impresión de caracteres en modo texto

print_prompt:
    LODSB  ; AL <- DS:[SI], SI++
    OR AL, AL
    JZ wait_input
    INT 10h
    JMP print_prompt

wait_input:
    MOV DI, buffer  ; Apuntar al buffer de entrada
    MOV CX, 0       ; Contador de caracteres

read_loop:
    MOV AH, 00h     ; Esperar pulsación de tecla
    INT 16h         ; Leer tecla en AL
    CMP AL, 13      ; ¿Es Enter?
    JE end_input
    CMP AL, 08h     ; ¿Es Backspace (0x08)?
    JE backspace_pressed
    CMP CX, 15      ; Limitar longitud de comando
    JGE read_loop
    MOV [DI], AL    ; Guardar carácter en el buffer
    INC DI
    INC CX
    MOV AH, 0Eh     ; Mostrar en pantalla
    INT 10h
    JMP read_loop

end_input:
    MOV BYTE [DI], 0 ; Asegurarse de terminar la cadena con NULL
    JMP process_command
    
backspace_pressed:
    ; Si la tecla de retroceso es presionada
    DEC DI          ; Mover el puntero hacia atrás en el buffer
    DEC CX          ; Decrementar el contador de caracteres
    MOV AL, 08h     ; Mostrar un espacio en la pantalla (para borrar)
    CALL print_char ; Imprimir el espacio
    MOV AL, 20h     ; Volver a imprimir el cursor (para borrar)
    CALL print_char ; Imprimir el carácter de retroceso
    MOV AL, 08h     ; De nuevo el retroceso
    CALL print_char ; Borrar el carácter en la pantalla
    JMP read_loop   ; Continuar leyendo

process_command:
    MOV BYTE [DI], 0 ; Terminar cadena con NULL
    MOV SI, buffer

    ; Comparar con "INFO"
    MOV DI, cmd_info
    CALL compare_strings
    JZ show_info

    ; Comparar con "TIME"
    MOV DI, cmd_time
    CALL compare_strings
    JZ show_time

    ; Comparar con "DATE"
    MOV DI, cmd_date
    CALL compare_strings
    JZ show_date

    ; Comparar con "CLEAR"
    MOV DI, cmd_clear
    CALL compare_strings
    JZ clear_screen

    ; Comparar con "EXIT"
    MOV DI, cmd_exit
    CALL compare_strings
    JZ exit_program
    
    ; Comparar con "HELP"
    MOV DI, cmd_help
    CALL compare_strings
    JZ show_help

    ; Si no se ha reconocido el comando
    MOV SI, unknown_command
    CALL print_string
    JMP wait_input

show_info:
    MOV SI, sys_info
    CALL print_string
    JMP wait_input

show_time:
    MOV AH, 02h  ; Leer hora del sistema
    INT 1Ah
    CALL print_time
    JMP wait_input

show_date:
    MOV AH, 04h ; Leer fecha del sistema 
    INT 1Ah 
    CALL print_date
    JMP wait_input

clear_screen:
    MOV AX, 03h  ; Modo texto 80x25 (limpiar pantalla)
    INT 10h
    JMP wait_input

unknown_command:
    MOV SI, unknown_msg
    CALL print_string
    JMP wait_input

; Subrutina para comparar cadenas
compare_strings:
    PUSH SI
    PUSH DI
comp_loop:
    MOV AL, [SI]      ; Cargar un byte de la cadena de entrada
    MOV BL, [DI]      ; Cargar un byte de la cadena de comparación
    CMP AL, BL        ; Comparar caracteres
    JNE not_equal     ; Si son distintos, no coinciden
    CMP AL, 0         ; ¿Hemos llegado al final?
    JE equal          ; Si ambas terminan, son iguales
    INC SI            ; Avanzar en ambas cadenas
    INC DI
    JMP comp_loop     ; Continuar comparando
not_equal:
    MOV AX, 1         ; Retornar 1 (diferente)
    JMP end_compare
equal:
    MOV AX, 0         ; Retornar 0 (iguales)
end_compare:
    POP DI
    POP SI
    RET

; Subrutina para imprimir una cadena
print_string:
    MOV AH, 0Eh
print_loop:
    LODSB
    OR AL, AL
    JZ done
    INT 10h
    JMP print_loop
done:
    RET

; Subrutina para imprimir la fecha
print_date:
    MOV AL, DL  ; Día
    CALL print_hex
    MOV AL, '/'
    CALL print_char
    MOV AL, DH  ; Mes
    CALL print_digit
    MOV AL, '/'
    CALL print_char
    MOV AX, CX  ; Cargar el año (CH contiene el año desde 1900)
    AND AX, 0FFh ; Obtener los últimos dos dígitos del año
    CALL print_hex ; Imprimir el año en formato hexadecimal
    CALL print_newline

    RET
    
; Subrutina para imprimir la hora
print_time:
    ; Suponiendo que ya se ha llamado a INT 1Ah para obtener la hora
    MOV AL, CH
    CALL print_hex
    MOV AL, ':'
    CALL print_char
    MOV AL, DH
    CALL print_hex
    CALL print_newline
    RET

print_hex:
    MOV AH, 0Eh
    SHR AL, 4
    CALL print_digit
    AND AL, 0Fh
    CALL print_digit
    RET

print_digit:
    ADD AL, '0'
    CMP AL, '9'
    JBE print_char
    ADD AL, 7
print_char:
    INT 10h
    RET

print_newline:
    MOV AL, 13
    INT 10h
    MOV AL, 10
    INT 10h
    RET
    
; Comando EXIT
exit_program:
    MOV SI, exit_msg   ; Cargar la dirección del mensaje de salida
    CALL print_string  ; Imprimir el mensaje
    JMP $              ; Bucle infinito que simula la salida
    
show_help:
    MOV SI, help_msg
    CALL print_string
    JMP wait_input  ; Volver a esperar un nuevo comando

Prompt: db "Mini-Shell> ", 0
cmd_info: db "INFO", 0
cmd_time: db "TIME", 0
cmd_date: db "DATE", 0
cmd_clear: db "CLR", 0
cmd_exit: db "EXIT", 0  
cmd_help: db "HELP", 0
sys_info: db "Sys1.0", 13, 10, 0
unknown_msg: db "Unknown", 13, 10, 0
exit_msg: db "Saliendo... Adios!", 13, 10, 0
help_msg: db "Cmds:INFO-TIME-DATE-CLR-EXIT", 13, 10, 0

buffer: times 6 db 0

times 510 - ($ - $$) db 0
DW 0xAA55
