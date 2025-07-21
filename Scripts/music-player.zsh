cols=$(tput cols)
rows=$(tput lines)

if (( $rows < 50 )); then
    rmpc -c ~/.config/rmpc/layout/config.ron
elif (( $rows <= 75 )); then
    rmpc -c ~/.config/rmpc/layout/medium.ron
else
    rmpc -c ~/.config/rmpc/layout/long.ron
fi
