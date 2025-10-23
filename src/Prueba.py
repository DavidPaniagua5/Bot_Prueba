import textwrap

AES_POLY = 0x1B 

S_BOX = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
]

def xor_hex_strings(hex1: str, hex2: str) -> str:
    hex1 = hex1.replace(" ", "").upper()
    hex2 = hex2.replace(" ", "").upper()
    
    if len(hex1) != len(hex2) or len(hex1) != 32:
        raise ValueError("Ambas cadenas deben ser de 32 caracteres hexadecimales (16 bytes) después de eliminar espacios.")
    
    int1 = int(hex1, 16)
    int2 = int(hex2, 16)
    
    xor_result = int1 ^ int2
    
    return f'{xor_result:032X}'

def hex_to_matrix(hex_string: str) -> list[list[str]]:
    if len(hex_string) != 32:
        raise ValueError("La cadena para la matriz debe ser de 32 caracteres hexadecimales.")
    
    bytes_list = textwrap.wrap(hex_string, 2)
    matrix = [['' for _ in range(4)] for _ in range(4)]
    
    # Llenar la matriz en orden Column-Major (Columna-Principal)
    for i in range(16):
        byte = bytes_list[i]
        
        row = i % 4
        col = i // 4
        
        matrix[row][col] = byte
    return matrix

def matrix_to_hex(matrix: list[list[str]]) -> str:
    hex_list = []
    # Recorrer en orden Column-Major: columna primero (j), luego fila (i)
    for col in range(4):
        for row in range(4):
            hex_list.append(matrix[row][col])
    return "".join(hex_list)

def byte_sub(matrix: list[list[str]]) -> list[list[str]]:
    new_matrix = [['' for _ in range(4)] for _ in range(4)]
    
    for row in range(4):
        for col in range(4):
            byte_hex_str = matrix[row][col]
            
            index = int(byte_hex_str, 16)
            sub_value_int = S_BOX[index]
            sub_value_hex_str = f'{sub_value_int:02X}'
            new_matrix[row][col] = sub_value_hex_str
            
    return new_matrix
# ----------------------------------------------------------------------

def shift_rows(matrix: list[list[str]]) -> list[list[str]]:
    if len(matrix) != 4 or any(len(row) != 4 for row in matrix):
        raise ValueError("La matriz debe ser de 4x4.")

    new_matrix = [['' for _ in range(4)] for _ in range(4)]

    for row_index in range(4):
        row = matrix[row_index]
        shift_amount = row_index
        
        new_matrix[row_index] = row[shift_amount:] + row[:shift_amount]
            
    return new_matrix

def print_matrix(matrix: list[list[str]], title: str):
    print(f"\n{title} (4x4):")
    print("-" * 35)
    for row in range(4):
        print("  ".join(matrix[row]))
    print("-" * 35)


# Módulo irreducible para GF(2^8) en AES: x^8 + x^4 + x^3 + x + 1 (0x11B)
# Usaremos 0x1B (27) porque el bit más significativo (x^8) se maneja implícitamente
# durante la reducción (XOR) si el byte de 9 bits resultante supera 0xFF.
def gmul2(b: int) -> int:
    """
    Multiplica un byte 'b' por {02} en GF(2^8).
    Equivalente a una rotación a la izquierda con reducción.
    """
    # 1. Rotación a la izquierda (Multiplicación por x)
    # Si b < 128 (0x80), el resultado es solo b << 1
    result = b << 1
    
    # 2. Reducción (Verificar si el bit x^8 se activó)
    # Si el bit 7 (0x80) estaba activado, el desplazamiento activó x^8 (bit 8)
    if b & 0x80:
        # Si x^8 está activado, se resta el módulo: result XOR 0x1B
        result ^= AES_POLY
        
    # Asegurarse de que el resultado sea solo 8 bits (0xFF = 255)
    return result & 0xFF

def gmul3(b: int) -> int:
    """
    Multiplica un byte 'b' por {03} en GF(2^8).
    {03} * b = ({02} * b) XOR b
    """
    # {02} * b
    b2 = gmul2(b)
    
    # ({02} * b) XOR b (Adición es XOR en GF(2^8))
    return b2 ^ b

# Matriz de constantes para MixColumns [cite: 325]
MIX_MATRIX = [
    [0x02, 0x03, 0x01, 0x01],
    [0x01, 0x02, 0x03, 0x01],
    [0x01, 0x01, 0x02, 0x03],
    [0x03, 0x01, 0x01, 0x02]
]

