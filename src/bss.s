// Variables globales no inicializadas.

.section .bss

// Matriz de estado del texto en claro de 128 bits
.global matState
matState: .space 16, 0 

// Matriz de llave inicial de 128 bits
.global key
key: .space 16, 0 

// Buffer para almacenar el resultado de la encriptacion
.global criptograma
criptograma: .space 16, 0 

// Buffer utilizado para almacenar la entrada del usuario
.global buffer
buffer: .space 256, 0 
