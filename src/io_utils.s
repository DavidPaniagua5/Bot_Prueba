.include "macros.s"
.include "data.s"

.section .text

.extern matState
.extern key
.extern criptograma
.extern buffer

.type is_hex_char, %function
is_hex_char:
    cmp w4, #'0'
    b.lt not_hex
    cmp w4, #'9'
    b.le is_hex
    
    orr w4, w4, #0x20       // Convertir a minúscula
    cmp w4, #'a'
    b.lt not_hex
    cmp w4, #'f'
    b.le is_hex
    
not_hex:
    mov w0, #0
    ret
is_hex:
    mov w0, #1
    ret
.size is_hex_char, (. - is_hex_char)


.type hex_char_to_nibble, %function
hex_char_to_nibble:
    cmp w4, #'0'
    b.lt hex_error
    cmp w4, #'9'
    b.le hex_digit
    
    orr w4, w4, #0x20       // Convertir a minúscula
    cmp w4, #'a'
    b.lt hex_error
    cmp w4, #'f'
    b.gt hex_error
    
    sub w0, w4, #'a'
    add w0, w0, #10
    ret
    
hex_digit:
    sub w0, w4, #'0'
    ret
    
hex_error:
    print 1, key_err_msg, lenKeyErr
    mov w0, #0
    ret
.size hex_char_to_nibble, (. - hex_char_to_nibble)

.type readTextInput, %function
.global readTextInput
readTextInput:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Leer entrada del usuario
    read 0, buffer, 256
    
    ldr x1, =buffer
    ldr x2, =matState
    mov x3, #0              // Contador de bytes leídos
    
convert_text_loop:
    cmp x3, #16
    b.ge convert_text_done
    
    ldrb w4, [x1, x3]
    cmp w4, #10             // Newline
    b.eq pad_remaining_bytes
    cmp w4, #0              // Null terminator
    b.eq pad_remaining_bytes
    
    // COLUMN-MAJOR: offset = columna * 4 + fila
    // donde: columna = index / 4, fila = index % 4
    
    mov x7, #4
    udiv x8, x3, x7         // x8 = columna (index / 4)
    msub x9, x8, x7, x3     // x9 = fila (index % 4)
    lsl x10, x8, #2         // x10 = columna * 4
    add x10, x10, x9        // x10 = columna * 4 + fila
    
    strb w4, [x2, x10]
    add x3, x3, #1
    b convert_text_loop
    
pad_remaining_bytes:
    cmp x3, #16
    b.ge convert_text_done
    
    mov x7, #4
    udiv x8, x3, x7
    msub x9, x8, x7, x3
    lsl x10, x8, #2
    add x10, x10, x9
    
    mov w4, #0
    strb w4, [x2, x10]
    add x3, x3, #1
    b pad_remaining_bytes
    
convert_text_done:
    ldp x29, x30, [sp], #16
    ret
.size readTextInput, (. - readTextInput)


.type convertHexKey, %function
.global convertHexKey
convertHexKey:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    read 0, buffer, 33
    
    ldr x1, =buffer
    ldr x2, =key
    mov x3, #0              // Contador de bytes procesados
    mov x11, #0             // Índice en el buffer
    
convert_hex_loop:
    cmp x3, #16
    b.ge convert_hex_done
    
skip_non_hex:
    ldrb w4, [x1, x11]
    cmp w4, #0
    b.eq convert_hex_done
    cmp w4, #10
    b.eq convert_hex_done
    
    bl is_hex_char
    cmp w0, #1
    b.eq process_hex_pair
    
    add x11, x11, #1
    b skip_non_hex
    
process_hex_pair:
    // Procesar nibble alto
    ldrb w4, [x1, x11]
    add x11, x11, #1
    bl hex_char_to_nibble
    lsl w5, w0, #4
    
    // Procesar nibble bajo
    ldrb w4, [x1, x11]
    add x11, x11, #1
    bl hex_char_to_nibble
    orr w5, w5, w0
    
    // COLUMN-MAJOR: offset = columna * 4 + fila
    mov x7, #4
    udiv x8, x3, x7         // columna
    msub x9, x8, x7, x3     // fila
    lsl x10, x8, #2         // columna * 4
    add x10, x10, x9        // + fila
    
    strb w5, [x2, x10]
    add x3, x3, #1
    b convert_hex_loop
    
convert_hex_done:
    ldp x29, x30, [sp], #16
    ret
.size convertHexKey, (. - convertHexKey)