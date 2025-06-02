# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ~/.zshrc: Configuración del shell interactivo Zsh

# --- Autocompletado y Colores ---
# Habilitar el autocompletado de comandos
# -C: No reinicializar si ya está activo y el archivo de volcado es actual.
# -i: No inicializar si no hay archivos de volcado (dumpfile)
# -d dumpfile_path: Especifica la ruta del archivo de volcado.
if [ -n "$ZDOTDIR" ] && [ -e "$ZDOTDIR/.zcompdump" ]; then
  _zcompdump_path="$ZDOTDIR/.zcompdump"
elif [ -e "$HOME/.zcompdump" ]; then
  _zcompdump_path="$HOME/.zcompdump"
else
  _zcompdump_path="" # No se encontró un archivo de volcado, compinit lo creará
fi

if [ -n "$_zcompdump_path" ]; then
  autoload -U compinit && compinit -i -d "$_zcompdump_path"
else
  autoload -U compinit && compinit -i # Dejar que compinit use la ruta por defecto
fi
unset _zcompdump_path # Limpiar la variable temporal

# Configuración de colores
autoload -U colors && colors

# --- Historial ---
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=20000 # Aumentado un poco, por si acaso
export SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST  # Eliminar duplicados antiguos primero
setopt HIST_IGNORE_DUPS        # No guardar comandos duplicados consecutivos
setopt HIST_IGNORE_ALL_DUPS    # No guardar ningún comando duplicado en el historial
setopt HIST_FIND_NO_DUPS     # Al buscar, no mostrar duplicados consecutivos
setopt HIST_SAVE_NO_DUPS     # Al guardar, eliminar duplicados
setopt EXTENDED_HISTORY        # Guardar timestamp y duración de cada comando
setopt SHARE_HISTORY           # Compartir historial entre todas las sesiones de Zsh (importa de HISTFILE y exporta al salir)
setopt HIST_VERIFY             # No ejecutar inmediatamente comandos recuperados del historial; permitir edición

# --- Editor Preferido ---
# Establecer editor preferido (puedes cambiarlo si prefieres otro editor)
export EDITOR='code --wait'
export VISUAL="$EDITOR" # Buena práctica establecer VISUAL también

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="agnoster" # O cualquier tema que prefieras
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins: considera añadir plugins como 'sudo' (presionar Esc dos veces para añadir sudo)
# o 'colored-man-pages' para páginas de manual coloreadas.
plugins=(
  git
  python
  zsh-autosuggestions # Asegúrate de que esté instalado correctamente
  zsh-syntax-highlighting # Asegúrate de que esté instalado correctamente
  docker
  brew # Autocompletado para Homebrew
  # common-aliases # Podría tener algunos alias útiles, revisa su contenido
  # dirhistory # Navegación de historial de directorios con Alt+Izquierda/Derecha
  # sudo # Presionar Esc dos veces para añadir sudo al comando actual
)

source "$ZSH/oh-my-zsh.sh"

# --- Alias ---
# Es buena práctica agruparlos o poner comentarios para saber qué hacen.

# Git
alias gs='git status -sb' # -sb para salida corta y de rama
alias ga='git add' # Dejar que el usuario especifique qué añadir (ej. ga . o ga archivo.txt)
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit -v -a' # -v para ver el diff, -a para añadir cambios y hacer commit
alias gp='git push'
alias gpf='git push --force-with-lease' # Más seguro que --force
alias gpl='git pull --rebase --autostash'
alias gco='git checkout'
alias gcb='git checkout -b' # Crear nueva rama
alias gl='git log --oneline --graph --decorate --all'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias gb='git branch'
alias gba='git branch -a'
alias gd='git diff'
alias gdc='git diff --cached' # Ver cambios que están en el staging area
alias gss='git stash save'
alias gsp='git stash pop'
alias gsl='git stash list'

# Gestión de archivos y directorios
alias ls='ls -G' # Habilitar colores para ls en macOS
alias l='ls -lGh' # -h para tamaño legible por humanos
alias ll='ls -laGh'
alias la='ls -AF' # Mostrar también archivos ocultos
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias c='clear'
alias md='mkdir -pv' # -v para verbose (mostrar qué se está creando)
alias rd='rmdir'

# rm -i es bueno, pero a veces uno quiere borrar sin confirmación (con cuidado)
# alias rm='rm -i'
# Para borrar sin confirmación (¡PELIGROSO!):
# alias rmf='command rm -rf'

# Navegación rápida
alias reload='source ~/.zshrc && echo "Zsh config reloaded"'
alias cls='clear'
alias h='history 1' # Mostrar historial desde el primer comando

# Búsqueda
alias findf='find . -iname' # -iname para búsqueda insensible a mayúsculas/minúsculas
alias grep='grep --color=auto -n' # -n para mostrar número de línea

# Archivos comprimidos
alias untgz='tar -xzvf'
alias untbz2='tar -xjvf'
# alias unzip='unzip -l' # -l solo lista, para descomprimir es solo 'unzip archivo.zip'

# Procesos
alias psg='ps aux | fzf'
alias top='htop' # Ya lo tenías, es bueno.

# Red (macOS)
alias myip="ipconfig getifaddr en0 || ipconfig getifaddr en1" # Obtener IP de Wi-Fi o Ethernet
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# --- Funciones Zsh ---
# Para comandos más complejos que un simple alias

# Crear un directorio y entrar en él
mkcd() {
  mkdir -pv "$1" && cd "$1"
}

# Extraer varios tipos de archivos comprimidos
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar xjvf "$1" ;;
      *.tar.gz)  tar xzvf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;; # Necesitas 'unrar' instalado
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xvf "$1" ;;
      *.tbz2)    tar xjvf "$1" ;;
      *.tgz)     tar xzvf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;; # Necesitas 'p7zip' instalado
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# --- Configuraciones Específicas de Herramientas ---

# Powerlevel10k (Ya lo tienes configurado, esto solo recuerda dónde está)
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# FZF (Fuzzy Finder)
# Asegúrate de que FZF esté instalado y configurado correctamente.
# Puedes añadir atajos de FZF aquí, por ejemplo:
# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"' # Usa ripgrep para buscar archivos
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Docker Desktop completions
# (Dejar como estaba, ya que Docker lo gestiona)
if [ -f "/Users/agu/.docker/completions/zsh/_docker" ]; then
  fpath=(/Users/agu/.docker/completions $fpath)
  # La llamada a compinit aquí podría ser redundante si la de arriba es suficiente.
  # Si no hay problemas de lentitud, se puede dejar.
  # De lo contrario, se podría intentar comentarla y ver si el autocompletado de Docker sigue funcionando.
  # autoload -Uz compinit
  # compinit
fi

# --- Finalización ---
# Cualquier cosa que deba ejecutarse al final.

# Mensaje de bienvenida (opcional)
# echo "Bienvenido de nuevo, $(whoami)!"

# Asegurarse de que el PATH está correctamente configurado, especialmente si usas herramientas instaladas por Homebrew
# En Macs con Apple Silicon, Homebrew está en /opt/homebrew. En Intel, en /usr/local.
if [ -x /opt/homebrew/bin/brew ]; then # Apple Silicon
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/sbin:$PATH"
elif [ -x /usr/local/bin/brew ]; then # Intel
  export PATH="/usr/local/bin:$PATH"
  export PATH="/usr/local/sbin:$PATH"
fi

# Limpiar variables temporales si es necesario
# unset temp_variable
