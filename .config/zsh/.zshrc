if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.config/zsh/.p10k.zsh.
[[ ! -f ~/dotfiles/.config/zsh/.p10k.zsh ]] || source ~/dotfiles/.config/zsh/.p10k.zsh
