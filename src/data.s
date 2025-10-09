// Cadenas de texto y tablas de consulta fijas.

.section .data

// CADENAS DE TEXTO
msg_txt: .asciz "Ingrese el texto a cifrar (maximo 16 caracteres): "
    lenMsgTxt = . - msg_txt

msg_key: .asciz "Ingrese la clave (32 caracteres hex): "
    lenMsgKey = . - msg_key

key_err_msg: .asciz "Error: Valor de clave incorrecto\n"
    lenKeyErr = . - key_err_msg

newline: .asciz "\n"
    
debug_state: .asciz "Matriz de Estado:\n"
    lenDebugState = . - debug_state

debug_key: .asciz "Matriz de Clave:\n"
    lenDebugKey = . - debug_key

msg_before_subbytes: .asciz "Estado ANTES de SubBytes:\n"
    lenMsgBeforeSub = . - msg_before_subbytes

msg_after_subbytes: .asciz "Estado DESPUÉS de SubBytes:\n"
    lenMsgAfterSub = . - msg_after_subbytes

msg_before_addroundkey: .asciz "Estado ANTES de AddRoundKey (XOR con clave):\n"
    lenMsgBeforeAdd = . - msg_before_addroundkey

msg_after_addroundkey: .asciz "Estado DESPUÉS de AddRoundKey:\n"
    lenMsgAfterAdd = . - msg_after_addroundkey

msg_before_shiftrows: .asciz "Estado ANTES de ShiftRows:\n"
    lenMsgBeforeShift = . - msg_before_shiftrows

msg_after_shiftrows: .asciz "Estado DESPUÉS de ShiftRows:\n"
    lenMsgAfterShift = . - msg_after_shiftrows

msg_before_mixcolumns: .asciz "Estado ANTES de MixColumns:\n"
        lenMsgBeforeMix = . - msg_before_mixcolumns

msg_after_mixcolumns: .asciz "Estado DESPUÉS de MixColumns:\n"
        lenMsgAfterMix = . - msg_after_mixcolumns