def mix_columns(matrix: list[list[str]]) -> list[list[str]]:
    """
    Implementa la transformación MixColumns de AES.
    Aplica una transformación lineal a cada columna de la matriz de estado.
    """
    new_matrix = [['' for _ in range(4)] for _ in range(4)]
    
    # Convertir la matriz de string hexadecimal a enteros
    state_int = [[int(matrix[r][c], 16) for c in range(4)] for r in range(4)]
    
    for c in range(4): # Columna a operar [cite: 332]
        
        # Extracción de la columna para mayor claridad
        s0, s1, s2, s3 = state_int[0][c], state_int[1][c], state_int[2][c], state_int[3][c]
        
        # Cálculo de la nueva columna c' utilizando las fórmulas
        # s'_{0,c} = ({02} * s_{0,c}) XOR ({03} * s_{1,c}) XOR s_{2,c} XOR s_{3,c} [cite: 329]
        s0_prime = gmul2(s0) ^ gmul3(s1) ^ s2 ^ s3
        
        # s'_{1,c} = s_{0,c} XOR ({02} * s_{1,c}) XOR ({03} * s_{2,c}) XOR s_{3,c} [cite: 330]
        s1_prime = s0 ^ gmul2(s1) ^ gmul3(s2) ^ s3
        
        # s'_{2,c} = s_{0,c} XOR s_{1,c} XOR ({02} * s_{2,c}) XOR ({03} * s_{3,c}) [cite: 331]
        s2_prime = s0 ^ s1 ^ gmul2(s2) ^ gmul3(s3)
        
        # s'_{3,c} = ({03} * s_{0,c}) XOR s_{1,c} XOR s_{2,c} XOR ({02} * s_{3,c}) [cite: 331]
        s3_prime = gmul3(s0) ^ s1 ^ s2 ^ gmul2(s3)
        
        # Convertir los resultados de vuelta a string hexadecimal y almacenarlos
        new_matrix[0][c] = f'{s0_prime:02X}'
        new_matrix[1][c] = f'{s1_prime:02X}'
        new_matrix[2][c] = f'{s2_prime:02X}'
        new_matrix[3][c] = f'{s3_prime:02X}'
            
    return new_matrix

# --- EJECUCIÓN DEL PROGRAMA ---

#--- Texto del archivo del proyecto ---
# STATE_HEX= "3FA21B7C9D564EF188007AC3D49E116B"
#--- Texto del texto de prueba ABC0123456789ABC ---
# STATE_HEX = "41424330313233343536373839414243"
#--- Texto de prueba en pagina https://www.teoria.com/jra/aes/encrypt.html ---
STATE_HEX = "4d656e73616a65207365637265746f2e"

#STATE_HEX = "54776f204f6e65204e696e652054776f"
#--- Llave usada en pruebas ---
# KEY_HEX = "C17DA4216A8FB10E77FF853C2B61EE94" 
#--- Llave usada en pagina https://www.teoria.com/jra/aes/encrypt.html ---
KEY_HEX = "2B7E151628AED2A6ABF7158809CF4F3C"
#KEY_HEX = "5468617473206D79204B756E67204675"

try:
    print(f"Estado (Input): {STATE_HEX}")
    print(f"Clave (Key):    {KEY_HEX}")
    
    result_hex = xor_hex_strings(STATE_HEX, KEY_HEX)
    print(f"\nResultado XOR (Secuencial): {result_hex}")
    
    state_matrix_xor = hex_to_matrix(result_hex)
    print_matrix(state_matrix_xor, "Matriz de Estado (Post-XOR)")

    state_matrix_sub = byte_sub(state_matrix_xor)
    print_matrix(state_matrix_sub, "Matriz de Estado (Post-ByteSub)")
    
    state_matrix_s_prime = shift_rows(state_matrix_sub)
    print_matrix(state_matrix_s_prime, "Matriz de Estado (Post-ShiftRow)")

    state_matrix = mix_columns(state_matrix_s_prime)
    print_matrix(state_matrix, "Matriz de Estado (Post-MixColumns)")
    
    final_hex = matrix_to_hex(state_matrix)
    print(f"\nResultado Final (Secuencial): {final_hex}")

except ValueError as e:
    print(f"\nError: {e}")