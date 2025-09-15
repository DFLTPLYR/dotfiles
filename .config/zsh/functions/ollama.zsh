function ollama() {
  case "$1" in
    --start)
      sudo systemctl start ollama
      ;;
    --stop)
      sudo systemctl stop ollama
      ;;
    --status)
      systemctl status ollama
      ;;
    --restart)
      sudo systemctl restart ollama
      ;;
    *)
      command ollama "$@"
      ;;
  esac
}
