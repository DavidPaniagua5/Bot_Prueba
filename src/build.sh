# Script de compilación y enlazado para código ARM64 (AArch64)

# 1. Definir herramientas de compilación cruzada (Cross-tools)
AS="aarch64-linux-gnu-as"
LD="aarch64-linux-gnu-ld"
TARGET="Main"

# Lista de todos los archivos fuente (módulos)
SRC_FILES="main.s functions.s io_utils.s debug_utils.s data.s bss.s constants.s macros.s"

# Arreglo para almacenar los archivos objeto generados
OBJ_FILES=""

echo "--- Ensamblando archivos fuente (.s) a archivos objeto (.o) ---"

# 2. Ensamblar cada archivo fuente
for file in $SRC_FILES; do
    OBJ_FILE="${file%.s}.o"
    echo "Ensamblando $file -> $OBJ_FILE"
    # El ensamblador genera el archivo objeto para la arquitectura AArch64
    $AS -o "$OBJ_FILE" "$file"
    
    # Verificar el código de salida del ensamblador
    if [ $? -ne 0 ]; then
        echo "ERROR: Falló el ensamblado de $file. Abortando."
        exit 1
    fi
    OBJ_FILES="$OBJ_FILES $OBJ_FILE"
done

echo "--- Enlazando archivos objeto a ejecutable final ---"

# 3. Enlazar todos los archivos objeto
$LD -o "$TARGET" $OBJ_FILES

if [ $? -eq 0 ]; then
    echo "--- ÉXITO ---"
    echo "El ejecutable $TARGET (ARM64) ha sido creado."
    
    chmod +x "$TARGET"
else
    echo "ERROR: Falló el enlazado del ejecutable. Abortando."
    exit 1
fi

echo "--- Ejecutando con QEMU ---"
# 5. Ejecutar el binario ARM64 usando QEMU System
qemu-aarch64 "$TARGET"