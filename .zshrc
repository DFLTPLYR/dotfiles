export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git zsh-256color zsh-autosuggestions zsh-syntax-highlighting fzf zoxide)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"

# export PHP_INI_SCAN_DIR="/home/dfltplyr/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
export PATH="$HOME/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/php/conf.d"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"


eval $(thefuck --alias)
eval "$(zoxide init zsh)"

# Aliases
alias checkdns="~/check_dns.sh"
alias vim="nvim"
alias yeetusdeletus='sudo pacman -Rns $(pacman -Qdtq)'
alias yey="yay -Syu"
alias rmpc='rmpc --config .config/rmpc/themes/Catppucin\ Macchiato/config.ron'
alias cloudbackup="Scripts/cloud-backup.zsh"
alias cloudbackup="Scripts/allow-webhid.zsh"
