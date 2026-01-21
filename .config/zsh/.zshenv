
eval "$(fzf --zsh)"

if ! . "$ZDOTDIR/conf/env.zsh"; then
    echo "Error: Could not source $ZDOTDIR/conf/env.zsh"
    return 1
fi

if [[ $- == *i* ]] && [ -f "$ZDOTDIR/conf/terminal.zsh" ]; then
    . "$ZDOTDIR/conf/terminal.zsh" || echo "Error: Could not source $ZDOTDIR/conf/terminal.zsh"
fi

[[ -f $ZDOTDIR/.zsh_secrets ]] && source $ZDOTDIR/.zsh_secrets
