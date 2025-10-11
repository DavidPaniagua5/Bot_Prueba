.include "macros.s"
.include "data.s"
// .include "bss.s"

.section .text

// Incluir funciones de otros módulos para ensamblado
.extern readTextInput
.extern convertHexKey
.extern printMatrix
.extern testAddRoundKey
.extern testSubBytes
.extern testShiftRows
.extern testMixColumns

.extern matState
.extern key
.extern criptograma
.extern buffer

.type _start, %function
.global _start
_start:
    // Leer texto
    print 1, msg_txt, lenMsgTxt
    bl readTextInput
    
    // Mostrar estado inicial del texto
    print 1, debug_state, lenDebugState
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // Leer clave
    print 1, msg_key, lenMsgKey
    bl convertHexKey
    
    // Mostrar clave
    print 1, debug_key, lenDebugKey
    ldr x0, =key
    ldr x1, =debug_key
    mov x2, lenDebugKey
    bl printMatrix
    
    // PASO 1: AddRoundKey (XOR inicial)
    bl testAddRoundKey
    
    // PASO 2: SubBytes (sustitución)
    bl testSubBytes
    
    // PASO 3: ShiftRows (rotar filas a la izquierda)
    bl testShiftRows

    // PASO 4: MixColumns (Aplicar campo de Galois)
    bl testMixColumns

    // Salir del programa
    mov x0, #0
    mov x8, #93
    svc #0
    
    .size _start, (. - _start)
    