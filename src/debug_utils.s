// ============================================================
// debug_utils.s - VERSIÓN COLUMN-MAJOR COMPLETA
// ============================================================

.include "macros.s"
.include "data.s"

.section .text

.extern addRoundKey
.extern subBytes
.extern shiftRows
.extern mixColumns

.extern matState
.extern key
.extern criptograma
.extern buffer

// ============================================================
// FUNCIÓN PARA IMPRIMIR BYTE EN HEXADECIMAL
// ============================================================
.type print_hex_byte, %function
print_hex_byte:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Separar nibbles
    and w1, w0, #0xF0
    lsr w1, w1, #4
    and w2, w0, #0x0F
    
    // Convertir nibble alto
    cmp w1, #10
    b.lt high_digit
    add w1, w1, #'A' - 10
    b high_done
high_digit:
    add w1, w1, #'0'
high_done:
    
    // Convertir nibble bajo
    cmp w2, #10
    b.lt low_digit
    add w2, w2, #'A' - 10
    b low_done
low_digit:
    add w2, w2, #'0'
low_done:
    
    // Imprimir
    sub sp, sp, #16
    strb w1, [sp]
    strb w2, [sp, #1]
    mov w3, #' '
    strb w3, [sp, #2]
    
    mov x0, #1
    mov x1, sp
    mov x2, #3
    mov x8, #64
    svc #0
    
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret
.size print_hex_byte, (. - print_hex_byte)


// ============================================================
// FUNCIÓN PARA IMPRIMIR MATRIZ - COLUMN-MAJOR
// ============================================================
.type printMatrix, %function
.global printMatrix
printMatrix:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    
    str x0, [sp, #16]
    str x1, [sp, #24]
    str x2, [sp, #32]
    
    // Imprimir mensaje
    mov x0, #1
    ldr x1, [sp, #24]
    ldr x2, [sp, #32]
    mov x8, #64
    svc #0
    
    mov x23, #0             // Contador de filas
    
print_row_loop:
    cmp x23, #4
    b.ge print_matrix_done
    
    mov x24, #0             // Contador de columnas
    
print_col_loop:
    cmp x24, #4
    b.ge print_row_newline
    
    // COLUMN-MAJOR: offset = columna * 4 + fila
    lsl x25, x24, #2        // x25 = columna * 4
    add x25, x25, x23       // x25 = columna * 4 + fila
    
    ldr x20, [sp, #16]
    ldrb w0, [x20, x25]
    bl print_hex_byte
    
    add x24, x24, #1
    b print_col_loop
    
print_row_newline:
    print 1, newline, 1
    add x23, x23, #1
    b print_row_loop
    
print_matrix_done:
    print 1, newline, 1
    ldp x29, x30, [sp], #48
    ret
.size printMatrix, (. - printMatrix)


// ============================================================
// FUNCIONES DE PRUEBA
// ============================================================

.type testAddRoundKey, %function
.global testAddRoundKey
testAddRoundKey:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    print 1, msg_before_addroundkey, lenMsgBeforeAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl addRoundKey
    
    print 1, msg_after_addroundkey, lenMsgAfterAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    ldp x29, x30, [sp], #16
    ret
.size testAddRoundKey, (. - testAddRoundKey)


.type testSubBytes, %function
.global testSubBytes
testSubBytes:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    print 1, msg_before_subbytes, lenMsgBeforeSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl subBytes
    
    print 1, msg_after_subbytes, lenMsgAfterSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    ldp x29, x30, [sp], #16
    ret
.size testSubBytes, (. - testSubBytes)


.type testShiftRows, %function
.global testShiftRows
testShiftRows:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    print 1, msg_before_shiftrows, lenMsgBeforeShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix

    bl shiftRows

    print 1, msg_after_shiftrows, lenMsgAfterShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix

    ldp x29, x30, [sp], #16
    ret
.size testShiftRows, (. - testShiftRows)


.type testMixColumns, %function
.global testMixColumns
testMixColumns:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    print 1, msg_before_mixcolumns, lenMsgBeforeMix
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl mixColumns
    
    print 1, msg_after_mixcolumns, lenMsgAfterMix
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    ldp x29, x30, [sp], #16
    ret
.size testMixColumns, (. - testMixColumns)