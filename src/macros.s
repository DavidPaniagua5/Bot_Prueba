// Definiciones de macros para syscalls.

// fd = file descriptor (1=stdout), buffer = direccion, len = longitud
.macro print fd, buffer, len
    mov x0, \fd
    ldr x1, =\buffer
    mov x2, \len
    mov x8, #64 // sys_write
    svc #0
.endm

// fd = file descriptor (0=stdin), buffer = direccion, len = longitud maxima
.macro read fd, buffer, len
    mov x0, \fd
    ldr x1, =\buffer
    mov x2, \len
    mov x8, #63 // sys_read
    svc #0
.endm
