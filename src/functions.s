.include "data.s"

.section .text

// Funciones de otros modulos
.extern Sbox
.extern Rcon

.extern matState
.extern key
.extern criptograma
.extern buffer
// Funciones principales de AES

/*
 * IMPLEMENTACIÓN DE ADDROUNDKEY - OPERACIÓN AES
 * Realiza XOR entre la matriz de estado y la clave
 */
.type addRoundKey, %function
.global addRoundKey
addRoundKey:
    stp x29, x30, [sp, #-32]! 
    mov x29, sp 
    
    str x19, [sp, #16] 
    str x20, [sp, #24] 
    
    ldr x19, =matState 
    ldr x20, =key 
    
    mov x0, #0 
    
addroundkey_loop:
    cmp x0, #16
    b.ge addroundkey_done
    
    ldrb w1, [x19, x0] 
    ldrb w2, [x20, x0] 
    
    eor w3, w1, w2 
    
    strb w3, [x19, x0] 
    
    add x0, x0, #1
    b addroundkey_loop
    
addroundkey_done:
    ldr x19, [sp, #16]
    ldr x20, [sp, #24]
    
    ldp x29, x30, [sp], #32
    ret
    .size addRoundKey, (. - addRoundKey)

/*
 * IMPLEMENTACIÓN DE SUBBYTES - OPERACIÓN AES
 * Realiza la sustitución de bytes usando la S-box.
 */
.type subBytes, %function
.global subBytes
subBytes:
    stp x29, x30, [sp, #-32]! 
    mov x29, sp 
    
    str x19, [sp, #16] 
    str x20, [sp, #24] 
    
    ldr x19, =matState 
    ldr x20, =Sbox 
    
    mov x0, #0 
    
subbytes_loop:
    cmp x0, #16
    b.ge subbytes_done
    
    ldrb w1, [x19, x0] 
    
    uxtw x1, w1 
    
    ldrb w2, [x20, x1] 
    
    strb w2, [x19, x0] 
    
    add x0, x0, #1
    b subbytes_loop
    
subbytes_done:
    ldr x19, [sp, #16]
    ldr x20, [sp, #24]
    
    ldp x29, x30, [sp], #32
    ret
    .size subBytes, (. - subBytes)
    
/*
 * IMPLEMENTACIÓN DE SHIFTROWS - OPERACIÓN AES
*/
.type shiftRows, %function
.global shiftRows
shiftRows:
    stp x29, x30, [sp, #-32]! 
    mov x29, sp 

    str x19, [sp, #16]      
    ldr x19, =matState
    
    // 1. Shift Fila 1 (Offset base 4) - Rotación de 1 byte a la izquierda
    
    // Guardar S[1,0] (offset 4) en w1 como temporal (irá al final)
    ldrb w1, [x19, #4]
    
    // Desplazar los bytes: [x] [5] [6] [7]
    ldrb w2, [x19, #5]      // w2 = S[1,1]
    strb w2, [x19, #4]      // S[1,0] = S[1,1] (offset 5 -> 4)
    
    ldrb w2, [x19, #6]      // w2 = S[1,2]
    strb w2, [x19, #5]      // S[1,1] = S[1,2] (offset 6 -> 5)
    
    ldrb w2, [x19, #7]      // w2 = S[1,3]
    strb w2, [x19, #6]      // S[1,2] = S[1,3] (offset 7 -> 6)
    
    // Colocar el byte temporal (S[1,0]) al final
    strb w1, [x19, #7]      // S[1,3] = S[1,0] original (w1 -> 7)
    
    
    // 2. Shift Fila 2 (Offset base 8) - Rotación de 2 bytes a la izquierda
    
    // Guardar el primer par S[2,0] (8) y S[2,1] (9) en w1 y w2
    ldrb w1, [x19, #8]
    ldrb w2, [x19, #9]
    
    // Mover el segundo par S[2,2] (10) y S[2,3] (11) a las posiciones iniciales
    ldrb w3, [x19, #10]
    ldrb w4, [x19, #11]
    strb w3, [x19, #8]      // S[2,0] = S[2,2]
    strb w4, [x19, #9]      // S[2,1] = S[2,3]
    
    // Mover el par guardado a las posiciones finales
    strb w1, [x19, #10]     // S[2,2] = S[2,0] original
    strb w2, [x19, #11]     // S[2,3] = S[2,1] original
    
    // 3. Shift Fila 3 (Offset base 12) - Rotación de 3 bytes a la izquierda
    
    // Guardar S[3,3] (offset 15) en w1 como temporal (irá al inicio)
    ldrb w1, [x19, #15]
    
    // Desplazar los bytes: [12] [13] [14] [x]
    ldrb w2, [x19, #14]     // w2 = S[3,2]
    strb w2, [x19, #15]     // S[3,3] = S[3,2] (offset 14 -> 15)
    
    ldrb w2, [x19, #13]     // w2 = S[3,1]
    strb w2, [x19, #14]     // S[3,2] = S[3,1] (offset 13 -> 14)
    
    ldrb w2, [x19, #12]     // w2 = S[3,0]
    strb w2, [x19, #13]     // S[3,1] = S[3,0] (offset 12 -> 13)
    
    // Colocar el byte temporal (S[3,3]) al inicio
    strb w1, [x19, #12]     // S[3,0] = S[3,3] original (w1 -> 12)

    // Restaurar registros y retornar
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size shiftRows, (. - shiftRows)

/*
 * IMPLEMENTACIÓN DE MIXCOLUMNS - OPERACIÓN AES
 * Multiplica cada columna de la matriz de estado por la matriz de MixColumns.
 */

/*
 * Función: multiply_by_02 (Multiplicación por {02} en GF(2^8))
 * Entrada: w0 = byte a (multiplicando)
 * Salida: w0 = resultado (a * {02})
 */
.type multiply_by_02, %function
.global multiply_by_02
multiply_by_02:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // w1: Bandera para chequear el bit 7
    and w1, w0, #0x80           
    
    // Desplazamiento a la izquierda por 1 (a * 2)
    lsl w0, w0, #1              
    
    // Si el bit 7 era 1 (es decir, w1 != 0), aplicamos la reducción
    cmp w1, #0
    b.eq xtime_done             
    
    // CORRECCIÓN: cargar constante con MOV (no "ldr =imm")
    mov w2, #0x1B                // w2 = 0x1B
    eor w0, w0, w2               // w0 = w0 XOR 0x1B
    
xtime_done:
    ldp x29, x30, [sp], #16
    ret
.size xtime, (. - xtime)

/*
 * Función: multiply_by_03
 * Entrada: w0 = byte a (multiplicando)
 * Salida: w0 = resultado (a * {03})
 */
.type multiply_by_03, %function
.global multiply_by_03
multiply_by_03:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    mov w1, w0                  // w1 = a
    
    bl xtime                    // w0 = a * {02}
    
    eor w0, w0, w1              // w0 = (a * {02}) XOR a. Esto es a * {03}
    
    ldp x29, x30, [sp], #16
    ret
.size multiply_by_03, (. - multiply_by_03)


/*
 * IMPLEMENTACIÓN DE MIXCOLUMNS - OPERACIÓN AES
 * Multiplica cada columna de la matriz de estado por la matriz fija de MixColumns.
 */
.type mixColumns, %function
.global mixColumns
mixColumns:
    // Reservar frame grande y consistente (64 bytes) y crear frame pointer
    stp x29, x30, [sp, #-64]!
    mov x29, sp

    // Guardar cales/variables (x19..x21) dentro del frame en offsets constantes
    // [x29, #16]  <- x19
    // [x29, #24]  <- x20
    // [x29, #32]  <- x21
    str x19, [x29, #16]
    str x20, [x29, #24]
    str x21, [x29, #32]

    // Cargar puntero a matState (puede usarse ldr =label como pseudo-instrucción)
    ldr x19, =matState          // x19 = Puntero a matState (matriz de estado)

    // Reservar buffer temporal dentro del frame: ubicamos el buffer en [x29,#40 .. #55] (16 bytes)
    add x21, x29, #40           // x21 apunta al buffer temporal dentro del frame

    mov x20, #0                 // x20 = j (contador de columnas: 0 a 3)

column_loop:
    cmp x20, #4
    b.ge mixColumns_done        // Terminar después de la columna 3

    // ----------------------------------------------------
    // Calcular offset base de la columna en bytes: offset = j * 4
    // ----------------------------------------------------
    lsl x10, x20, #2            // x10 = j * 4

    // Dirección base de la columna: base = matState + offset
    add x11, x19, x10           // x11 = &matState[offset]

    // ----------------------------------------------------
    // Paso 1: Cargar la columna j del estado
    // x22: s[0,j], x23: s[1,j], x24: s[2,j], x25: s[3,j]
    // ----------------------------------------------------
    ldrb w22, [x11, #0]         // s[0,j]
    ldrb w23, [x11, #1]         // s[1,j]
    ldrb w24, [x11, #2]         // s[2,j]
    ldrb w25, [x11, #3]         // s[3,j]

    // ----------------------------------------------------
    // Paso 2: Calcular s'[0,j]
    // s'[0,j] = {02}*s[0,j] ^ {03}*s[1,j] ^ {01}*s[2,j] ^ {01}*s[3,j]
    // ----------------------------------------------------
    mov w0, w22                 // {02}*s[0,j]
    bl xtime                    // w0 = {02}*s[0,j]
    mov w4, w0
    
    mov w0, w23                 // {03}*s[1,j]
    bl multiply_by_03
    eor w4, w4, w0              // w4 ^= {03}*s[1,j]
    
    eor w4, w4, w24             // w4 ^= {01}*s[2,j] (es solo XOR con s[2,j])
    
    eor w4, w4, w25             // w4 ^= {01}*s[3,j]
    
    strb w4, [x21, #0]          // Guardar s'[0,j] en el buffer temporal


    // ----------------------------------------------------
    // Paso 3: Calcular s'[1,j]
    // s'[1,j] = {01}*s[0,j] ^ {02}*s[1,j] ^ {03}*s[2,j] ^ {01}*s[3,j]
    // ----------------------------------------------------
    mov w4, w22                 // w4 = {01}*s[0,j]
    
    mov w0, w23                 // {02}*s[1,j]
    bl xtime
    eor w4, w4, w0              // w4 ^= {02}*s[1,j]
    
    mov w0, w24                 // {03}*s[2,j]
    bl multiply_by_03
    eor w4, w4, w0              // w4 ^= {03}*s[2,j]
    
    eor w4, w4, w25             // w4 ^= {01}*s[3,j]
    
    strb w4, [x21, #1]          // Guardar s'[1,j] en el buffer temporal


    // ----------------------------------------------------
    // Paso 4: Calcular s'[2,j]
    // s'[2,j] = {01}*s[0,j] ^ {01}*s[1,j] ^ {02}*s[2,j] ^ {03}*s[3,j]
    // ----------------------------------------------------
    eor w4, w22, w23            // w4 = {01}*s[0,j] ^ {01}*s[1,j]
    
    mov w0, w24                 // {02}*s[2,j]
    bl xtime
    eor w4, w4, w0              // w4 ^= {02}*s[2,j]
    
    mov w0, w25                 // {03}*s[3,j]
    bl multiply_by_03
    eor w4, w4, w0              // w4 ^= {03}*s[3,j]
    
    strb w4, [x21, #2]          // Guardar s'[2,j] en el buffer temporal


    // ----------------------------------------------------
    // Paso 5: Calcular s'[3,j]
    // s'[3,j] = {03}*s[0,j] ^ {01}*s[1,j] ^ {01}*s[2,j] ^ {02}*s[3,j]
    // ----------------------------------------------------
    mov w0, w22                 // {03}*s[0,j]
    bl multiply_by_03
    mov w4, w0
    
    eor w4, w4, w23             // w4 ^= {01}*s[1,j]
    
    eor w4, w4, w24             // w4 ^= {01}*s[2,j]
    
    mov w0, w25                 // {02}*s[3,j]
    bl xtime
    eor w4, w4, w0              // w4 ^= {02}*s[3,j]
    
    strb w4, [x21, #3]          // Guardar s'[3,j] en el buffer temporal
    
    // ----------------------------------------------------
    // Paso 6: Escribir la nueva columna del buffer al estado (matState)
    // ----------------------------------------------------
    ldrb w4, [x21, #0]
    strb w4, [x11, #0]          // s'[0,j] -> s[0,j]
    
    ldrb w4, [x21, #1]
    strb w4, [x11, #1]          // s'[1,j] -> s[1,j]
    
    ldrb w4, [x21, #2]
    strb w4, [x11, #2]          // s'[2,j] -> s[2,j]
    
    ldrb w4, [x21, #3]
    strb w4, [x11, #3]          // s'[3,j] -> s[3,j]
    
    // ----------------------------------------------------
    // Preparar siguiente columna
    // ----------------------------------------------------
    add x20, x20, #1
    b column_loop

mixColumns_done:
    // Restaurar variables guardadas y limpiar el frame
    ldr x21, [x29, #32]
    ldr x20, [x29, #24]
    ldr x19, [x29, #16]
    ldp x29, x30, [sp], #64
    ret
.size mixColumns, (. - mixColumns)
