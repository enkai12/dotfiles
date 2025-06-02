#!/bin/bash
# Script para crear enlaces simbólicos de los dotfiles, con mejoras.

# --- Configuración ---
# Usar $HOME es a menudo más seguro en scripts que ~
DOTFILES_DIR="$HOME/dotfiles"
OLD_DOTFILES_BACKUP_DIR="$HOME/dotfiles_old_backup"

# Lista de archivos a enlazar.
# Formato: "nombre_en_repo_dotfiles:ruta_relativa_desde_home_para_el_enlace"
# Ejemplo para un archivo en .config: "nvim/init.vim:.config/nvim/init.vim"
files_to_link=(
    "gitconfig:.gitconfig"
    "zshrc:.zshrc"
    "p10k.zsh:.p10k.zsh" # Ejemplo, asegúrate de que 'p10k.zsh' existe en $DOTFILES_DIR
    # "alacritty/alacritty.toml:.config/alacritty/alacritty.toml" # Ejemplo de destino profundo
    # "tmux.conf:.tmux.conf"
)

# --- Funciones de Ayuda ---
ask_for_confirmation() {
    while true; do
        # No es necesario escapar _ en OLD_DOTFILES_BACKUP_DIR aquí
        read -r -p "Este script moverá archivos existentes a $OLD_DOTFILES_BACKUP_DIR y creará enlaces simbólicos. ¿Deseas continuar? (s/N): " response
        case "$response" in
            [sS][iI]|[sS]) # Acepta 's', 'S', 'si', 'Si', 'SI'
                echo "Continuando..."
                return 0
                ;;
            [nN][oO]|[nN]|"") # Acepta 'n', 'N', 'no', 'No', 'NO', o Enter (vacío)
                echo "Operación cancelada por el usuario."
                return 1
                ;;
            *) # El asterisco NO debe estar escapado aquí
                echo "Respuesta no válida. Por favor, introduce 's' para sí o 'n' para no."
                ;;
        esac
    done
}

# --- Lógica Principal ---

# 1. Pedir confirmación al usuario
if ! ask_for_confirmation; then # El signo de exclamación NO debe estar escapado aquí
    exit 0 # Salir del script si el usuario cancela
fi

# 2. Crear directorio de backup si no existe
# No es necesario escapar _ en OLD_DOTFILES_BACKUP_DIR aquí
echo "Creando directorio de backup para dotfiles existentes en $OLD_DOTFILES_BACKUP_DIR..."
mkdir -p "$OLD_DOTFILES_BACKUP_DIR"
echo "Directorio de backup asegurado en: $OLD_DOTFILES_BACKUP_DIR"
echo "---"

# 3. Crear enlaces simbólicos
echo "Iniciando creación de enlaces simbólicos..."
# No es necesario escapar los caracteres especiales del array en esta expansión
for item in "${files_to_link[@]}"; do
    source_file_name=$(echo "$item" | cut -d':' -f1)
    target_link_name=$(echo "$item" | cut -d':' -f2)

    source_file_path="$DOTFILES_DIR/$source_file_name"
    target_link_path="$HOME/$target_link_name"

    echo "Procesando: $source_file_name -> $target_link_path"

    # 3a. Verificar si el archivo fuente existe en el repositorio de dotfiles
    if [ ! -e "$source_file_path" ]; then
        echo "  ERROR: El archivo fuente '$source_file_path' no existe. Saltando este archivo."
        continue # Saltar al siguiente item del bucle
    fi

    # 3b. Crear el directorio de destino si no existe (para rutas profundas como ~/.config/app/...)
    target_link_dir=$(dirname "$target_link_path")
    if [ ! -d "$target_link_dir" ]; then
        echo "  INFO: El directorio de destino '$target_link_dir' no existe. Creándolo..."
        mkdir -p "$target_link_dir"
    fi

    # 3c. Si el archivo/enlace original en HOME existe, moverlo al directorio de backup
    if [ -f "$target_link_path" ] || [ -L "$target_link_path" ]; then
        echo "  INFO: Moviendo '$target_link_path' existente a $OLD_DOTFILES_BACKUP_DIR"
        mv "$target_link_path" "$OLD_DOTFILES_BACKUP_DIR/"
    fi

    # 3d. Crear el enlace simbólico
    echo "  INFO: Enlazando '$source_file_path' a '$target_link_path'"
    ln -s "$source_file_path" "$target_link_path"
    echo "  HECHO: Enlace creado para $source_file_name."
    echo "---"
done

echo "¡Proceso de enlazado de Dotfiles completado!"
echo "No olvides ejecutar 'source ~/.zshrc' o reiniciar tu terminal si has actualizado la configuración de Zsh."

