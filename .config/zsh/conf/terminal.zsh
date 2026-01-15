#!/usr/bin/env zsh

# Load all custom function files // Directories are ignored
function _load_functions() {
    for file in "${ZDOTDIR:-$HOME/.config/zsh}/functions/"*.zsh; do
        [ -r "$file" ] && source "$file"
    done
}

function _load_compinit() {
    # Initialize completions with optimized performance
    autoload -Uz compinit

    # Enable extended glob for the qualifier to work
    setopt EXTENDED_GLOB

    # Fastest - use glob qualifiers on directory pattern
    compinit -C

    _comp_options+=(globdots) # tab complete hidden files
}

function _load_prompt() {
    # Try to load prompts immediately
    if ! source ${ZDOTDIR}/prompt.zsh > /dev/null 2>&1; then
        [[ -f $ZDOTDIR/conf/prompt.zsh ]] && source $ZDOTDIR/conf/prompt.zsh
    fi
}

# Override this environment variable in ~/.zshrc
# cleaning up home folder
# ZSH Plugin Configuration

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# # History configuration
HISTFILE=${HISTFILE:-$ZDOTDIR/.zsh_history}
if [[ -f $HOME/.zsh_history ]] && [[ ! -f $HISTFILE ]]; then
    echo "Please manually move $HOME/.zsh_history to $HISTFILE"
    echo "Or move it somewhere else to avoid conflicts"
fi

export HISTFILE ZSH_AUTOSUGGEST_STRATEGY

source $HOME/.user.zsh
fpath+=("/usr/share/zsh/site-functions")

_load_compinit
_load_prompt
_load_functions
