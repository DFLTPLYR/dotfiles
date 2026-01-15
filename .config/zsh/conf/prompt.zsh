#!/usr/bin/env zsh
eval "$(starship init zsh)"
eval "$(thefuck --alias)"

export STARSHIP_CACHE=$XDG_CACHE_HOME/starship
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
POWERLEVEL10K_TRANSIENT_PROMPT=same-dir
P10k_THEME=${P10k_THEME:-/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme}
[[ -r $P10k_THEME ]] && source $P10k_THEME

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh
if [[ -f $HOME/.p10k.zsh ]]; then
   source $HOME/.p10k.zsh
fi

