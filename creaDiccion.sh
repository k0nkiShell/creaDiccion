#!/bin/bash

# Definir códigos de color
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Verificar si se han proporcionado los parámetros correctos
if [ "$#" -ne 4 ]; then
    echo "Uso: $0 <número_de_caracteres> <texto_fijo> <i|f> <numeric|text|alphanumeric>"
    exit 1
fi

# Leer los parámetros
num_chars=$1
fixed_text=$2
position=$3
generation_type=$4

# Verificar que el número de caracteres es válido
if ! [[ "$num_chars" =~ ^[0-9]+$ ]] || [ "$num_chars" -lt 1 ]; then
    echo "El número de caracteres debe ser un número entero positivo."
    exit 1
fi

# Verificar que la posición de inserción es válida
if [[ "$position" != "i" && "$position" != "f" ]]; then
    echo "La posición debe ser 'i' para inicio o 'f' para final."
    exit 1
fi

# Verificar que el tipo de generación es válido
if [[ "$generation_type" != "numeric" && "$generation_type" != "text" && "$generation_type" != "alphanumeric" ]]; then
    echo "El tipo de generación debe ser 'numeric', 'text', o 'alphanumeric'."
    exit 1
fi

# Determinar el nombre del archivo de salida
if [ "$position" == "i" ]; then
    # Crear el nombre de archivo con "X"s al principio
    file_name="$(printf "%0${num_chars}d" 0 | sed 's/0/X/g')${fixed_text}.txt"
else
    # Crear el nombre de archivo con "X"s al final
    file_name="${fixed_text}$(printf "%0${num_chars}d" 0 | sed 's/0/X/g').txt"
fi

# Archivo de salida y archivo temporal
output_file="$file_name"
temp_file="temp_diccionario.txt"

# Limpiar el archivo de salida si ya existe
> "$output_file"

# Limpiar el archivo temporal
> "$temp_file"

# Contador de palabras generadas
word_count=0

# Generar combinaciones numéricas
if [ "$generation_type" == "numeric" ] || [ "$generation_type" == "alphanumeric" ]; then
    if [ "$num_chars" -ge 1 ]; then
        start=0
        end=$((10**num_chars - 1))
        while [ "$start" -le "$end" ]; do
            formatted_text=$(printf "%0${num_chars}d" "$start")
            if [ "$position" == "i" ]; then
                echo "${formatted_text}${fixed_text}" >> "$temp_file"
            else
                echo "${fixed_text}${formatted_text}" >> "$temp_file"
            fi
            start=$((start + 1))
            word_count=$((word_count + 1))
        done
    fi
fi

# Generar combinaciones alfabéticas
if [ "$generation_type" == "text" ] || [ "$generation_type" == "alphanumeric" ]; then
    generate_combinations() {
        local prefix="$1"
        local length="$2"
        if [ "$length" -eq 0 ]; then
            if [ "$position" == "i" ]; then
                echo "${prefix}${fixed_text}" >> "$temp_file"
            else
                echo "${fixed_text}${prefix}" >> "$temp_file"
            fi
            word_count=$((word_count + 1))
            return
        fi
        for c in {a..z}; do
            generate_combinations "${prefix}${c}" $((length - 1))
        done
    }

    generate_combinations "" "$num_chars"
fi

# Añadir combinaciones al archivo de salida según la posición
if [ "$position" == "i" ]; then
    cat "$temp_file" > "${output_file}.tmp"
    mv "${output_file}.tmp" "$output_file"
else
    cat "$temp_file" >> "$output_file"
fi

# Limpiar el archivo temporal
rm "$temp_file"

# Mostrar la salida en verde y el número de palabras en azul
echo -e "${GREEN}Diccionario guardado como $output_file${RESET}"
echo -e "${BLUE} -Número de palabras generadas: $word_count${RESET}"
