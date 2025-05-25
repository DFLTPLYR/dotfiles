export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git zsh-256color zsh-autosuggestions zsh-syntax-highlighting fzf zoxide)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"

# export PHP_INI_SCAN_DIR="/home/dfltplyr/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
export PATH="/home/dfltplyr/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/php/conf.d"
export PATH="/home/dfltplyr/.config/composer/vendor/bin:$PATH"

eval $(thefuck --alias)
eval "$(zoxide init zsh)"

function allowwebhid() {
  local device
  local changed=0
  local failed=0

  for device in /dev/hidraw*; do
    if [[ ! -e $device ]]; then
      echo "❌ No HIDRAW devices found."
      return 1
    fi

    echo "🔧 Setting permissions on $device..."
    if sudo chmod a+rw "$device"; then
      local perms
      perms=$(ls -l "$device" | awk '{print $1, $3, $4}')
      echo "✅ $device permissions set: $perms"
      ((changed++))
    else
      echo "❌ Failed to set permissions on $device"
      ((failed++))
    fi
  done

  echo "\n📊 Summary:"
  echo "  ✅ Success: $changed"
  echo "  ❌ Failed:  $failed"
}

function ff() {
    # Default values
    local file="/home/dfltplyr/Pictures/meme/shigure-ui.gif"
    local args=()

    # Parse for -f option (optional override)
    while [[ "$1" != "" ]]; do
        case "$1" in
            -f|--file)
                shift
                file="$1"
                ;;
            *)
                args+=("$1")
                ;;
        esac
        shift
    done

    # Run the script with the file and other args
    python3 anifetch/anifetch.py -f "$file" "${args[@]}" -ff
}

function backupMega() {
    if [[ -z "$1" ]]; then
      echo "Usage: backupMegaZip /path/to/folder"
      return 1
    fi

    local folder="$1"
    local foldername=$(basename "$folder")
    local zipfile="/tmp/${foldername}.zip"

    echo "Zipping folder '$folder' to '$zipfile' ..."
    zip -r "$zipfile" "$folder" || {
      echo "Zip failed"
      return 2
    }

    echo "Uploading zipped file to mega:MusicBackup ..."
    rclone copy "$zipfile" mega:MusicBackup/ --progress || {
      echo "Upload failed"
      return 3
    }

    local remote_path="mega:MusicBackup/${foldername}.zip"
    echo "Generating public link for $remote_path ..."
    local link=$(rclone link "$remote_path" 2>/dev/null)

    if [[ -n "$link" ]]; then
      echo "Public link for zipped folder:"
      echo "$link"
    else
      echo "⚠️ Failed to create public link"
    fi


    rm "$zipfile"
}


# Aliases
alias checkdns="~/check_dns.sh"
alias vim="nvim"
alias yeetusdeletus='sudo pacman -Rns $(pacman -Qdtq)'
alias yey="yay -Syu"
alias rmpc='rmpc --config .config/rmpc/themes/Catppucin\ Macchiato/config.ron'
